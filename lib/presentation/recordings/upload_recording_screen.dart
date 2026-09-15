import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/providers.dart';
import '../../services/auth_session.dart';
import '../../services/dio_error_mapper.dart';
import '../navigation/side_navigation_rail.dart';
import '../widgets/app_shell.dart';
import 'recordings_controller.dart';

class UploadRecordingScreen extends ConsumerStatefulWidget {
  const UploadRecordingScreen({super.key});

  @override
  ConsumerState<UploadRecordingScreen> createState() =>
      _UploadRecordingScreenState();
}

class _UploadRecordingScreenState extends ConsumerState<UploadRecordingScreen> {
  static const List<String> _supportedAudioExtensions = [
    'wav',
    'm4a',
    'aac',
    'mp3',
    'ogg',
    'flac',
    'wma',
  ];

  final _formKey = GlobalKey<FormState>();

  XFile? _pickedFile;
  int? _pickedFileSize;

  final _caseNumber = TextEditingController();
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _judgeName = TextEditingController();
  final _prosecutionCounsel = TextEditingController();
  final _defenseCounsel = TextEditingController();

  DateTime _dateStamp = DateTime.now();

  int? _durationSeconds;
  bool _durationLoading = false;
  String? _durationError;

  List<String> _courts = const [];
  Map<String, List<String>> _courtroomsByCourt = const {};
  String? _selectedCourt;
  String? _selectedCourtroom;

  bool _loadingCourts = true;
  String? _courtLoadError;

