import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';

import '../../app/providers.dart';
import '../../services/auth_session.dart';
import '../../utils/audio_uri.dart';

class AudioPlayerState {
  const AudioPlayerState({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.speed,
  });

  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double speed;

  AudioPlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? speed,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
    );
  }

  static const initial = AudioPlayerState(
    isPlaying: false,
    position: Duration.zero,
    duration: Duration.zero,
    speed: 1.0,
  );
}

class AudioPlayerController extends StateNotifier<AudioPlayerState> {
  AudioPlayerController(this._ref) : super(AudioPlayerState.initial) {
  }

  final Ref _ref;
  late final Logger _logger = _ref.read(loggingServiceProvider).logger;
  AudioPlayer? _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<ProcessingState>? _processingStateSub;
  bool _isAvailable = true;
  int _loadAttempt = 0;

  AudioPlayer? _ensurePlayer() {
    if (!_isAvailable) return null;
    if (_player != null) return _player;
    try {
      final player = AudioPlayer();
      _player = player;
      _positionSub = player.positionStream.listen((pos) {
        state = state.copyWith(position: pos);
      });
      _durationSub = player.durationStream.listen((dur) {
        state = state.copyWith(duration: dur ?? Duration.zero);
      });
      _playerStateSub = player.playerStateStream.listen((playerState) {
        state = state.copyWith(isPlaying: playerState.playing);
      });
      _processingStateSub =
          player.processingStateStream.listen((processingState) {
        _logger.info('[AudioPlayer] processingState=$processingState');
      });
      return player;
    } on MissingPluginException {
      _isAvailable = false;
      return null;
    }
  }

  Future<void> loadRecording(String audioPath) async {
    if (!_isAvailable) return;
    final attempt = ++_loadAttempt;
    AudioPlayer? player;
    Map<String, String>? authHeaders;
    try {
      player = _ensurePlayer();
      if (player == null) return;
      await player.stop();
      final config = _ref.read(appConfigProvider);
      final session = _ref.read(authSessionProvider);
      authHeaders = session.httpAuthHeaders;
      _logger.info(
        '[AudioPlayer] loadRecording audioPath="$audioPath" '
        'baseUrl="${config.audioBaseUrl}" auth=${authHeaders != null}',
      );
      final uri = buildRecordingAudioUri(
        baseUrl: config.audioBaseUrl,
        audioPath: audioPath,
        logger: _logger,
      );
      if (uri == null) {
        _logger.warning('[AudioPlayer] Empty audio path for recording');
        return;
      }
      _logger.info('[AudioPlayer] ═══════════════════════════════════════');
      _logger.info('[AudioPlayer] FINAL STREAM ENDPOINT: $uri');
      _logger.info(
        '[AudioPlayer] Headers: ${authHeaders == null ? 'none' : authHeaders.keys.join(', ')}',
      );
      _logger.info('[AudioPlayer] ═══════════════════════════════════════');
      await _probeAudio(uri, authHeaders);
      _logger.info('[AudioPlayer] Calling player.setAudioSource with URI: $uri');
      await player.setAudioSource(
        AudioSource.uri(
          uri,
          headers: authHeaders,
        ),
      );
      _logger.info('[AudioPlayer] Successfully loaded audio source');
    } on MissingPluginException catch (error, stack) {
      _logger.severe('[AudioPlayer] MissingPluginException', error, stack);
      _isAvailable = false;
    } catch (error, stack) {
      _logger.severe('[AudioPlayer] Failed to load audio source', error, stack);
      final fallbackUri = buildMp3FallbackUri(
        baseUrl: _ref.read(appConfigProvider).audioBaseUrl,
        audioPath: audioPath,
        logger: _logger,
      );
      if (fallbackUri != null && attempt == _loadAttempt && player != null) {
        _logger.warning('[AudioPlayer] ═══════════════════════════════════════');
        _logger.warning('[AudioPlayer] PRIMARY LOAD FAILED - TRYING MP3 FALLBACK');
        _logger.warning('[AudioPlayer] FALLBACK STREAM ENDPOINT: $fallbackUri');
        _logger.warning(
          '[AudioPlayer] Headers: ${authHeaders == null ? 'none' : authHeaders.keys.join(', ')}',
        );
        _logger.warning('[AudioPlayer] ═══════════════════════════════════════');
        await _probeAudio(fallbackUri, authHeaders);
        try {
          _logger.info('[AudioPlayer] Calling player.setAudioSource with fallback URI: $fallbackUri');
          await player.setAudioSource(
            AudioSource.uri(
              fallbackUri,
              headers: authHeaders,
            ),
          );
          _logger.info('[AudioPlayer] Successfully loaded fallback MP3 audio source');
        } catch (fallbackError, fallbackStack) {
          _logger.severe(
            '[AudioPlayer] MP3 fallback failed',
            fallbackError,
            fallbackStack,
          );
        }
      }
    }
  }

