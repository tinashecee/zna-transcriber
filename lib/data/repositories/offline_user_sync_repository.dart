import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../local/offline_users_database.dart';
import '../../utils/email_normalize.dart';

/// Downloads the full user roster (including bcrypt `password_hash`) for
/// offline sign-in. Requires a valid JWT via [ApiClient] interceptors.
class OfflineUserSyncRepository {
  OfflineUserSyncRepository(
    this._client,
    this._db, {
    String syncPath = '/users',
  }) : _syncPath = syncPath.startsWith('/') ? syncPath : '/$syncPath';

  final ApiClient _client;
  final OfflineUsersDatabase _db;
  final String _syncPath;

  /// Persists the signed-in user from the login JSON so offline sign-in works
  /// even when the roster sync route is unavailable. Expects bcrypt in `password` or
  /// `password_hash` (Flask column is often `password`). Never logs secrets.
  Future<bool> cacheUserFromSuccessfulLogin(Map<String, dynamic> userPayload) async {
    final id = _readString(userPayload, 'id');
    final email = _readString(userPayload, 'email');
    final hasBcrypt = _bcryptFieldFromMap(userPayload).isNotEmpty;
    debugPrint(
      '[UserCache] upsert-from-login START id=${id.isEmpty ? "(empty)" : id} '
      'email=${email.isEmpty ? "(empty)" : email} bcryptFieldPresent=$hasBcrypt',
    );

    final companion = _companionFromUserMap(userPayload);
    if (companion == null) {
      debugPrint(
        '[UserCache] upsert-from-login SKIP reason=${_explainRejectReason(userPayload)}',
      );
      return false;
    }

    await _db.upsertCachedUser(companion);
    debugPrint(
      '[UserCache] upsert-from-login OK drift write id=$id '
      'emailNorm=${normalizeEmailForAuth(email)}',
    );
    return true;
  }

  /// Parses response and replaces the local cache in one transaction.
  /// Returns number of users written. Never logs password hashes.
  Future<int> syncFullRoster() async {
    final resp = await _client.dio.get<dynamic>(_syncPath);
    final raw = resp.data;
    final list = _coerceUserList(raw);
    if (list.isEmpty) {
      await _db.replaceAllUsers(const []);
      return 0;
    }

    final companions = <CachedUsersCompanion>[];
    for (final item in list) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final companion = _companionFromUserMap(m);
      if (companion == null) continue;
      companions.add(companion);
    }

    await _db.replaceAllUsers(companions);
    return companions.length;
  }

  List<dynamic> _coerceUserList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      if (raw['users'] is List) return raw['users'] as List;
      if (raw['data'] is List) return raw['data'] as List;
    }
    throw DioException(
      requestOptions: RequestOptions(path: _syncPath),
      message: 'Unexpected users roster response shape (expected JSON array)',
    );
  }

  String _readString(Map<String, dynamic> m, String key) =>
      (m[key] ?? '').toString();

  String? _nullableString(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  /// Flask-Bcrypt usually stores under `password`; sync API may use `password_hash`.
  String _bcryptFieldFromMap(Map<String, dynamic> m) {
    final h = _readString(m, 'password_hash');
    if (h.isNotEmpty) return h;
    return _readString(m, 'password');
  }

  String _explainRejectReason(Map<String, dynamic> m) {
    final id = _readString(m, 'id');
    final emailRaw = _readString(m, 'email');
    final hasHash = _bcryptFieldFromMap(m).isNotEmpty;
    final hasPwdKey = m.containsKey('password');
    final hasHashKey = m.containsKey('password_hash');
    if (id.isEmpty) return 'missing id';
    if (emailRaw.isEmpty) return 'missing email';
    if (!hasHash) {
      return 'missing bcrypt string (need non-empty password or password_hash; '
          'keysPresent password=$hasPwdKey password_hash=$hasHashKey)';
    }
    return 'unknown';
  }

  CachedUsersCompanion? _companionFromUserMap(Map<String, dynamic> m) {
    final id = _readString(m, 'id');
    final emailRaw = _readString(m, 'email');
    final hash = _bcryptFieldFromMap(m);
    if (id.isEmpty || emailRaw.isEmpty || hash.isEmpty) return null;

    return CachedUsersCompanion(
      id: Value(id),
      name: Value(
        _readString(m, 'name').isEmpty ? emailRaw : _readString(m, 'name'),
      ),
      emailNormalized: Value(normalizeEmailForAuth(emailRaw)),
      role: Value(
        _readString(m, 'role').isEmpty ? 'transcriber' : _readString(m, 'role'),
      ),
      court: Value(_nullableString(m, 'court')),
      contactInfo: Value(_nullableString(m, 'contact_info')),
      province: Value(_nullableString(m, 'province')),
      region: Value(_nullableString(m, 'region')),
      district: Value(_nullableString(m, 'district')),
      dateCreated: Value(_nullableString(m, 'date_created')),
      passwordHash: Value(hash),
    );
  }
}
