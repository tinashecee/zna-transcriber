import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

/// Soft gradient canvas with a floating glass frame (desktop design system).
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.maxWidth = 1480,
    this.bottomBar,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.canvasGradientStart,
              AppColors.canvasGradientEnd,
            ],
          ),
        ),
        padding: padding,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGlass,
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusOuterFrame),
                      border: Border.all(
                        color: AppColors.surfaceGlassBorder,
                        width: 1.5,
                      ),
                      boxShadow: AppTokens.frameShadow,
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusOuterFrame),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
            if (bottomBar != null) ...[
              const SizedBox(height: 12),
              bottomBar!,
            ],
          ],
        ),
      ),
    );
  }
}
