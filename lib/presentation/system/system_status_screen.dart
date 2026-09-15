import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../navigation/side_navigation_rail.dart';
import '../widgets/app_shell.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/auth_session.dart';
import '../../services/update_manager.dart';

class SystemStatusScreen extends ConsumerStatefulWidget {
  const SystemStatusScreen({super.key});

  @override
  ConsumerState<SystemStatusScreen> createState() => _SystemStatusScreenState();
}

class _SystemStatusScreenState extends ConsumerState<SystemStatusScreen> {
  bool _checking = false;
  Map<String, dynamic>? _downloadProgress;

  final _apiKeyController = TextEditingController();
  bool _apiKeyObscured = true;
  bool _apiKeySaving = false;

  @override
  void initState() {
    super.initState();

    // Listen to download progress
    UpdateManager.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _downloadProgress = progress;
        });
      }
    });

    // Auto-check for updates when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isWindows) {
        _checkForUpdates();
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final typed = _apiKeyController.text.trim();
    if (typed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paste a new API key to save, or use Clear to remove.'),
        ),
      );
      return;
    }
    setState(() => _apiKeySaving = true);
    try {
      await ref.read(authControllerProvider).saveApiKey(typed);
      if (!mounted) return;
      _apiKeyController.clear();
      final ok = ref.read(authControllerProvider).value.isAuthenticated;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'API key saved. You are authenticated as machine client.'
                : 'API key cleared.',
          ),
        ),
      );
      if (ok) {
        context.go('/recordings');
      }
    } finally {
      if (mounted) setState(() => _apiKeySaving = false);
    }
  }

  Future<void> _clearApiKey() async {
    setState(() => _apiKeySaving = true);
    try {
      await ref.read(authControllerProvider).clearApiKey();
      if (!mounted) return;
      _apiKeyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key removed.')),
      );
    } finally {
      if (mounted) setState(() => _apiKeySaving = false);
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _checking = true;
    });

    await UpdateManager.checkForUpdatesManual(context);

    if (mounted) {
      setState(() {
        _checking = false;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.8)),
        boxShadow: AppTokens.cardShadow,
      );

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final auth = ref.watch(authControllerProvider).value;
    final isAuthed = auth.isAuthenticated || session.isAuthenticated;

    return AppShell(
      child: Row(
        children: [
          SideNavigationRail(
            selected: AppNavDestination.system,
            navigationEnabled: isAuthed,
            userName: session.user?.name.trim().isNotEmpty == true
                ? session.user!.name
                : session.user?.email,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isAuthed) ...[
                        Tooltip(
                          message: 'Back to Recordings',
                          child: Material(
                            color: AppColors.surfaceSearchInput,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => context.go('/recordings'),
                              child: const SizedBox(
                                width: 42,
                                height: 42,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => context.go('/recordings'),
                          icon: const Icon(Icons.library_music_outlined,
                              size: 18),
                          label: const Text('Recordings'),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Status',
                              style: AppTextStyles.headerLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAuthed
                                  ? 'App info, API key, and updates'
                                  : 'Enter an API key to continue',
                              style: AppTextStyles.tileTimestamp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: _cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppColors.primaryDark,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'App Information',
                                    style: AppTextStyles.headerMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                'App Name',
                                'Testimony Transcriber',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Current Version',
                                UpdateManager.appDisplayVersion ??
                                    UpdateManager.bundledAppVersion,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Platform',
                                Platform.operatingSystem,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: _cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.vpn_key_outlined,
                                    color: AppColors.primaryDark,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'API key',
                                      style: AppTextStyles.headerMedium,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: session.hasApiKey
                                          ? AppColors.onlineGreen
                                              .withValues(alpha: 0.12)
                                          : AppColors.warningBg,
                                      borderRadius: BorderRadius.circular(
                                        AppTokens.radiusTile,
                                      ),
                                      border: Border.all(
                                        color: session.hasApiKey
                                            ? AppColors.onlineGreen
                                                .withValues(alpha: 0.35)
                                            : AppColors.badgeOrange
                                                .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      session.hasApiKey
                                          ? 'Configured'
                                          : 'Required',
                                      style: AppTextStyles.label.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: session.hasApiKey
                                            ? AppColors.onlineGreen
                                            : AppColors.warningText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                session.hasApiKey
                                    ? 'A key is saved on this machine. Paste a new key below only if you need to replace it — the current key is never shown again.'
                                    : 'Each machine uses one key. Sent as X-API-Key on every request — no login needed.',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _apiKeyController,
                                obscureText: _apiKeyObscured,
                                enableSuggestions: false,
                                autocorrect: false,
                                style: AppTextStyles.body,
                                decoration: InputDecoration(
                                  labelText: session.hasApiKey
                                      ? 'Replace API key'
                                      : 'API key',
                                  hintText: session.hasApiKey
                                      ? 'Paste new key to replace'
                                      : 'Paste API key',
                                  filled: true,
                                  fillColor: AppColors.surfaceSearchInput,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.radiusInput,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderSubtle,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.radiusInput,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderSubtle,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.radiusInput,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryDark,
                                      width: 1.5,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    tooltip:
                                        _apiKeyObscured ? 'Show' : 'Hide',
                                    onPressed: () {
                                      setState(
                                        () =>
                                            _apiKeyObscured = !_apiKeyObscured,
                                      );
                                    },
                                    icon: Icon(
                                      _apiKeyObscured
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                onSubmitted: (_) {
                                  if (!_apiKeySaving) _saveApiKey();
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  FilledButton.icon(
                                    onPressed:
                                        _apiKeySaving ? null : _saveApiKey,
                                    icon: _apiKeySaving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.save_outlined),
                                    label: Text(
                                      _apiKeySaving
                                          ? 'Saving…'
                                          : (session.hasApiKey
                                              ? 'Replace key'
                                              : 'Save key'),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primaryDark,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppTokens.radiusPill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (session.hasApiKey)
                                    OutlinedButton.icon(
                                      onPressed: _apiKeySaving
                                          ? null
                                          : _clearApiKey,
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Clear'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            AppColors.textSecondary,
                                        side: const BorderSide(
                                          color: AppColors.borderSubtle,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppTokens.radiusPill,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Builder(
                          builder: (context) {
                            final user = session.user;
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: _cardDecoration,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        color: AppColors.primaryDark,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Logged-in user',
                                        style: AppTextStyles.headerMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  if (user == null)
                                    Text(
                                      'Not logged in',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  else ...[
                                    _buildInfoRow('User ID', user.id),
                                    const SizedBox(height: 12),
                                    _buildInfoRow('Name', user.name),
                                    const SizedBox(height: 12),
                                    _buildInfoRow('Email', user.email),
                                    const SizedBox(height: 12),
                                    _buildInfoRow('Role', user.role),
                                    if (session.hasApiKey) ...[
                                      const SizedBox(height: 12),
                                      _buildInfoRow('Auth', 'API key'),
                                    ],
                                    if (user.province != null &&
                                        user.province!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        'Province',
                                        user.province!,
                                      ),
                                    ],
                                    if (user.court != null &&
                                        user.court!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      _buildInfoRow('Court', user.court!),
                                    ],
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: _cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.system_update,
                                    color: AppColors.primaryDark,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Updates',
                                    style: AppTextStyles.headerMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (!Platform.isWindows)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningBg,
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.radiusTile,
                                    ),
                                    border: Border.all(
                                      color: AppColors.badgeOrange
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: AppColors.warningText,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Automatic updates are only available on Windows',
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.warningText,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else ...[
                                FilledButton.icon(
                                  onPressed:
                                      _checking ? null : _checkForUpdates,
                                  icon: _checking
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.refresh),
                                  label: Text(
                                    _checking
                                        ? 'Checking...'
                                        : 'Check for Updates',
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppTokens.radiusPill,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_downloadProgress != null) ...[
                                  const SizedBox(height: 20),
                                  _buildDownloadProgress(),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadProgress() {
    final status = _downloadProgress!['status'] as String;
    final progress = _downloadProgress!['progress'] as double?;
    final received = _downloadProgress!['received'] as int?;
    final total = _downloadProgress!['total'] as int?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSearchInput,
        borderRadius: BorderRadius.circular(AppTokens.radiusTile),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (status == 'downloading')
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryDark,
                  ),
                )
              else if (status == 'downloaded')
                const Icon(Icons.check_circle, color: AppColors.onlineGreen)
              else if (status == 'failed')
                const Icon(Icons.error, color: AppColors.danger)
              else
                const Icon(Icons.downloading, color: AppColors.primaryDark),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status == 'downloading'
                      ? 'Downloading update...'
                      : status == 'downloaded'
                          ? 'Download complete!'
                          : status == 'failed'
                              ? 'Download failed'
                              : 'Starting download...',
                  style: AppTextStyles.tileTitle.copyWith(
                    color: status == 'failed'
                        ? AppColors.danger
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (progress != null && progress > 0) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderSubtle,
              color: AppColors.primaryDark,
            ),
            const SizedBox(height: 8),
            if (received != null)
              Text(
                total != null
                    ? '${_formatBytes(received)} / ${_formatBytes(total)} (${(progress * 100).toStringAsFixed(1)}%)'
                    : _formatBytes(received),
                style: AppTextStyles.tileTimestamp,
              ),
          ],
          if (status == 'failed' && _downloadProgress!['error'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error: ${_downloadProgress!['error']}',
              style: AppTextStyles.label.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }
}
