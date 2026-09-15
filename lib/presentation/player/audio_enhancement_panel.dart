import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'audio_enhancement_controller.dart';

const Color _accent = Color(0xFF115343);

/// Denoise / voice-isolation controls for the player screens.
///
/// [preparing] is true while the screen is downloading a remote recording so a
/// local copy can be processed; the controls stay disabled with a hint until
/// the file is ready.
class AudioEnhancementPanel extends ConsumerWidget {
  const AudioEnhancementPanel({
    super.key,
    this.preparing = false,
    this.prepareProgress,
    this.prepareStatus = '',
    this.onEnableRequested,
  });

  final bool preparing;

  /// Download progress 0.0–1.0 when known; null shows an indeterminate bar.
  final double? prepareProgress;

  /// Short status line shown while [preparing] is true.
  final String prepareStatus;

  /// Called when the user turns cleanup on but no local source is available yet
  /// (e.g. the online player must download the recording first). When provided,
  /// the toggle stays enabled even before a local file exists.
  final Future<void> Function()? onEnableRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioEnhancementControllerProvider);
    final controller = ref.read(audioEnhancementControllerProvider.notifier);

    final unavailable = state.ffmpegAvailable == false;
    final noSource = !state.hasLocalSource;
    final canPrepare = onEnableRequested != null;
    final canToggle = !unavailable &&
        !preparing &&
        !state.isProcessing &&
        (!noSource || canPrepare);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.graphic_eq, color: _accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Clean up audio',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _accent,
                  ),
                ),
              ),
              if (state.isProcessing)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              Switch(
                value: state.enabled,
                activeColor: _accent,
                onChanged: canToggle
                    ? (v) {
                        if (!v) {
                          controller.setEnabled(false);
                        } else if (state.hasLocalSource) {
                          controller.setEnabled(true);
                        } else if (onEnableRequested != null) {
                          onEnableRequested!();
                        }
                      }
                    : null,
              ),
            ],
          ),
          Text(
            'Remove white noise and isolate voices using a noise filter.',
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600]),
          ),
          if (unavailable) ...[
            const SizedBox(height: 8),
            _Hint(
              icon: Icons.error_outline,
              color: Colors.redAccent,
              text: state.error ??
                  'FFmpeg is not available. Add ffmpeg.exe to assets/ffmpeg/ '
                      'or install FFmpeg on this machine.',
            ),
          ] else if (preparing) ...[
            const SizedBox(height: 10),
            _PrepareProgress(
              progress: prepareProgress,
              status: prepareStatus.isNotEmpty
                  ? prepareStatus
                  : 'Preparing audio for processing...',
            ),
          ] else if (noSource && !canPrepare) ...[
            const SizedBox(height: 8),
            const _Hint(
              icon: Icons.info_outline,
              color: Colors.grey,
              text: 'Download this recording to enable cleanup.',
            ),
          ],
          if (state.enabled && canToggle) ...[
            const SizedBox(height: 12),
            _PresetRow(state: state, controller: controller),
            const SizedBox(height: 8),
            _SliderRow(
              label: 'Noise reduction',
              value: state.settings.noiseReductionDb,
              min: 0,
              max: 30,
              divisions: 30,
              suffix: ' dB',
              onChanged: state.isProcessing ? null : controller.setNoiseReduction,
            ),
            _SliderRow(
              label: 'Low cut (clip below)',
              value: state.settings.lowCutHz,
              min: 50,
              max: 500,
              divisions: 45,
              suffix: ' Hz',
              onChanged: state.isProcessing ? null : controller.setLowCut,
            ),
            _SliderRow(
              label: 'High cut (clip above)',
              value: state.settings.highCutHz,
              min: 2000,
              max: 12000,
              divisions: 100,
              suffix: ' Hz',
              onChanged: state.isProcessing ? null : controller.setHighCut,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: state.isProcessing ? null : () => controller.apply(),
                icon: state.isProcessing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_fix_high, size: 16),
                label: Text(state.isProcessing ? 'Processing...' : 'Apply'),
                style: FilledButton.styleFrom(backgroundColor: _accent),
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 6),
              _Hint(
                icon: Icons.error_outline,
                color: Colors.redAccent,
                text: state.error!,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.state, required this.controller});

  final EnhancementState state;
  final AudioEnhancementController controller;

  static const _labels = {
    EnhancementPreset.light: 'Light',
    EnhancementPreset.standard: 'Standard',
    EnhancementPreset.strong: 'Strong',
    EnhancementPreset.voiceIsolation: 'Voice Isolation',
    EnhancementPreset.custom: 'Custom',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Preset:',
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<EnhancementPreset>(
          value: state.settings.preset,
          isDense: true,
          items: _labels.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value, style: GoogleFonts.roboto(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: state.isProcessing
              ? null
              : (value) {
                  // Selecting "Custom" keeps the current slider values.
                  if (value == null || value == EnhancementPreset.custom) {
                    return;
                  }
                  controller.selectPreset(value);
                },
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(min, max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.roboto(fontSize: 12),
              ),
            ),
            Text(
              '${clamped.toStringAsFixed(0)}$suffix',
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _accent,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            activeTrackColor: _accent,
            thumbColor: _accent,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: clamped.toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _PrepareProgress extends StatelessWidget {
  const _PrepareProgress({required this.progress, required this.status});

  final double? progress;
  final String status;

  @override
  Widget build(BuildContext context) {
    final percent = progress != null ? (progress! * 100).round() : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.downloading, size: 16, color: _accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                status,
                style: GoogleFonts.roboto(fontSize: 12, color: _accent),
              ),
            ),
            if (percent != null)
              Text(
                '$percent%',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _accent,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (progress != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress!.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: _accent.withOpacity(0.15),
              color: _accent,
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 6,
              backgroundColor: _accent.withOpacity(0.15),
              color: _accent,
            ),
          ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.roboto(fontSize: 12, color: color),
          ),
        ),
      ],
    );
  }
}
