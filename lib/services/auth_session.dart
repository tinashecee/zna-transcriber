import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/user.dart';

class AuthSession {
  const AuthSession({
    this.token,
    this.apiKey,
    this.user,
    this.offlineOnly = false,
  });

  final String? token;

  /// Machine client key sent as `X-API-Key` (preferred over JWT when set).
  final String? apiKey;

  final User? user;

  /// When true, user was authenticated via local bcrypt verify (no JWT).
  /// API calls remain unauthorized until online sign-in or API key.
  final bool offlineOnly;

  bool get isAuthenticated {
    final u = user;
    if (u == null) return false;
    if (hasApiKey) return true;
    if (offlineOnly) return true;
    return token != null && token!.isNotEmpty;
  }

  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;

  /// Whether the app has a Bearer token suitable for HTTPS API requests.
  bool get hasJwtForApi =>
      !offlineOnly && !hasApiKey && token != null && token!.isNotEmpty;

  /// Headers for non-Dio clients (audio streaming, probes).
  Map<String, String>? get httpAuthHeaders {
    if (hasApiKey) {
      return {'X-API-Key': apiKey!};
    }
    if (token != null && token!.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return null;
  }
}

class AuthSessionController extends StateNotifier<AuthSession> {
  AuthSessionController() : super(const AuthSession());

  void setSession({required String token, required User user}) {
    state = AuthSession(token: token, user: user, offlineOnly: false);
  }

  void setApiKeySession({required String apiKey, required User user}) {
    state = AuthSession(
      apiKey: apiKey,
      user: user,
      offlineOnly: false,
    );
  }

  void setOfflineSession({required User user}) {
    state = AuthSession(token: null, user: user, offlineOnly: true);
  }

  void clear() {
    state = const AuthSession();
  }
}

final authSessionProvider =
    StateNotifierProvider<AuthSessionController, AuthSession>((ref) {
  return AuthSessionController();
});
