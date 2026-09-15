import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/providers.dart';
import '../../services/update_manager.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _waveAnimationController;

  @override
  void initState() {
    super.initState();
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.label,
      filled: true,
      fillColor: AppColors.surfaceSearchInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusInput),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusInput),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusInput),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);
    final authState = authController.value;

    ref.listen<String?>(offlineSyncWarningProvider, (prev, next) {
      if (next == null || next.isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryDark,
            duration: const Duration(seconds: 8),
          ),
        );
        ref.read(offlineSyncWarningProvider.notifier).state = null;
      });
    });

    // Show a one-shot "session expired" banner if we were redirected here
    // because the JWT expired (picked up either by the 401 interceptor or
    // the periodic expiry check).
    if (authState.sessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Your session has expired. Please sign in again.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 4),
          ),
        );
        authController.clearSessionExpired();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _waveAnimationController,
            builder: (context, child) {
              return Container(
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
                child: CustomPaint(
                  painter: WavePainter(
                    animationValue: _waveAnimationController.value,
                  ),
                  size: Size.infinite,
                ),
              );
            },
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                    border: Border.all(
                      color: AppColors.surfaceGlassBorder,
                      width: 1.5,
                    ),
                    boxShadow: AppTokens.frameShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 240,
                        height: 78,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Image.asset(
                          'assets/images/download.jpg',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      const _ApiStatusChip(),
                      const SizedBox(height: 16),
                      Text('Welcome back', style: AppTextStyles.headerLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue to Testimony Transcriber Portal',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSearchInput,
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusPill),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          'Version ${UpdateManager.appDisplayVersion ?? UpdateManager.bundledAppVersion}',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: TextFormField(
                                controller: _emailController,
                                style: AppTextStyles.body,
                                decoration: _fieldDecoration('Email'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Required'
                                        : null,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: AppTextStyles.body,
                                decoration: _fieldDecoration('Password'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Required'
                                        : null,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  TextButton(
                                    onPressed: authState.isLoading
                                        ? null
                                        : () async {
                                            final uri = Uri.parse(
                                              'https://api.testimony.co.zw/forgot_password',
                                            );
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(
                                                uri,
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            } else if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Could not open forgot password page',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      AppColors.danger,
                                                ),
                                              );
                                            }
                                          },
                                    child: Text(
                                      'Forgot Password?',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (authState.errorMessage != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  authState.errorMessage!,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.danger,
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: authState.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState
                                                ?.validate() ??
                                            false) {
                                          await authController.loginOffline(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                          );
                                        }
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryDark,
                                  side: const BorderSide(
                                    color: AppColors.borderSubtle,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.radiusPill,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Sign in offline',
                                  style: AppTextStyles.button.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Offline uses a cached user list with secure password '
                                'verification. Sign in online once to download the roster.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.tileSnippet.copyWith(
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 24),
                        child: Text(
                          'Intuitive Innovation for Modern Justice Systems',
                          style: AppTextStyles.label,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiStatusChip extends ConsumerWidget {
  const _ApiStatusChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(apiStatusProvider);
    final String label;
    final Color color;
    switch (status) {
      case ApiStatus.online:
        label = 'API Online';
        color = AppColors.onlineGreen;
        break;
      case ApiStatus.offline:
        label = 'API Offline';
        color = AppColors.danger;
        break;
      case ApiStatus.checking:
        label = 'API …';
        color = AppColors.textTertiary;
        break;
    }
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandMint.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path1 = Path();
    final path2 = Path();
    final path3 = Path();

    final offset = animationValue * size.width;

    path1.moveTo(-offset, size.height * 0.45);
    for (double x = 0; x < size.width + 200; x += 200) {
      path1.quadraticBezierTo(
        x + 100 - offset,
        size.height * 0.4,
        x + 200 - offset,
        size.height * 0.45,
      );
    }

    path2.moveTo(-offset, size.height * 0.5);
    for (double x = 0; x < size.width + 200; x += 200) {
      path2.quadraticBezierTo(
        x + 100 - offset,
        size.height * 0.45,
        x + 200 - offset,
        size.height * 0.5,
      );
    }

    path3.moveTo(-offset, size.height * 0.35);
    for (double x = 0; x < size.width + 200; x += 200) {
      path3.quadraticBezierTo(
        x + 100 - offset,
        size.height * 0.3,
        x + 200 - offset,
        size.height * 0.35,
      );
    }

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
