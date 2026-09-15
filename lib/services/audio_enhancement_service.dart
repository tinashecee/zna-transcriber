import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

/// Predefined audio cleanup profiles. [custom] uses whatever the user has dialed
/// in on the sliders.
enum EnhancementPreset { light, standard, strong, voiceIsolation, custom }

/// Parameters for the FFmpeg filter chain used to clean up a recording.
class EnhancementSettings {
  const EnhancementSettings({
    required this.preset,
    required this.noiseReductionDb,
    required this.lowCutHz,
    required this.highCutHz,
  });

  /// Selected preset (or [EnhancementPreset.custom]).
  final EnhancementPreset preset;

  /// afftdn noise reduction strength in dB (0-30).
  final double noiseReductionDb;

  /// highpass cutoff in Hz - frequencies below this are clipped (50-500).
  final double lowCutHz;

  /// lowpass cutoff in Hz - frequencies above this are clipped (2000-12000).
  final double highCutHz;

  static const EnhancementSettings light = EnhancementSettings(
    preset: EnhancementPreset.light,
    noiseReductionDb: 6,
    lowCutHz: 120,
    highCutHz: 12000,
  );

  static const EnhancementSettings standard = EnhancementSettings(
    preset: EnhancementPreset.standard,
    noiseReductionDb: 12,
    lowCutHz: 150,
    highCutHz: 8000,
  );

  static const EnhancementSettings strong = EnhancementSettings(
    preset: EnhancementPreset.strong,
    noiseReductionDb: 20,
    lowCutHz: 200,
    highCutHz: 6000,
  );

  static const EnhancementSettings voiceIsolation = EnhancementSettings(
    preset: EnhancementPreset.voiceIsolation,
    noiseReductionDb: 24,
    lowCutHz: 200,
    highCutHz: 3400,
  );

  /// Returns the default settings bundle for [preset].
  static EnhancementSettings forPreset(EnhancementPreset preset) {
    switch (preset) {
      case EnhancementPreset.light:
        return light;
      case EnhancementPreset.standard:
        return standard;
      case EnhancementPreset.strong:
        return strong;
      case EnhancementPreset.voiceIsolation:
        return voiceIsolation;
      case EnhancementPreset.custom:
        return standard.copyWith(preset: EnhancementPreset.custom);
    }
  }

  EnhancementSettings copyWith({
    EnhancementPreset? preset,
    double? noiseReductionDb,
    double? lowCutHz,
    double? highCutHz,
  }) {
    return EnhancementSettings(
      preset: preset ?? this.preset,
      noiseReductionDb: noiseReductionDb ?? this.noiseReductionDb,
      lowCutHz: lowCutHz ?? this.lowCutHz,
      highCutHz: highCutHz ?? this.highCutHz,
    );
  }

  /// FFmpeg `-af` filter chain for these settings.
  String buildFilterChain() {
    final nr = noiseReductionDb.clamp(0, 97).toStringAsFixed(0);
    final low = lowCutHz.clamp(20, 2000).toStringAsFixed(0);
    final high = highCutHz.clamp(1000, 20000).toStringAsFixed(0);
    return 'afftdn=nr=$nr,highpass=f=$low,lowpass=f=$high';
  }

  /// Stable cache token (changes whenever the audible result would change).
  String get cacheToken =>
      '${noiseReductionDb.toStringAsFixed(1)}_'
      '${lowCutHz.toStringAsFixed(0)}_'
      '${highCutHz.toStringAsFixed(0)}';
}

/// Thrown when FFmpeg cannot be located on the system.
class FfmpegUnavailableException implements Exception {
  FfmpegUnavailableException(this.message);
  final String message;
  @override
  String toString() => 'FfmpegUnavailableException: $message';
}

/// Runs FFmpeg to produce a cleaned copy of a recording for playback.
///
/// `just_audio` cannot apply live filters, so we process the source file into a
/// temp WAV and let the player swap it in. Results are cached on disk by the
/// input path + settings so repeated toggles are instant.
class AudioEnhancementService {
  AudioEnhancementService({required Logger logger}) : _logger = logger;

  final Logger _logger;
  String? _resolvedFfmpegPath;
  Future<String?>? _resolving;

  static const String _assetKey = 'assets/ffmpeg/ffmpeg.exe';

  /// Resolves the FFmpeg executable, caching the result. Returns null when no
  /// usable binary can be found.
  Future<String?> resolveFfmpeg() {
    if (_resolvedFfmpegPath != null) return Future.value(_resolvedFfmpegPath);
    return _resolving ??= _resolveFfmpegInternal();
  }

