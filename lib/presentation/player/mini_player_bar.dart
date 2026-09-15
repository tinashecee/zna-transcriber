import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import 'audio_player_controller.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerControllerProvider);
    if (state.duration == Duration.zero) {
      return const SizedBox.shrink();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
            border: Border.all(
              color: AppColors.surfaceGlassBorder,
              width: 1.5,
            ),
            boxShadow: AppTokens.bubbleShadow,
          ),
          child: Row(
            children: [
              Material(
                color: AppColors.primaryDark,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: ref
                      .read(audioPlayerControllerProvider.notifier)
                      .playPause,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryDark,
                    inactiveTrackColor: AppColors.borderSubtle,
                    thumbColor: AppColors.primaryDark,
                    overlayColor:
                        AppColors.primaryDark.withValues(alpha: 0.12),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: state.position.inSeconds
                        .clamp(0, state.duration.inSeconds)
                        .toDouble(),
                    max: state.duration.inSeconds.toDouble().clamp(1, double.infinity),
                    onChanged: (value) => ref
                        .read(audioPlayerControllerProvider.notifier)
                        .seek(Duration(seconds: value.toInt())),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_format(state.position)} / ${_format(state.duration)}',
                style: AppTextStyles.tileTimestamp.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(duration.inMinutes.remainder(60));
    final secs = two(duration.inSeconds.remainder(60));
    final hours = duration.inHours;
    return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
  }
}
