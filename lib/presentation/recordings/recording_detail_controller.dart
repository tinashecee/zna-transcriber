import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entities/recording.dart';
import '../../services/auth_session.dart';

final recordingDetailProvider =
    FutureProvider.autoDispose.family<Recording, String>((ref, id) async {
  final repo = ref.read(recordingRepositoryProvider);
  return repo.fetchRecording(id);
});

/// Offline detail source: reads cached My List JSON for the current user.
final offlineRecordingDetailProvider =
    FutureProvider.autoDispose.family<Recording?, String>((ref, recordingId) async {
  final userId = ref.read(authSessionProvider).user?.id ?? '';
  if (userId.isEmpty) return null;
  final cache = ref.read(recordingsCacheRepositoryProvider);
  return cache.recordingById(ownerUserId: userId, recordingId: recordingId);
});
