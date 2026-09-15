import 'package:drift/drift.dart';

import '../local/offline_users_database.dart';

class TranscriptCacheRepository {
  TranscriptCacheRepository(this._db);

  final OfflineUsersDatabase _db;

  Future<CachedRecordingTranscriptRow?> row({
    required String ownerUserId,
    required String recordingId,
  }) {
    return (_db.select(_db.cachedRecordingTranscripts)
          ..where((t) =>
              t.ownerUserId.equals(ownerUserId) &
              t.recordingId.equals(recordingId)))
        .getSingleOrNull();
  }

  Future<String?> getHtml({
    required String ownerUserId,
    required String recordingId,
  }) async {
    final r = await row(ownerUserId: ownerUserId, recordingId: recordingId);
    if (r == null) return null;
    final html = r.html.trim();
    return html.isEmpty ? null : html;
  }

  Future<void> upsert({
    required String ownerUserId,
    required String recordingId,
    required String html,
  }) async {
    if (ownerUserId.isEmpty || recordingId.isEmpty) return;
    await _db.into(_db.cachedRecordingTranscripts).insert(
          CachedRecordingTranscriptsCompanion.insert(
            ownerUserId: ownerUserId,
            recordingId: recordingId,
            html: html,
            updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}

