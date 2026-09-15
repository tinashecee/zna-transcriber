import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../app/config.dart';
import '../data/local/offline_users_database.dart';
import '../utils/audio_uri.dart';

/// Called with [received] and [total] bytes during a download ([total] may be -1).
typedef DownloadProgressCallback = void Function(int received, int total);

class OfflineAudioDownloadService {
  OfflineAudioDownloadService({
    required this.dio,
    required this.db,
    required this.config,
    required Logger logger,
  }) : _logger = logger;

  final Dio dio;
  final OfflineUsersDatabase db;
  final AppConfig config;
  final Logger _logger;

  final _queue = <_DownloadJob>[];
  bool _running = false;

  Future<void> prefetchForMyList({
    required String ownerUserId,
    required List<Map<String, dynamic>> myListItems,
  }) async {
    if (ownerUserId.isEmpty || myListItems.isEmpty) return;
    for (final item in myListItems) {
      final id = item['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      final audioPath = (item['audio_url'] ?? item['file_path'] ?? item['audio_path'])
              ?.toString() ??
          '';
      if (audioPath.trim().isEmpty) continue;
      await _ensureQueued(ownerUserId: ownerUserId, recordingId: id, audioPath: audioPath);
    }
    _pump();
  }

  Future<void> downloadNow({
    required String ownerUserId,
    required String recordingId,
    required String audioPath,
  }) async {
    await _ensureQueued(ownerUserId: ownerUserId, recordingId: recordingId, audioPath: audioPath);
    _pump();
  }

  /// Downloads a recording to disk for local processing, reporting byte progress.
  /// Returns the local file path. Skips the background queue so progress is accurate.
  Future<String> downloadForProcessing({
    required String ownerUserId,
    required String recordingId,
    required String audioPath,
    DownloadProgressCallback? onProgress,
  }) async {
    final existing = await row(
      ownerUserId: ownerUserId,
      recordingId: recordingId,
    );
    final existingPath = existing?.localPath;
    if (existingPath != null &&
        existingPath.isNotEmpty &&
        File(existingPath).existsSync()) {
      onProgress?.call(1, 1);
      return existingPath;
    }

    final uri = buildRecordingAudioUri(
      baseUrl: config.audioBaseUrl,
      audioPath: audioPath,
      logger: _logger,
    );
    if (uri == null) {
      throw Exception('Audio URL is empty');
    }

    final ext = _guessExtension(uri);
    final dir = await getApplicationSupportDirectory();
    final folder = Directory(
      '${dir.path}${Platform.pathSeparator}offline_audio'
      '${Platform.pathSeparator}$ownerUserId',
    );
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    final filePath =
        '${folder.path}${Platform.pathSeparator}$recordingId.$ext';
    final file = File(filePath);

    await db.into(db.cachedRecordingAudios).insert(
          CachedRecordingAudiosCompanion.insert(
            ownerUserId: ownerUserId,
            recordingId: recordingId,
            audioPath: audioPath,
            status: 'downloading',
          ),
          mode: InsertMode.insertOrReplace,
        );

    try {
      _logger.info(
        '[OfflineAudio] downloadForProcessing id=$recordingId uri=$uri',
      );
      await dio.downloadUri(
        uri,
        file.path,
        onReceiveProgress: (received, total) {
          onProgress?.call(received, total);
        },
      );
      final size = await file.length();
      await db.into(db.cachedRecordingAudios).insert(
            CachedRecordingAudiosCompanion.insert(
              ownerUserId: ownerUserId,
              recordingId: recordingId,
              audioPath: audioPath,
              status: 'downloaded',
              localPath: Value(file.path),
              bytes: Value(size),
              downloadedAtMillis: Value(DateTime.now().millisecondsSinceEpoch),
              error: const Value.absent(),
            ),
            mode: InsertMode.insertOrReplace,
          );
      _logger.info(
        '[OfflineAudio] downloadForProcessing ok id=$recordingId bytes=$size',
      );
      return file.path;
    } catch (e) {
      final msg = e.toString();
      await _markFailed(
        _DownloadJob(ownerUserId, recordingId, audioPath),
        msg,
      );
      rethrow;
    }
  }

  Future<CachedRecordingAudioRow?> row({
    required String ownerUserId,
    required String recordingId,
  }) {
    return (db.select(db.cachedRecordingAudios)
          ..where((t) =>
              t.ownerUserId.equals(ownerUserId) &
              t.recordingId.equals(recordingId)))
        .getSingleOrNull();
  }

  Future<void> _ensureQueued({
    required String ownerUserId,
    required String recordingId,
    required String audioPath,
  }) async {
    final existing = await row(ownerUserId: ownerUserId, recordingId: recordingId);
    if (existing != null && existing.status == 'downloaded') return;
    await db.into(db.cachedRecordingAudios).insert(
          CachedRecordingAudiosCompanion.insert(
            ownerUserId: ownerUserId,
            recordingId: recordingId,
            audioPath: audioPath,
            status: existing?.status == 'downloading' ? 'downloading' : 'queued',
          ),
          mode: InsertMode.insertOrReplace,
        );
    if (existing?.status == 'downloading') return;
    _queue.add(_DownloadJob(ownerUserId, recordingId, audioPath));
  }

  void _pump() {
    if (_running) return;
    _running = true;
    unawaited(_runLoop());
  }

  Future<void> _runLoop() async {
    try {
      while (_queue.isNotEmpty) {
        final job = _queue.removeAt(0);
        await _download(job);
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _download(_DownloadJob job) async {
    final uri = buildRecordingAudioUri(
      baseUrl: config.audioBaseUrl,
      audioPath: job.audioPath,
      logger: _logger,
    );
    if (uri == null) {
      await _markFailed(job, 'empty audio url');
      return;
    }

    final ext = _guessExtension(uri);
    final dir = await getApplicationSupportDirectory();
    final folder = Directory(
      '${dir.path}${Platform.pathSeparator}offline_audio'
      '${Platform.pathSeparator}${job.ownerUserId}',
    );
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    final filePath =
        '${folder.path}${Platform.pathSeparator}${job.recordingId}.$ext';
    final file = File(filePath);

    await db.into(db.cachedRecordingAudios).insert(
          CachedRecordingAudiosCompanion.insert(
            ownerUserId: job.ownerUserId,
            recordingId: job.recordingId,
            audioPath: job.audioPath,
            status: 'downloading',
          ),
          mode: InsertMode.insertOrReplace,
        );

    try {
      _logger.info('[OfflineAudio] download start id=${job.recordingId} uri=$uri');
      await dio.downloadUri(uri, file.path);
      final size = await file.length();
      await db.into(db.cachedRecordingAudios).insert(
            CachedRecordingAudiosCompanion.insert(
              ownerUserId: job.ownerUserId,
              recordingId: job.recordingId,
              audioPath: job.audioPath,
              status: 'downloaded',
            localPath: Value(file.path),
            bytes: Value(size),
            downloadedAtMillis: Value(DateTime.now().millisecondsSinceEpoch),
              error: const Value.absent(),
            ),
            mode: InsertMode.insertOrReplace,
          );
      _logger.info('[OfflineAudio] download ok id=${job.recordingId} bytes=$size');
    } catch (e) {
      final msg = e.toString();
      await _markFailed(job, msg);
    }
  }

  Future<void> _markFailed(_DownloadJob job, String msg) async {
    _logger.warning('[OfflineAudio] download failed id=${job.recordingId} err=$msg');
    await db.into(db.cachedRecordingAudios).insert(
          CachedRecordingAudiosCompanion.insert(
            ownerUserId: job.ownerUserId,
            recordingId: job.recordingId,
            audioPath: job.audioPath,
            status: 'failed',
            error: Value(msg.length > 300 ? msg.substring(0, 300) : msg),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  String _guessExtension(Uri uri) {
    if (uri.pathSegments.isEmpty) return 'wav';
    final name = uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    if (dot < 0) return 'wav';
    final ext = name.substring(dot + 1).toLowerCase();
    if (ext.isEmpty) return 'wav';
    if (ext.length > 6) return 'wav';
    return ext;
  }
}

class _DownloadJob {
  _DownloadJob(this.ownerUserId, this.recordingId, this.audioPath);
  final String ownerUserId;
  final String recordingId;
  final String audioPath;
}

