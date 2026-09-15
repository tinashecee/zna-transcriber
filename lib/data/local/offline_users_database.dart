import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'offline_users_database.g.dart';

/// JSON snapshot per recording from My List API (`/user/recordings/latest_paginated`).
@DataClassName('CachedMyListRecordingRow')
class CachedMyListRecordings extends Table {
  TextColumn get ownerUserId => text()();
  TextColumn get recordingId => text()();
  TextColumn get payloadJson => text()();
  /// From API `date_stamp` / `date` for ordering and prune.
  IntColumn get listDateMillis => integer()();
  IntColumn get syncedAtMillis => integer()();

  @override
  Set<Column> get primaryKey => {ownerUserId, recordingId};
}

@DataClassName('CachedRecordingAudioRow')
class CachedRecordingAudios extends Table {
  TextColumn get ownerUserId => text()();
  TextColumn get recordingId => text()();
  TextColumn get audioPath => text()();
  TextColumn get localPath => text().nullable()();
  /// queued|downloading|downloaded|failed
  TextColumn get status => text()();
  IntColumn get bytes => integer().nullable()();
  IntColumn get downloadedAtMillis => integer().nullable()();
  TextColumn get error => text().nullable()();

  @override
  Set<Column> get primaryKey => {ownerUserId, recordingId};
}

@DataClassName('CachedRecordingTranscriptRow')
class CachedRecordingTranscripts extends Table {
  TextColumn get ownerUserId => text()();
  TextColumn get recordingId => text()();
  TextColumn get html => text()();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column> get primaryKey => {ownerUserId, recordingId};
}

@DataClassName('CachedUserRow')
class CachedUsers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  /// Normalized email (trim + lowercase) for lookups; unique.
  TextColumn get emailNormalized => text().unique()();
  TextColumn get role => text()();
  TextColumn get court => text().nullable()();
  TextColumn get contactInfo => text().nullable()();
  TextColumn get province => text().nullable()();
  TextColumn get region => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get dateCreated => text().nullable()();
  /// Bcrypt modular crypt string from server — never log this field.
  TextColumn get passwordHash => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  CachedUsers,
  CachedMyListRecordings,
  CachedRecordingAudios,
  CachedRecordingTranscripts,
])
class OfflineUsersDatabase extends _$OfflineUsersDatabase {
  OfflineUsersDatabase(QueryExecutor executor) : super(executor);

  factory OfflineUsersDatabase.open() {
    return OfflineUsersDatabase(
      driftDatabase(
        name: 'offline_users_cache',
        native: DriftNativeOptions(
          databaseDirectory: getApplicationSupportDirectory,
        ),
      ),
    );
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(cachedMyListRecordings);
          }
          if (from < 3) {
            await m.createTable(cachedRecordingAudios);
          }
          if (from < 4) {
            await m.createTable(cachedRecordingTranscripts);
          }
        },
      );

  Future<CachedUserRow?> rowByNormalizedEmail(String emailNormalized) {
    return (select(cachedUsers)
          ..where((t) => t.emailNormalized.equals(emailNormalized)))
        .getSingleOrNull();
  }

  /// Atomically replace the full cache (avoids partial-empty state on failure).
  Future<void> replaceAllUsers(List<CachedUsersCompanion> rows) async {
    await transaction(() async {
      await delete(cachedUsers).go();
      for (final row in rows) {
        await into(cachedUsers).insert(row);
      }
    });
  }

  /// Upsert one user (e.g. current session after online login).
  Future<void> upsertCachedUser(CachedUsersCompanion row) async {
    await into(cachedUsers).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> clearAllUsers() => delete(cachedUsers).go();

  Future<int> countUsers() async {
    final q = selectOnly(cachedUsers)..addColumns([cachedUsers.id.count()]);
    final r = await q.getSingle();
    return r.read(cachedUsers.id.count()) ?? 0;
  }
}
