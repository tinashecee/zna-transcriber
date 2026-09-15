import 'dart:convert';

import 'package:drift/drift.dart';

import '../local/offline_users_database.dart';
import '../models/recording_model.dart';
import '../../domain/entities/recording.dart';

/// Persists My List API snapshots for offline browsing (per [ownerUserId]).
class RecordingsCacheRepository {
  RecordingsCacheRepository(this._db);

  final OfflineUsersDatabase _db;

  /// Cap rows per user after each upsert batch (plan: avoid unbounded growth).
  static const int maxRowsPerUser = 400;

  int _listDateMillisFromItem(Map<String, dynamic> json) {
    final raw = json['date_stamp'] ?? json['date'] ?? json['recorded_at'];
    if (raw == null) return 0;
    if (raw is DateTime) return raw.millisecondsSinceEpoch;
    if (raw is String) {
      if (raw.isEmpty) return 0;
      final d = DateTime.tryParse(raw);
      return d?.millisecondsSinceEpoch ?? 0;
    }
    if (raw is int) {
      if (raw > 20000000000) return raw;
      return raw * 1000;
    }
    if (raw is num) {
      final v = raw.toInt();
      if (v > 20000000000) return v;
      return v * 1000;
    }
    return 0;
  }

  Future<void> upsertMyListItems(
    String ownerUserId,
    List<Map<String, dynamic>> items,
  ) async {
    if (ownerUserId.isEmpty || items.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final item in items) {
      final id = item['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      final listMillis = _listDateMillisFromItem(item);
      await _db.into(_db.cachedMyListRecordings).insert(
            CachedMyListRecordingsCompanion.insert(
              ownerUserId: ownerUserId,
              recordingId: id,
              payloadJson: jsonEncode(item),
              listDateMillis: listMillis,
              syncedAtMillis: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
    await _pruneExcess(ownerUserId);
  }

  Future<void> _pruneExcess(String ownerUserId) async {
    final rows = await (_db.select(_db.cachedMyListRecordings)
          ..where((t) => t.ownerUserId.equals(ownerUserId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.listDateMillis, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.recordingId, mode: OrderingMode.desc),
          ]))
        .get();
    if (rows.length <= maxRowsPerUser) return;
    final drop = rows.skip(maxRowsPerUser).map((r) => r.recordingId).toList();
    await (_db.delete(_db.cachedMyListRecordings)
          ..where((t) =>
              t.ownerUserId.equals(ownerUserId) & t.recordingId.isIn(drop)))
        .go();
  }

  /// All cached My List recordings for [ownerUserId], latest first.
  Future<List<Recording>> recordingsForUser(String ownerUserId) async {
    if (ownerUserId.isEmpty) return const [];
    final rows = await (_db.select(_db.cachedMyListRecordings)
          ..where((t) => t.ownerUserId.equals(ownerUserId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.listDateMillis, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.recordingId, mode: OrderingMode.desc),
          ]))
        .get();
    final out = <Recording>[];
    for (final row in rows) {
      try {
        final map = jsonDecode(row.payloadJson) as Map<String, dynamic>;
        out.add(RecordingModel.fromJson(map).toEntity());
      } catch (_) {
        continue;
      }
    }
    return out;
  }

  Future<Recording?> recordingById({
    required String ownerUserId,
    required String recordingId,
  }) async {
    if (ownerUserId.isEmpty || recordingId.isEmpty) return null;
    final row = await (_db.select(_db.cachedMyListRecordings)
          ..where((t) =>
              t.ownerUserId.equals(ownerUserId) &
              t.recordingId.equals(recordingId)))
        .getSingleOrNull();
    if (row == null) return null;
    try {
      final map = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      return RecordingModel.fromJson(map).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<int> countForUser(String ownerUserId) async {
    if (ownerUserId.isEmpty) return 0;
    final q = _db.selectOnly(_db.cachedMyListRecordings)
      ..addColumns([_db.cachedMyListRecordings.recordingId.count()])
      ..where(_db.cachedMyListRecordings.ownerUserId.equals(ownerUserId));
    final r = await q.getSingle();
    return r.read(_db.cachedMyListRecordings.recordingId.count()) ?? 0;
  }
}
