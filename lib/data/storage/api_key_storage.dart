import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the machine API key used for `X-API-Key` auth (no login).
///
/// Uses platform secure storage (Windows credential store / DPAPI). Legacy
/// SharedPreferences values are migrated once, then removed from plaintext.
class ApiKeyStorage {
  static const _key = 'machine_api_key';
  static const _legacyPrefsKey = 'machine_api_key';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<void> writeApiKey(String apiKey) async {
    final trimmed = apiKey.trim();
    await _secure.write(key: _key, value: trimmed);
    await _clearLegacyPrefs();
    final verify = (await _secure.read(key: _key))?.trim();
    if (verify != trimmed) {
      throw StateError('Secure storage failed to persist API key');
    }
  }

  Future<String?> readApiKey() async {
    final fromSecure = (await _secure.read(key: _key))?.trim();
    if (fromSecure != null && fromSecure.isNotEmpty) {
      return fromSecure;
    }

    // One-time migration from older plaintext SharedPreferences installs.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_legacyPrefsKey)?.trim();
    if (legacy == null || legacy.isEmpty) return null;

    await _secure.write(key: _key, value: legacy);
    await prefs.remove(_legacyPrefsKey);
    return legacy;
  }

  Future<void> clearApiKey() async {
    await _secure.delete(key: _key);
    await _clearLegacyPrefs();
  }

  Future<void> _clearLegacyPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_legacyPrefsKey);
    } catch (_) {
      // Best-effort cleanup of legacy plaintext copy.
    }
  }
}