  Future<String?> _resolveFfmpegInternal() async {
    try {
      // 1) Bundled asset sitting next to the executable (release builds).
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      final beside = File(
        '$exeDir${Platform.pathSeparator}data${Platform.pathSeparator}'
        'flutter_assets${Platform.pathSeparator}assets${Platform.pathSeparator}'
        'ffmpeg${Platform.pathSeparator}ffmpeg.exe',
      );
      if (beside.existsSync() && beside.lengthSync() > 0) {
        _logger.info('[Enhance] Using bundled ffmpeg at ${beside.path}');
        return _resolvedFfmpegPath = beside.path;
      }

      // 2) Extract the asset to app support and run from there.
      final extracted = await _extractBundledFfmpeg();
      if (extracted != null) {
        _logger.info('[Enhance] Using extracted ffmpeg at $extracted');
        return _resolvedFfmpegPath = extracted;
      }

      // 3) Fall back to ffmpeg on PATH.
      final onPath = await _ffmpegOnPath();
      if (onPath != null) {
        _logger.info('[Enhance] Using ffmpeg from PATH');
        return _resolvedFfmpegPath = onPath;
      }
    } catch (e, st) {
      _logger.warning('[Enhance] Failed to resolve ffmpeg', e, st);
    } finally {
      _resolving = null;
    }
    return null;
  }

  Future<String?> _extractBundledFfmpeg() async {
    try {
      final data = await rootBundle.load(_assetKey);
      if (data.lengthInBytes <= 0) return null;
      final dir = await getApplicationSupportDirectory();
      final binDir = Directory('${dir.path}${Platform.pathSeparator}bin');
      if (!binDir.existsSync()) binDir.createSync(recursive: true);
      final out = File('${binDir.path}${Platform.pathSeparator}ffmpeg.exe');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      // Re-extract only when the size differs (cheap freshness check).
      if (!out.existsSync() || out.lengthSync() != bytes.length) {
        await out.writeAsBytes(bytes, flush: true);
      }
      return out.path;
    } catch (e) {
      // Asset not bundled (placeholder only) - silently skip.
      _logger.info('[Enhance] No bundled ffmpeg asset: $e');
      return null;
    }
  }

  Future<String?> _ffmpegOnPath() async {
    try {
      final result = await Process.run(
        Platform.isWindows ? 'where' : 'which',
        ['ffmpeg'],
      );
      if (result.exitCode == 0) {
        final out = (result.stdout as String).trim();
        if (out.isNotEmpty) {
          return out.split(RegExp(r'[\r\n]+')).first.trim();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Processes [inputPath] with [settings] and returns the cleaned WAV path.
  /// Throws [FfmpegUnavailableException] when no FFmpeg binary is available.
  Future<String> process({
    required String inputPath,
    required EnhancementSettings settings,
  }) async {
    final ffmpeg = await resolveFfmpeg();
    if (ffmpeg == null) {
      throw FfmpegUnavailableException(
        'FFmpeg was not found. Add ffmpeg.exe to assets/ffmpeg/ or install it '
        'on the system PATH.',
      );
    }

    final dir = await getApplicationSupportDirectory();
    final outDir = Directory(
      '${dir.path}${Platform.pathSeparator}enhanced_audio',
    );
    if (!outDir.existsSync()) outDir.createSync(recursive: true);

    final key = _hash('$inputPath|${settings.cacheToken}');
    final outPath = '${outDir.path}${Platform.pathSeparator}$key.wav';
    final outFile = File(outPath);
    if (outFile.existsSync() && outFile.lengthSync() > 0) {
      _logger.info('[Enhance] Cache hit -> $outPath');
      return outPath;
    }

    final filter = settings.buildFilterChain();
    final args = [
      '-y',
      '-i', inputPath,
      '-af', filter,
      '-ar', '44100',
      outPath,
    ];
    _logger.info('[Enhance] Running ffmpeg -af "$filter"');
    final result = await Process.run(ffmpeg, args);
    if (result.exitCode != 0 || !outFile.existsSync()) {
      final stderr = (result.stderr ?? '').toString();
      final tail = stderr.length > 500
          ? stderr.substring(stderr.length - 500)
          : stderr;
      _logger.warning('[Enhance] ffmpeg failed (${result.exitCode}): $tail');
      if (outFile.existsSync()) {
        try {
          outFile.deleteSync();
        } catch (_) {}
      }
      throw Exception('Audio processing failed (ffmpeg exit ${result.exitCode}).');
    }
    _logger.info('[Enhance] Produced $outPath');
    return outPath;
  }

  /// Removes all cached enhanced audio files.
  Future<void> clearCache() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final outDir = Directory(
        '${dir.path}${Platform.pathSeparator}enhanced_audio',
      );
      if (outDir.existsSync()) {
        await outDir.delete(recursive: true);
      }
    } catch (e) {
      _logger.info('[Enhance] clearCache skipped: $e');
    }
  }

  /// FNV-1a 32-bit hash, rendered as hex. Stable across runs (unlike
  /// String.hashCode) so the on-disk cache survives restarts.
  String _hash(String input) {
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
