import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../presentation/auth/auth_controller.dart';
import '../services/auth_session.dart';
import '../services/word_export_service.dart';
import '../services/word_import_service.dart';
import '../services/recording_upload_service.dart';
import '../services/audio_enhancement_service.dart';
import 'api/api_client.dart';
import 'local/offline_users_database.dart';
import 'repositories/offline_user_sync_repository.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/assignment_repository_impl.dart';
import 'repositories/comment_repository_impl.dart';
import 'repositories/recording_repository_impl.dart';
import 'repositories/recordings_cache_repository.dart';
import 'repositories/status_repository_impl.dart';
import 'repositories/transcript_repository_impl.dart';
import 'repositories/transcript_cache_repository.dart';
import 'storage/secure_storage.dart';
import 'storage/api_key_storage.dart';
import '../services/update_service.dart';
import '../services/offline_audio_download_service.dart';

final userStorageProvider = Provider<UserStorage>((ref) {
  return UserStorage();
});

final apiKeyStorageProvider = Provider<ApiKeyStorage>((ref) {
  return ApiKeyStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(
    config: config,
    // Always read the latest session — do not close over a stale snapshot.
    tokenProvider: () async => ref.read(authSessionProvider).token,
    apiKeyProvider: () async => ref.read(authSessionProvider).apiKey,
    onUnauthorized: (error) async {
      // A 401 from a non-auth endpoint means the JWT has either expired or
      // been revoked server-side. Tear down the session and let the router
      // redirect to settings / login. (Skipped for X-API-Key in ApiClient.)
      try {
        await ref.read(authControllerProvider).handleSessionExpired();
      } catch (e) {
        print('[apiClientProvider] onUnauthorized failed: $e');
      }
    },
  );
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(ref.watch(apiClientProvider));
});

final recordingsCacheRepositoryProvider = Provider<RecordingsCacheRepository>((ref) {
  return RecordingsCacheRepository(ref.watch(offlineUsersDatabaseProvider));
});

final offlineAudioDownloadServiceProvider =
    Provider<OfflineAudioDownloadService>((ref) {
  final logger = ref.watch(loggingServiceProvider).logger;
  return OfflineAudioDownloadService(
    dio: ref.watch(apiClientProvider).dio,
    db: ref.watch(offlineUsersDatabaseProvider),
    config: ref.watch(appConfigProvider),
    logger: logger,
  );
});

final recordingRepositoryProvider = Provider<RecordingRepositoryImpl>((ref) {
  return RecordingRepositoryImpl(
    ref.watch(apiClientProvider),
    ref.watch(recordingsCacheRepositoryProvider),
    ref.watch(offlineAudioDownloadServiceProvider),
  );
});

final assignmentRepositoryProvider = Provider<AssignmentRepositoryImpl>((ref) {
  return AssignmentRepositoryImpl(ref.watch(apiClientProvider));
});

final commentRepositoryProvider = Provider<CommentRepositoryImpl>((ref) {
  return CommentRepositoryImpl(ref.watch(apiClientProvider));
});

final statusRepositoryProvider = Provider<StatusRepositoryImpl>((ref) {
  return StatusRepositoryImpl(ref.watch(apiClientProvider));
});

final transcriptRepositoryProvider = Provider<TranscriptRepositoryImpl>((ref) {
  return TranscriptRepositoryImpl(ref.watch(apiClientProvider));
});

final transcriptCacheRepositoryProvider = Provider<TranscriptCacheRepository>((ref) {
  return TranscriptCacheRepository(ref.watch(offlineUsersDatabaseProvider));
});

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService(ref.watch(apiClientProvider));
});

final wordExportServiceProvider = Provider<WordExportService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WordExportService(
    dio: apiClient.dio,
  );
});

final wordImportServiceProvider = Provider<WordImportService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WordImportService(
    dio: apiClient.dio,
  );
});

final recordingUploadServiceProvider = Provider<RecordingUploadService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RecordingUploadService(dio: apiClient.dio);
});

final audioEnhancementServiceProvider =
    Provider<AudioEnhancementService>((ref) {
  return AudioEnhancementService(
    logger: ref.watch(loggingServiceProvider).logger,
  );
});

/// Local Drift DB for offline roster + bcrypt hashes (sensitive at rest).
final offlineUsersDatabaseProvider = Provider<OfflineUsersDatabase>((ref) {
  final db = OfflineUsersDatabase.open();
  ref.onDispose(db.close);
  return db;
});

/// Syncs users from config [AppConfig.offlineUsersSyncPath] after online login.
final offlineUserSyncRepositoryProvider = Provider<OfflineUserSyncRepository>((ref) {
  final path = ref.watch(appConfigProvider).offlineUsersSyncPath;
  return OfflineUserSyncRepository(
    ref.watch(apiClientProvider),
    ref.watch(offlineUsersDatabaseProvider),
    syncPath: path,
  );
});

/// One-shot message after online login if roster sync failed (no secrets).
final offlineSyncWarningProvider = StateProvider<String?>((ref) => null);

/// API reachability status by pinging GET /courts.
enum ApiStatus { checking, online, offline }

/// Interval for re-checking reachability (login chip + diagnostics).
const Duration apiStatusPollInterval = Duration(seconds: 20);

bool _dioMeansOffline(DioException e) {
  if (e.response != null) {
    return false;
  }
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    default:
      break;
  }
  final err = e.error;
  if (err is SocketException) return true;
  if (err is HttpException) return true;
  if (e.type == DioExceptionType.unknown && e.response == null) {
    return true;
  }
  return false;
}

class ApiStatusNotifier extends StateNotifier<ApiStatus> {
  ApiStatusNotifier(this._ref) : super(ApiStatus.checking) {
    check(showChecking: true);
    _pollTimer = Timer.periodic(apiStatusPollInterval, (_) {
      check(showChecking: false);
    });
  }

  final Ref _ref;
  Timer? _pollTimer;

  void disposePoll() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// [showChecking] avoids flicker on periodic polls.
  Future<void> check({bool showChecking = false}) async {
    if (showChecking) {
      state = ApiStatus.checking;
    }
    try {
      final dio = _ref.read(apiClientProvider).dio;
      await dio.get<dynamic>('/courts');
      state = ApiStatus.online;
    } on DioException catch (e) {
      if (e.response != null) {
        state = ApiStatus.online;
        return;
      }
      if (_dioMeansOffline(e)) {
        state = ApiStatus.offline;
      } else {
        state = ApiStatus.online;
      }
    } catch (_) {
      state = ApiStatus.offline;
    }
  }
}

final apiStatusProvider =
    StateNotifierProvider<ApiStatusNotifier, ApiStatus>((ref) {
  final notifier = ApiStatusNotifier(ref);
  ref.onDispose(notifier.disposePoll);
  return notifier;
});