  Future<void> loadLocalFile(String path) async {
    if (!_isAvailable) return;
    final attempt = ++_loadAttempt;
    try {
      final player = _ensurePlayer();
      if (player == null) return;
      await player.stop();
      _logger.info('[AudioPlayer] loadLocalFile path="$path"');
      if (attempt != _loadAttempt) return;
      await player.setAudioSource(AudioSource.file(path));
      _logger.info('[AudioPlayer] Successfully loaded local audio file');
    } on MissingPluginException catch (_) {
      _isAvailable = false;
    } catch (e, st) {
      _logger.severe('[AudioPlayer] Failed to load local file', e, st);
    }
  }

  /// Swaps the active source to a local [path] (e.g. an enhanced copy or the
  /// original) while preserving the current playback [position], [speed] and,
  /// when [resume] is true, the playing state.
  Future<void> swapSource(
    String path, {
    required Duration position,
    required bool resume,
  }) async {
    if (!_isAvailable) return;
    final attempt = ++_loadAttempt;
    try {
      final player = _ensurePlayer();
      if (player == null) return;
      final speed = state.speed;
      await player.stop();
      if (attempt != _loadAttempt) return;
      _logger.info('[AudioPlayer] swapSource path="$path" pos=$position');
      await player.setAudioSource(AudioSource.file(path));
      if (attempt != _loadAttempt) return;
      if (speed != 1.0) {
        await player.setSpeed(speed);
      }
      if (position > Duration.zero) {
        await player.seek(position);
      }
      if (resume) {
        await player.play();
      }
    } on MissingPluginException catch (_) {
      _isAvailable = false;
    } catch (e, st) {
      _logger.severe('[AudioPlayer] Failed to swap source', e, st);
    }
  }

  Future<void> playPause() async {
    if (!_isAvailable) return;
    try {
      final player = _ensurePlayer();
      if (player == null) return;
      if (player.playing) {
        await player.pause();
      } else {
        await player.play();
      }
    } on MissingPluginException catch (_) {
      _isAvailable = false;
    }
  }

  Future<void> rewind({int seconds = 5}) async {
    if (!_isAvailable) return;
    try {
      final player = _ensurePlayer();
      if (player == null) return;
      final target = state.position - Duration(seconds: seconds);
      await player.seek(target < Duration.zero ? Duration.zero : target);
    } on MissingPluginException catch (_) {
      _isAvailable = false;
    }
  }

  Future<void> forward({int seconds = 5}) async {
    if (!_isAvailable) return;
    try {
      final player = _ensurePlayer();
      if (player == null) return;
      final target = state.position + Duration(seconds: seconds);
      await player.seek(target);
    } on MissingPluginException catch (_) {
      _isAvailable = false;
    }
  }

  Future<void> setSpeed(double speed) async {
    if (!_isAvailable) return;
    try {
      final player = _ensurePlayer();
      if (player == null) return;
      await player.setSpeed(speed);
      state = state.copyWith(speed: speed);
    } on MissingPluginException catch (_) {
      _isAvailable = false;
    }
  }

  Future<void> seek(Duration position) async {
    if (!_isAvailable) return;
    try {
      final player = _ensurePlayer();
      if (player == null) return;
      await player.seek(position);
    } on MissingPluginException catch (_) {
      _isAvailable = false;
    }
  }

  Future<void> pressPlay() async {
    if (!_isAvailable) return;
    try {
      final player = _ensurePlayer();
      if (player == null) return;
      if (!player.playing) {
        await player.play();
      }
    } on MissingPluginException catch (_) {
      _isAvailable = false;
    }
  }

  Future<void> releasePlay() async {
    if (!_isAvailable) return;
    try {
      final player = _ensurePlayer();
      if (player == null) return;
      if (player.playing) {
        await player.pause();
      }
    } on MissingPluginException catch (_) {
      _isAvailable = false;
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _processingStateSub?.cancel();
    if (_isAvailable) {
      try {
        _player?.dispose();
      } on MissingPluginException catch (_) {
        _isAvailable = false;
      }
    }
    super.dispose();
  }

  Future<void> _probeAudio(Uri uri, Map<String, String>? authHeaders) async {
    try {
      _logger.info('[AudioPlayer] Probing audio at: $uri');
      final dio = Dio(
        BaseOptions(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final headers = <String, dynamic>{
        'Range': 'bytes=0-1',
        if (authHeaders != null) ...authHeaders,
      };
      final response = await dio.getUri(uri, options: Options(headers: headers));
      _logger.info(
        '[AudioPlayer] Probe response: status=${response.statusCode} '
        'contentType=${response.headers.value('content-type')} '
        'contentLength=${response.headers.value('content-length')} '
        'acceptRanges=${response.headers.value('accept-ranges')}',
      );
    } catch (error, stack) {
      _logger.warning('[AudioPlayer] Probe failed for $uri', error, stack);
    }
  }
}

final audioPlayerControllerProvider =
    StateNotifierProvider<AudioPlayerController, AudioPlayerState>((ref) {
  return AudioPlayerController(ref);
});
