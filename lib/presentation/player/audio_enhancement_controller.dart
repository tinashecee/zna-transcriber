import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../services/audio_enhancement_service.dart';
import 'audio_player_controller.dart';

export '../../services/audio_enhancement_service.dart'
    show EnhancementPreset, EnhancementSettings;

/// UI + orchestration state for the denoise / voice-isolation feature.
class EnhancementState {
  const EnhancementState({
    required this.enabled,
    required this.settings,
    required this.isProcessing,
    required this.ffmpegAvailable,
    this.originalPath,
    this.error,
  });

  /// Whether cleanup is currently applied (or being applied).
  final bool enabled;

  /// Current filter settings (driven by preset or custom sliders).
  final EnhancementSettings settings;

  /// True while FFmpeg is running.
  final bool isProcessing;

  /// null = not yet checked, true/false once resolved.
  final bool? ffmpegAvailable;

  /// The original (unprocessed) local file currently loaded, if any.
  final String? originalPath;

  /// Last error message, if any.
  final String? error;

  bool get hasLocalSource => originalPath != null && originalPath!.isNotEmpty;

  EnhancementState copyWith({
    bool? enabled,
    EnhancementSettings? settings,
    bool? isProcessing,
    bool? ffmpegAvailable,
    String? originalPath,
    bool clearOriginalPath = false,
    String? error,
    bool clearError = false,
  }) {
    return EnhancementState(
      enabled: enabled ?? this.enabled,
      settings: settings ?? this.settings,
      isProcessing: isProcessing ?? this.isProcessing,
      ffmpegAvailable: ffmpegAvailable ?? this.ffmpegAvailable,
      originalPath:
          clearOriginalPath ? null : (originalPath ?? this.originalPath),
      error: clearError ? null : (error ?? this.error),
    );
  }

  static const initial = EnhancementState(
    enabled: false,
    settings: EnhancementSettings.standard,
    isProcessing: false,
    ffmpegAvailable: null,
  );
}

class AudioEnhancementController extends StateNotifier<EnhancementState> {
  AudioEnhancementController(this._ref) : super(EnhancementState.initial);

  final Ref _ref;

  AudioEnhancementService get _service =>
      _ref.read(audioEnhancementServiceProvider);

  /// Registers the local source for the current recording and resets any
  /// previous cleanup. Call this whenever a new recording's audio loads.
  void setOriginal(String? localPath) {
    state = EnhancementState.initial.copyWith(
      originalPath: localPath,
      clearOriginalPath: localPath == null,
      ffmpegAvailable: state.ffmpegAvailable,
    );
    _ensureAvailabilityChecked();
  }

  Future<void> _ensureAvailabilityChecked() async {
    if (state.ffmpegAvailable != null) return;
    final path = await _service.resolveFfmpeg();
    if (!mounted) return;
    state = state.copyWith(ffmpegAvailable: path != null);
  }

  void selectPreset(EnhancementPreset preset) {
    state = state.copyWith(
      settings: EnhancementSettings.forPreset(preset),
      clearError: true,
    );
  }

  void setNoiseReduction(double value) {
    state = state.copyWith(
      settings: state.settings
          .copyWith(noiseReductionDb: value, preset: EnhancementPreset.custom),
    );
  }

  void setLowCut(double value) {
    state = state.copyWith(
      settings: state.settings
          .copyWith(lowCutHz: value, preset: EnhancementPreset.custom),
    );
  }

  void setHighCut(double value) {
    state = state.copyWith(
      settings: state.settings
          .copyWith(highCutHz: value, preset: EnhancementPreset.custom),
    );
  }

  /// Toggles cleanup on/off. Turning off reverts to the original immediately.
  Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      state = state.copyWith(enabled: true, clearError: true);
      await apply();
    } else {
      state = state.copyWith(enabled: false, clearError: true);
      await _revert();
    }
  }

  /// Processes the original with the current settings and swaps it into the
  /// player, preserving position and play state.
  Future<void> apply() async {
    final original = state.originalPath;
    if (original == null || original.isEmpty) {
      state = state.copyWith(
        error: 'No local audio available to process yet.',
      );
      return;
    }
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true, enabled: true, clearError: true);
    final player = _ref.read(audioPlayerControllerProvider.notifier);
    final playerState = _ref.read(audioPlayerControllerProvider);
    final position = playerState.position;
    final resume = playerState.isPlaying;
    try {
      final outPath = await _service.process(
        inputPath: original,
        settings: state.settings,
      );
      if (!mounted) return;
      await player.swapSource(outPath, position: position, resume: resume);
      if (!mounted) return;
      state = state.copyWith(isProcessing: false);
    } on FfmpegUnavailableException catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isProcessing: false,
        enabled: false,
        ffmpegAvailable: false,
        error: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isProcessing: false,
        enabled: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> _revert() async {
    final original = state.originalPath;
    if (original == null || original.isEmpty) return;
    final player = _ref.read(audioPlayerControllerProvider.notifier);
    final playerState = _ref.read(audioPlayerControllerProvider);
    await player.swapSource(
      original,
      position: playerState.position,
      resume: playerState.isPlaying,
    );
  }
}

final audioEnhancementControllerProvider =
    StateNotifierProvider<AudioEnhancementController, EnhancementState>((ref) {
  final controller = AudioEnhancementController(ref);
  // Drop processed temp files when leaving the player to bound disk usage.
  ref.onDispose(() {
    ref.read(audioEnhancementServiceProvider).clearCache();
  });
  return controller;
});
