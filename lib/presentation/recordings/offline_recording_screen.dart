import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../services/auth_session.dart';
import '../player/audio_player_controller.dart';
import '../player/audio_enhancement_controller.dart';
import '../player/audio_enhancement_panel.dart';
import '../../domain/entities/recording.dart';

class OfflineRecordingScreen extends ConsumerStatefulWidget {
  const OfflineRecordingScreen({super.key, required this.recordingId});

  final String recordingId;

  @override
  ConsumerState<OfflineRecordingScreen> createState() =>
      _OfflineRecordingScreenState();
}

class _OfflineRecordingScreenState extends ConsumerState<OfflineRecordingScreen> {
  bool _loading = true;
  String? _error;
  Recording? _recording;
  String? _localPath;
  String? _status;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final userId = ref.read(authSessionProvider).user?.id ?? '';
    if (userId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Sign in required to view saved recordings.';
      });
      return;
    }
    try {
      final cache = ref.read(recordingsCacheRepositoryProvider);
      final download = ref.read(offlineAudioDownloadServiceProvider);
      final recording = await cache.recordingById(
        ownerUserId: userId,
        recordingId: widget.recordingId,
      );
      final audioRow = await download.row(
        ownerUserId: userId,
        recordingId: widget.recordingId,
      );

      final local = audioRow?.localPath;
      final exists = local != null && local.isNotEmpty && File(local).existsSync();
      setState(() {
        _recording = recording;
        _audioPath = audioRow?.audioPath;
        _localPath = exists ? local : null;
        _status = audioRow?.status;
        _loading = false;
        _error = recording == null
            ? 'This recording is not saved on this device.'
            : null;
      });

      if (recording != null && exists) {
        await ref
            .read(audioPlayerControllerProvider.notifier)
            .loadLocalFile(local);
        ref
            .read(audioEnhancementControllerProvider.notifier)
            .setOriginal(local);
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load saved recording: $e';
      });
    }
  }

  Future<void> _downloadNow() async {
    final userId = ref.read(authSessionProvider).user?.id ?? '';
    final audioPath = _audioPath ?? _recording?.audioPath ?? '';
    if (userId.isEmpty || audioPath.trim().isEmpty) return;
    setState(() {
      _status = 'queued';
    });
    await ref.read(offlineAudioDownloadServiceProvider).downloadNow(
          ownerUserId: userId,
          recordingId: widget.recordingId,
          audioPath: audioPath,
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(audioPlayerControllerProvider);
    final playerController = ref.read(audioPlayerControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF115343),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            ref.invalidate(audioPlayerControllerProvider);
            ref.invalidate(audioEnhancementControllerProvider);
            context.go('/recordings');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Saved offline',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    Text(
                      _error!,
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF856404),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (_recording != null) ...[
                    _Header(recording: _recording!, status: _status, localPath: _localPath),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_localPath == null)
                          ElevatedButton.icon(
                            onPressed: _downloadNow,
                            icon: const Icon(Icons.download),
                            label: const Text('Download now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF115343),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        if (_localPath != null)
                          OutlinedButton.icon(
                            onPressed: () => playerController.playPause(),
                            icon: Icon(
                              playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                            label: Text(playerState.isPlaying ? 'Pause' : 'Play'),
                          ),
                      ],
                    ),
                    if (_localPath != null) ...[
                      const SizedBox(height: 16),
                      const AudioEnhancementPanel(),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.recording, required this.status, required this.localPath});

  final Recording recording;
  final String? status;
  final String? localPath;

  @override
  Widget build(BuildContext context) {
    final statusLabel = localPath != null
        ? 'Downloaded'
        : (status == null || status!.isEmpty)
            ? 'Missing'
            : status!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recording.caseNumber,
            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            recording.title,
            style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: 'Court: ${recording.court}'),
              _Chip(label: 'Room: ${recording.courtroom}'),
              _Chip(label: 'Audio: $statusLabel'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF115343).withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

