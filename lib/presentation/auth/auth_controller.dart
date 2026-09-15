import 'dart:async';

import 'package:bcrypt/bcrypt.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../app/providers.dart';
import '../../data/providers.dart';
import '../../domain/entities/user.dart';
import '../../services/auth_session.dart';
import '../../utils/email_normalize.dart';
import 'package:logging/logging.dart';

import '../recordings/recordings_controller.dart';
import '../transcript/transcript_controller.dart';

class AuthState {
  AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  /// One-shot flag set when the session was terminated because the JWT
  /// expired (either detected by the periodic check or by a 401 from the
  /// API). The login screen consumes this to show a "please sign in again"
  /// message, then calls [AuthController.clearSessionExpired].
  final bool sessionExpired;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    bool? sessionExpired,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }

  static AuthState initial() => AuthState(isAuthenticated: false);
}

class AuthController extends ChangeNotifier {
  AuthController(this._ref, {bool mockAuthenticated = false}) {
    _logger = Logger('AuthController');
    if (mockAuthenticated) {
      _state = AuthState(isAuthenticated: true);
      return;
    }
    // Restore machine API key session from disk (no login required).
    _state = AuthState(isAuthenticated: false, isLoading: true);
    unawaited(_restoreApiKeySession());
  }

  static const machineUser = User(
    id: 'machine-clients',
    name: 'Machine Client',
    email: 'machine-clients@local',
    role: 'super_admin',
  );

  final Ref _ref;
  late final Logger _logger;
  AuthState _state = AuthState.initial();
  Timer? _expiryTimer;
  bool _handlingExpiry = false;

  AuthState get value => _state;

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  Future<void> _restoreApiKeySession() async {
    try {
      final key = await _ref.read(apiKeyStorageProvider).readApiKey();
      if (key != null && key.isNotEmpty) {
        await _applyApiKeySession(key);
        _setState(AuthState(isAuthenticated: true, isLoading: false));
        _logger.info('Restored API key session for ${machineUser.email}');
        return;
      }
      _logger.info('No stored API key to restore');
    } catch (e, st) {
      _logger.warning('Failed to restore API key session', e, st);
    }
    _setState(AuthState(isAuthenticated: false, isLoading: false));
  }

  Future<void> _applyApiKeySession(String apiKey) async {
    _expiryTimer?.cancel();
    _ref.read(authSessionProvider.notifier).setApiKeySession(
          apiKey: apiKey,
          user: machineUser,
        );
    try {
      await _ref.read(userStorageProvider).writeUser(machineUser);
    } catch (e) {
      _logger.warning('Failed to persist machine user profile', e);
    }
  }