  bool _isUploading = false;
  double _progress = 0.0;
  String? _uploadError;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _loadCourtData();
  }

  @override
  void dispose() {
    _caseNumber.dispose();
    _title.dispose();
    _notes.dispose();
    _judgeName.dispose();
    _prosecutionCounsel.dispose();
    _defenseCounsel.dispose();
    super.dispose();
  }

  Future<void> _loadCourtData() async {
    setState(() {
      _loadingCourts = true;
      _courtLoadError = null;
    });
    try {
      final repo = ref.read(recordingRepositoryProvider);
      final results = await Future.wait([
        repo.fetchCourts(),
        repo.fetchCourtroomsByCourt(),
      ]);
      final courts = (results[0] as List<String>)..sort();
      final roomsByCourt = results[1] as Map<String, List<String>>;
      if (!mounted) return;
      setState(() {
        _courts = courts;
        _courtroomsByCourt = roomsByCourt;
        _loadingCourts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCourts = false;
        _courtLoadError = e.toString();
      });
    }
  }

  Future<void> _pickAudioFile() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Audio (${_supportedAudioExtensions.map((e) => '.$e').join(', ')})',
          extensions: _supportedAudioExtensions,
        ),
      ],
    );
    if (file == null) return;

    int? size;
    try {
      final f = File(file.path);
      size = await f.length();
    } catch (_) {
      size = null;
    }

    if (!mounted) return;
    setState(() {
      _pickedFile = file;
      _pickedFileSize = size;
      _uploadError = null;
      _progress = 0.0;
      _durationSeconds = null;
      _durationError = null;
    });

    await _probeDuration(file.path);
  }

  Future<void> _probeDuration(String filePath) async {
    setState(() {
      _durationLoading = true;
      _durationError = null;
    });
    final player = AudioPlayer();
    try {
      final d = await player.setFilePath(filePath);
      final duration = d ?? player.duration;
      if (duration == null) {
        throw Exception('Could not determine duration');
      }
      final secs = duration.inSeconds;
      if (!mounted) return;
      setState(() {
        _durationSeconds = secs <= 0 ? 1 : secs;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _durationError = 'Failed to read audio duration: $e';
      });
    } finally {
      await player.dispose();
      if (!mounted) return;
      setState(() {
        _durationLoading = false;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateStamp,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateStamp),
    );
    if (time == null) return;

    final next = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (!mounted) return;
    setState(() => _dateStamp = next);
  }

  bool get _canSubmit {
    if (_isUploading) return false;
    if (_pickedFile == null) return false;
    if (_durationLoading) return false;
    if (_durationSeconds == null) return false;
    if (_selectedCourt == null || _selectedCourt!.trim().isEmpty) return false;
    if (_selectedCourtroom == null || _selectedCourtroom!.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _startUpload() async {
    setState(() {
      _uploadError = null;
      _isUploading = true;
      _progress = 0.0;
    });
    _cancelToken = CancelToken();

    try {
      final picked = _pickedFile;
      if (picked == null) {
        throw Exception('No audio file selected');
      }
      if (!(_formKey.currentState?.validate() ?? false)) {
        throw Exception('Please fix the highlighted fields');
      }

      final duration = _durationSeconds;
      if (duration == null || duration <= 0) {
        throw Exception('Could not determine audio duration');
      }

      final file = File(picked.path);
      final size = await file.length();
      final filename = picked.name;

      final service = ref.read(recordingUploadServiceProvider);
      final uploadedFilename = await service.uploadV2(
        file: file,
        filename: filename,
        cancelToken: _cancelToken!,
        onProgress: (p) {
          if (!mounted) return;
          setState(() => _progress = p);
        },
      );

      final dateStampStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(_dateStamp);

      await service.postRecordingMetadata(
        cancelToken: _cancelToken!,
        fields: {
          'case_number': _caseNumber.text.trim(),
          'title': _title.text.trim(),
          'notes': _notes.text.trim(),
          'date_stamp': dateStampStr,
          'judge_name': _judgeName.text.trim(),
          'prosecution_counsel': _prosecutionCounsel.text.trim(),
          'defense_counsel': _defenseCounsel.text.trim(),
          'courtroom': _selectedCourtroom!.trim(),
          'court': _selectedCourt!.trim(),
          'duration': duration.toString(),
          'size': size.toString(),
          'status': 'backed up',
          'annotations': '[]',
          'file_path': uploadedFilename,
        },
      );

      // Refresh list and pop.
      ref.read(recordingsControllerProvider.notifier).loadInitial();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload complete')),
      );
      // Use router navigation and schedule it post-frame to avoid navigator
      // mutation while the tree is finalizing/dispose is in progress.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.go('/recordings');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadError = mapDioError(e);
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _cancelUpload() {
    _cancelToken?.cancel('User cancelled');
  }

  void _leaveScreen() {
    if (_isUploading) return;
    context.go('/recordings');
  }

  @override
  Widget build(BuildContext context) {
    final fileName = _pickedFile?.name;
    final fileSize = _pickedFileSize;
    final courtrooms =
        _selectedCourt == null ? const <String>[] : (_courtroomsByCourt[_selectedCourt!] ?? const <String>[]);
    final session = ref.watch(authSessionProvider);

    return AppShell(
      child: Row(
        children: [
          SideNavigationRail(
            selected: AppNavDestination.upload,
            userName: session.user?.name.trim().isNotEmpty == true
                ? session.user!.name
                : session.user?.email,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
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
                      Tooltip(
                        message: 'Back to Recordings',
                        child: Material(
                          color: AppColors.surfaceSearchInput,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _isUploading ? null : _leaveScreen,
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload Recording',
                              style: AppTextStyles.headerLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Choose audio and enter case metadata',
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
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusCard),
                            border: Border.all(
                              color: AppColors.borderSubtle
                                  .withValues(alpha: 0.8),
                            ),
                            boxShadow: AppTokens.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('Audio file'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  FilledButton.icon(
                                    onPressed:
                                        _isUploading ? null : _pickAudioFile,
                                    icon: const Icon(Icons.folder_open),
                                    label: const Text('Choose file'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primaryDark,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppTokens.radiusPill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      fileName == null
                                          ? 'No file selected'
                                          : (fileSize == null
                                              ? fileName
                                              : '$fileName (${_formatBytes(fileSize)})'),
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Supported audio formats: ${_supportedAudioExtensions.map((e) => '.$e').join(', ')}. '
                                'Recommended: .wav or .m4a.',
                                style: AppTextStyles.tileSnippet,
                              ),
                              const SizedBox(height: 20),
                              _sectionTitle('Metadata'),
                              const SizedBox(height: 8),
                              if (_loadingCourts)
                                const LinearProgressIndicator(
                                  color: AppColors.primaryDark,
                                )
                              else if (_courtLoadError != null)
                                _errorBox(
                                  'Failed to load courts/courtrooms.\n$_courtLoadError',
                                  onRetry: _loadCourtData,
                                ),
                              const SizedBox(height: 8),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _twoCol(
                                      left: _textField(
                                        controller: _caseNumber,
                                        label: 'Case number',
                                        required: true,
                                      ),
                                      right: _textField(
                                        controller: _title,
                                        label: 'Title',
                                        required: true,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _twoCol(
                                      left: _dropdown<String>(
                                        label: 'Court',
                                        value: _selectedCourt,
                                        items: _courts,
                                        onChanged: _isUploading
                                            ? null
                                            : (v) {
                                                setState(() {
                                                  _selectedCourt = v;
                                                  _selectedCourtroom = null;
                                                });
                                              },
                                        required: true,
                                      ),
                                      right: _dropdown<String>(
                                        label: 'Courtroom',
                                        value: _selectedCourtroom,
                                        items: courtrooms,
                                        onChanged: _isUploading
                                            ? null
                                            : (v) {
                                                setState(
                                                  () =>
                                                      _selectedCourtroom = v,
                                                );
                                              },
                                        enabled: _selectedCourt != null &&
                                            !_loadingCourts,
                                        required: true,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _twoCol(
                                      left: _textField(
                                        controller: _judgeName,
                                        label: 'Judge name',
                                      ),
                                      right: _durationField(),
                                    ),
                                    const SizedBox(height: 12),
                                    _twoCol(
                                      left: _textField(
                                        controller: _prosecutionCounsel,
                                        label: 'Prosecution counsel',
                                      ),
                                      right: _textField(
                                        controller: _defenseCounsel,
                                        label: 'Defense counsel',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: _isUploading
                                                ? null
                                                : _pickDateTime,
                                            icon: const Icon(Icons.event),
                                            label: Text(
                                              'Date/time: ${DateFormat('yyyy-MM-dd HH:mm').format(_dateStamp)}',
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.primaryDark,
                                              side: const BorderSide(
                                                color: AppColors.borderSubtle,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  AppTokens.radiusPill,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _textField(
                                      controller: _notes,
                                      label: 'Notes',
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (_isUploading) ...[
                                LinearProgressIndicator(
                                  value: _progress.clamp(0.0, 1.0),
                                  color: AppColors.primaryDark,
                                  backgroundColor: AppColors.borderSubtle,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Uploading… ${(100 * _progress).toStringAsFixed(0)}%',
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: _cancelUpload,
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (_uploadError != null) ...[
                                _errorBox(_uploadError!),
                                const SizedBox(height: 8),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed:
                                        _isUploading ? null : _leaveScreen,
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
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton.icon(
                                    onPressed:
                                        _canSubmit ? _startUpload : null,
                                    icon: const Icon(Icons.cloud_upload),
                                    label: const Text('Upload'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          AppColors.primaryDark,
                                      foregroundColor: Colors.white,
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
                      ),
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.headerMedium,
    );
  }

  Widget _twoCol({required Widget left, required Widget right}) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
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
          borderSide: const BorderSide(
            color: AppColors.primaryDark,
            width: 1.5,
          ),
        ),
      ),
      validator: (value) {
        if (!required) return null;
        if (value == null || value.trim().isEmpty) return 'Required';
        return null;
      },
    );
  }

  Widget _durationField() {
    final value = _durationSeconds;
    final label = _durationLoading
        ? 'Duration (detecting...)'
        : 'Duration (seconds)';

    return InputDecorator(
      decoration: InputDecoration(
        labelText: '$label *',
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
        errorText: _durationError,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value == null ? '—' : value.toString(),
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (_durationLoading) ...[
            const SizedBox(width: 10),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryDark,
              ),
            ),
          ],
          if (!_durationLoading && _pickedFile != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: _isUploading
                  ? null
                  : () => _probeDuration(_pickedFile!.path),
              child: const Text('Recheck'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?>? onChanged,
    bool enabled = true,
    bool required = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
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
          borderSide: const BorderSide(
            color: AppColors.primaryDark,
            width: 1.5,
          ),
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(e.toString(), overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: (v) {
        if (!required) return null;
        if (v == null || v.toString().trim().isEmpty) return 'Required';
        return null;
      },
    );
  }

  Widget _errorBox(String message, {VoidCallback? onRetry}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(AppTokens.radiusTile),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }

  static String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double v = bytes.toDouble();
    int i = 0;
    while (v >= 1024 && i < units.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(i == 0 ? 0 : 1)} ${units[i]}';
  }
}

