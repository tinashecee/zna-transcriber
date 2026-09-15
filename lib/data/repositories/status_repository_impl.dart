import '../../domain/repositories/status_repository.dart';
import '../api/api_client.dart';

class StatusRepositoryImpl implements StatusRepository {
  StatusRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> updateStatus({
    required String recordingId,
    required String status,
  }) async {
    // Normalize status to lowercase (API accepts: pending, inprogress, completed)
    final normalizedStatus = status.toLowerCase().replaceAll('_', '');
    
    print('[StatusRepository] PUT /case_recordings/$recordingId/update_status body={"transcript_status": "$normalizedStatus"}');
    
    final response = await _client.dio.put(
      '/case_recordings/$recordingId/update_status',
      data: {'transcript_status': normalizedStatus},
    );
    
    print('[StatusRepository] Response: ${response.data}');
    
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<Map<String, dynamic>> sendForProofread({
    required String recordingId,
    required String magistrateUserId,
    bool alsoCompleteStatus = true,
  }) async {
    // API expects an int when IDs are numeric; send as int when possible.
    final dynamic magistrateId =
        int.tryParse(magistrateUserId.trim()) ?? magistrateUserId.trim();

    print(
      '[StatusRepository] POST /case_recordings/$recordingId/send_for_proofread '
      'magistrate_user_id=$magistrateId also_complete_status=$alsoCompleteStatus',
    );

    final response = await _client.dio.post(
      '/case_recordings/$recordingId/send_for_proofread',
      data: {
        'magistrate_user_id': magistrateId,
        'also_complete_status': alsoCompleteStatus,
      },
    );

    print('[StatusRepository] sendForProofread response: ${response.data}');
    return response.data as Map<String, dynamic>? ?? {};
  }
}