  /// Saves the machine API key, activates the session, and skips login.
  Future<void> saveApiKey(String apiKey) async {
    final trimmed = apiKey.trim();
    _setState(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      if (trimmed.isEmpty) {
        await clearApiKey();
        return;
      }
      await _ref.read(apiKeyStorageProvider).writeApiKey(trimmed);
      await _applyApiKeySession(trimmed);
      _ref.invalidate(recordingsControllerProvider);
      _setState(AuthState(isAuthenticated: true, isLoading: false));
      _logger.info('API key saved; authenticated as ${machineUser.email}');
    } catch (e, st) {
      _logger.severe('Failed to save API key', e, st);
      _setState(_state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save API key.',
      ));
    }
  }

  /// Removes the stored API key and clears the session.
  Future<void> clearApiKey() async {
    _expiryTimer?.cancel();
    _setState(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _ref.read(apiKeyStorageProvider).clearApiKey();
      await _ref.read(userStorageProvider).clearUser();
      _ref.read(authSessionProvider.notifier).clear();
      _ref.invalidate(recordingsControllerProvider);
      _ref.invalidate(transcriptControllerProvider);
      _setState(AuthState.initial());
    } catch (e, st) {
      _logger.severe('Failed to clear API key', e, st);
      _ref.read(authSessionProvider.notifier).clear();
      _setState(AuthState.initial());
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _logger.info('Starting login attempt for email: $email');
    _setState(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      _logger.info('Attempting API login...');
      final authRepo = _ref.read(authRepositoryProvider);
      final response = await authRepo.login(email, password);

      _logger.info('API login successful, parsing response...');

      final token = response['token'] as String?;
      if (token == null || token.isEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: '/login'),
          message: 'Missing token in login response',
        );
      }

      final dynamic rawUser = response['user'] ?? response;
      if (rawUser is! Map) {
        throw DioException(
          requestOptions: RequestOptions(path: '/login'),
          message: 'Login response user payload is not a JSON object',
        );
      }
      final userMap = Map<String, dynamic>.from(rawUser);
      // Drop auth noise if the whole response was used as `user`.
      userMap.remove('token');
      // Bcrypt may be on the user object as `password` or only on the root — merge safely.
      for (final k in ['password', 'password_hash']) {
        final rootVal = response[k];
        if (rootVal != null) {
          final existing = userMap[k];
          if (existing == null || existing.toString().isEmpty) {
            userMap[k] = rootVal;
          }
        }
      }

      debugPrint(
        '[UserCache] login response: root keys password=${response.containsKey('password')} '
        'password_hash=${response.containsKey('password_hash')}',
      );
      debugPrint(
        '[UserCache] user payload after merge: has password=${userMap.containsKey('password')} '
        'has password_hash=${userMap.containsKey('password_hash')} '
        '(values are never logged)',
      );

      _logger.info('Token received: Yes (${token.length} chars)');
      final safeKeys = userMap.keys
          .where((k) => k != 'password' && k != 'password_hash')
          .toList();
      _logger.info('User field keys (sanitized): $safeKeys');

      final user = User(
        id: userMap['id'].toString(),
        email: userMap['email'] ?? email,
        name: userMap['name'] ?? 'Test User',
        role: userMap['role'] ?? 'transcriber',
        court: userMap['court'],
        contactInfo: userMap['contact_info'],
        district: userMap['district'],
        province: userMap['province'],
        region: userMap['region'],
        dateCreated: userMap['date_created'],
      );

      _logger.info('User created: ${user.name} (${user.email}) - Role: ${user.role}');
      _logger.info(
        'Online login profile: id=${user.id} role=${user.role} court=${user.court}',
      );

      // Password login replaces machine API-key auth for this install.
      try {
        await _ref.read(apiKeyStorageProvider).clearApiKey();
      } catch (_) {}

      _ref.read(authSessionProvider.notifier).setSession(token: token, user: user);
      _ref.read(offlineSyncWarningProvider.notifier).state = null;
      // Persist ONLY the user profile. Token stays in memory.
      await _ref.read(userStorageProvider).writeUser(user);

      debugPrint('[UserCache] calling upsert-from-login (Drift) …');
      try {
        final cached = await _ref
            .read(offlineUserSyncRepositoryProvider)
            .cacheUserFromSuccessfulLogin(userMap);
        if (cached) {
          _logger.info('Offline user row upserted for online login (Drift cache)');
          debugPrint('[UserCache] upsert-from-login returned success=true');
        } else {
          _logger.warning(
            'Offline cache: login JSON missing id, email, or bcrypt field '
            '(expected `password` or `password_hash` on user or root).',
          );
          debugPrint('[UserCache] upsert-from-login returned success=false (see [UserCache] SKIP line)');
        }
      } catch (e, st) {
        _logger.warning('Offline cache: failed to upsert logged-in user', e, st);
        debugPrint('[UserCache] upsert-from-login EXCEPTION $e');
      }

      final syncPath = _ref.read(appConfigProvider).offlineUsersSyncPath;
      debugPrint('[UserCache] starting full roster sync (GET $syncPath) …');
      try {
        final count =
            await _ref.read(offlineUserSyncRepositoryProvider).syncFullRoster();
        _logger.info('Offline roster sync complete: cached $count users');
        debugPrint('[UserCache] roster sync OK wrote $count user rows (replace-all)');
      } catch (e, st) {
        if (e is DioException && e.response?.statusCode == 404) {
          _logger.warning(
            'Offline roster sync: $syncPath returned 404 — deploy this route on '
            'the API or set offlineUsersSyncPath in assets/config.json.',
          );
          debugPrint(
            '[UserCache] roster sync NOT AVAILABLE (404 GET $syncPath). '
            'Online session is fine.',
          );
        } else {
          _logger.warning('Offline roster sync failed', e, st);
          debugPrint('[UserCache] roster sync FAILED $e');
        }
        _ref.read(offlineSyncWarningProvider.notifier).state =
            'Could not refresh the offline user list. You can continue online; '
            'sign in again when the network or server allows sync for offline login.';
      }

      _logger.info('Login successful, navigating to recordings');
      _setState(_state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        sessionExpired: false,
      ));
      _startExpiryWatch(token);
    } catch (error, stackTrace) {
      _logger.severe('API login failed', error, stackTrace);

      String message = 'Incorrect email or password.';
      if (error is DioException) {
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        if (statusCode == 401 || statusCode == 403) {
          message = 'Incorrect email or password.';
        } else if (data is Map) {
          final apiMessage = (data['message'] ?? data['error'] ?? data['detail'])?.toString().trim();
          if (apiMessage != null && apiMessage.isNotEmpty) {
            final lower = apiMessage.toLowerCase();
            if (lower.contains('invalid') || lower.contains('incorrect') ||
                lower.contains('wrong') || lower.contains('credential') ||
                lower.contains('password') || lower.contains('email') ||
                lower.contains('unauthorized')) {
              message = 'Incorrect email or password.';
            } else {
              message = apiMessage;
            }
          }
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Server error. Please try again later.';
        }
      } else {
        final errStr = error.toString();
        if (errStr.contains('SocketException') ||
            errStr.contains('Connection refused') ||
            errStr.contains('Failed host lookup') ||
            errStr.contains('Connection timed out')) {
          message = 'Cannot reach server. Check your connection and try again.';
        }
      }

      _setState(_state.copyWith(
        isLoading: false,
        errorMessage: message,
      ));
    }
  }

  /// Local sign-in using cached bcrypt hashes (no JWT). Requires a prior online
  /// login to populate the drift cache successfully.
  Future<void> loginOffline({
    required String email,
    required String password,
  }) async {
    debugPrint('[OfflineLogin] attempt START (password value is never logged)');
    _logger.info('Starting offline login attempt (email normalized)');
    _setState(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      final normalized = normalizeEmailForAuth(email);
      debugPrint('[OfflineLogin] normalizedEmail=$normalized');
      final db = _ref.read(offlineUsersDatabaseProvider);
      final totalCached = await db.countUsers();
      debugPrint('[OfflineLogin] drift table cached_users total rows=$totalCached');

      final row = await db.rowByNormalizedEmail(normalized);
      if (row == null) {
        debugPrint(
          '[OfflineLogin] lookup by emailNormalized: NO ROW (cannot verify offline)',
        );
        _setState(_state.copyWith(
          isLoading: false,
          errorMessage:
              'No offline profile for this email. Sign in online once while the server '
              'returns the user roster, then try again.',
        ));
        return;
      }

      debugPrint(
        '[OfflineLogin] lookup HIT cachedUserId=${row.id} role=${row.role} '
        'name=${row.name}',
      );
      debugPrint('[OfflineLogin] running BCrypt.checkpw (stored hash not logged) …');
      final ok = BCrypt.checkpw(password, row.passwordHash);
      debugPrint('[OfflineLogin] BCrypt.checkpw result: ${ok ? "MATCH" : "MISMATCH"}');
      if (!ok) {
        _setState(_state.copyWith(
          isLoading: false,
          errorMessage: 'Incorrect email or password.',
        ));
        debugPrint('[OfflineLogin] attempt END uiError=bad_credentials');
        return;
      }

      final user = User(
        id: row.id,
        email: normalized,
        name: row.name,
        role: row.role,
        court: row.court,
        contactInfo: row.contactInfo,
        district: row.district,
        province: row.province,
        region: row.region,
        dateCreated: row.dateCreated,
      );

      _ref.read(authSessionProvider.notifier).setOfflineSession(user: user);
      await _ref.read(userStorageProvider).writeUser(user);

      _setState(_state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        sessionExpired: false,
      ));
      _logger.info('Offline login successful for cached user id=${user.id}');
      debugPrint(
        '[OfflineLogin] session set offlineOnly=true userId=${user.id} '
        'role=${user.role}',
      );
      debugPrint('[OfflineLogin] attempt END success');
    } catch (error, stackTrace) {
      _logger.severe('Offline login failed', error, stackTrace);
      debugPrint('[OfflineLogin] attempt END exception=$error');
      _setState(_state.copyWith(
        isLoading: false,
        errorMessage: 'Offline sign-in failed. Please try again.',
      ));
    }
  }

  Future<void> logout() async {
    _expiryTimer?.cancel();
    _setState(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      final hadApiKey = _ref.read(authSessionProvider).hasApiKey;
      // Keep machine API key on disk so app restarts / reloads can restore it.
      // Only the explicit "Remove key" action clears SharedPreferences.
      await _ref.read(userStorageProvider).clearUser();
      _ref.read(authSessionProvider.notifier).clear();
      _ref.invalidate(recordingsControllerProvider);
      _ref.invalidate(transcriptControllerProvider);

      if (!hadApiKey) {
        try {
          final authRepo = _ref.read(authRepositoryProvider);
          await authRepo.logout();
        } catch (_) {
          // Ignore logout endpoint errors - local cleanup is more important
        }
      }

      _setState(AuthState.initial());
    } catch (error) {
      _ref.read(authSessionProvider.notifier).clear();
      _setState(AuthState.initial());
    }
  }

  /// Clears the current session because the JWT has expired. Triggered from
  /// either the 401 interceptor on [ApiClient] or the periodic expiry check.
  /// Leaves [AuthState.sessionExpired] = true so the login screen can prompt
  /// the user to sign in again.
  Future<void> handleSessionExpired() async {
    if (_handlingExpiry) return;
    _handlingExpiry = true;
    _expiryTimer?.cancel();
    _logger.warning('Session expired, clearing auth state');
    try {
      await _ref.read(userStorageProvider).clearUser();
      _ref.read(authSessionProvider.notifier).clear();
      _ref.invalidate(recordingsControllerProvider);
      _ref.invalidate(transcriptControllerProvider);
    } catch (e) {
      _logger.severe('Error clearing session on expiry', e);
    } finally {
      _setState(AuthState(
        isAuthenticated: false,
        sessionExpired: true,
      ));
      _handlingExpiry = false;
    }
  }

  /// One-shot acknowledgement from the login screen so the "session expired"
  /// banner only shows once.
  void clearSessionExpired() {
    if (!_state.sessionExpired) return;
    _setState(_state.copyWith(sessionExpired: false));
  }

  /// Starts a periodic JWT expiry check for the given token. Cancels any
  /// existing timer first. On expiry, triggers [handleSessionExpired] so the
  /// user is routed to the login screen even without making an API call.
  void _startExpiryWatch(String? token) {
    _expiryTimer?.cancel();
    if (token == null || token.isEmpty) return;
    if (_ref.read(authSessionProvider).offlineOnly) return;
    if (_ref.read(authSessionProvider).hasApiKey) return;

    _expiryTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final currentToken = _ref.read(authSessionProvider).token;
      if (currentToken == null || currentToken.isEmpty) {
        _expiryTimer?.cancel();
        return;
      }
      try {
        if (JwtDecoder.isExpired(currentToken)) {
          await handleSessionExpired();
        }
      } catch (e) {
        _logger.warning('JWT expiry check failed', e);
      }
    });
  }

  Future<void> forgotPassword(String email) async {
    _setState(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _ref.read(authRepositoryProvider).sendPasswordReset(email);
      _setState(_state.copyWith(isLoading: false));
    } catch (error) {
      _setState(
        _state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }
}

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(ref);
});
