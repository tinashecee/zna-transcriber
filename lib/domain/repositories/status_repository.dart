abstract class StatusRepository {
  /// Update the transcript status of a recording
  /// Returns the response from the API: {message, recording_id, transcript_status}
  Future<Map<String, dynamic>> updateStatus({
    required String recordingId,
    required String status,
  });

  /// Request magistrate proof-read (and optionally mark the case completed).
  /// POST /case_recordings/:id/send_for_proofread
  Future<Map<String, dynamic>> sendForProofread({
    required String recordingId,
    required String magistrateUserId,
    bool alsoCompleteStatus = true,
  });
}
