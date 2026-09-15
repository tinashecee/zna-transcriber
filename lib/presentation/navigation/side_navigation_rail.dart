import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';

enum AppNavDestination { recordings, upload, system }

/// Shared expand/collapse state so the rail stays open across routes.
final sideNavExpandedProvider = StateProvider<bool>((ref) => true);

/// Glass navigation rail — collapses to icons, expands with page labels.
class SideNavigationRail extends ConsumerWidget {
  const SideNavigationRail({
    super.key,
    required this.selected,
    this.userName,
    this.onUserTap,
    this.navigationEnabled = true,
  });

  final AppNavDestination selected;
  final String? userName;
  final VoidCallback? onUserTap;

  /// When false (e.g. unauthenticated on /system), other destinations are disabled.
  final bool navigationEnabled;

  static const double _collapsedWidth = 76;
  static const double _expandedWidth = 220;

  static Widget _logoMedallion({
    double size = 48,
    String asset = 'assets/images/download.jpg',
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(size * 0.33),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: AppTokens.medallionShadow,
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final expanded = ref.watch(sideNavExpandedProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOutCubic,
      width: expanded ? _expandedWidth : _collapsedWidth,
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: expanded ? 12 : 14,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceGlassSubtle,
        border: Border(
          right: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            expanded ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
        children: [
          if (expanded)
            Row(
              children: [
                Tooltip(
                  message: navigationEnabled ? 'Recordings' : 'Home',
                  child: InkWell(
                    onTap: navigationEnabled
                        ? () => context.go('/recordings')
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: _logoMedallion(size: 44),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Testimony',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.recipientName,
                  ),
                ),
                Tooltip(
                  message: 'Collapse',
                  child: InkWell(
                    onTap: () {
                      ref.read(sideNavExpandedProvider.notifier).state = false;
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Tooltip(
                  message: 'Expand',
                  child: InkWell(
                    onTap: () {
                      ref.read(sideNavExpandedProvider.notifier).state = true;
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Tooltip(
                  message: navigationEnabled ? 'Recordings' : 'Home',
                  child: InkWell(
                    onTap: navigationEnabled
                        ? () => context.go('/recordings')
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: _logoMedallion(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 28),
          _NavItem(
            icon: Icons.library_music_outlined,
            activeIcon: Icons.library_music,
            label: 'Recordings',
            tooltip: navigationEnabled
                ? 'Recordings'
                : 'Enter an API key first',
            isActive: selected == AppNavDestination.recordings ||
                location.startsWith('/recordings'),
            enabled: navigationEnabled,
            expanded: expanded,
            onTap: () => context.go('/recordings'),
          ),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.upload_file_outlined,
            activeIcon: Icons.upload_file,
            label: 'Upload',
            tooltip: navigationEnabled
                ? 'Upload'
                : 'Enter an API key first',
            isActive: selected == AppNavDestination.upload ||
                location.startsWith('/upload'),
            enabled: navigationEnabled,
            expanded: expanded,
            onTap: () => context.go('/upload-recording'),
          ),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'System',
            tooltip: 'System',
            isActive: selected == AppNavDestination.system ||
                location.startsWith('/system'),
            enabled: true,
            expanded: expanded,
            onTap: () => context.go('/system'),
          ),
          const Spacer(),
          Tooltip(
            message: userName ?? 'Account',
            child: InkWell(
              onTap: onUserTap,
              borderRadius: BorderRadius.circular(16),
              child: expanded
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSearchInput,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _logoMedallion(
                            size: 36,
                            asset: 'assets/images/testimony.png',
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              userName?.trim().isNotEmpty == true
                                  ? userName!
                                  : 'Account',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.tileTitle,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _logoMedallion(
                      size: 42,
                      asset: 'assets/images/testimony.png',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
    required this.expanded,
    this.enabled = true,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;
  final bool expanded;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = !enabled
        ? AppColors.textTertiary
        : isActive
            ? Colors.white
            : AppColors.textSecondary;
    final Color labelColor = !enabled
        ? AppColors.textTertiary
        : isActive
            ? Colors.white
            : AppColors.textPrimary;

    final item = InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(expanded ? 14 : 22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        width: expanded ? double.infinity : 44,
        padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 0),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(expanded ? 14 : 22),
        ),
        alignment: expanded ? Alignment.centerLeft : Alignment.center,
        child: expanded
            ? Row(
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    size: 20,
                    color: iconColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.tileTitle.copyWith(
                        color: labelColor,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )
            : Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: iconColor,
              ),
      ),
    );

    if (expanded) return item;
    return Tooltip(message: tooltip, child: item);
  }
}
