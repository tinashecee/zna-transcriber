import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:testimony_transcriber/data/models/recording_model.dart';

void main() {
  test('My List JSON round-trips through RecordingModel for cache storage', () {
    final map = <String, dynamic>{
      'id': 1017359,
      'case_number': 'CRB 12/24',
      'title': 'State v X',
      'court': 'High Court Harare',
      'courtroom': 'Court 3',
      'judge_name': 'Hon J',
      'prosecution_counsel': 'A',
      'defense_counsel': 'B',
      'date_stamp': '2025-01-15T10:00:00',
      'transcript_status': 'completed',
      'file_path': '/a/b.wav',
      'duration': 120.5,
      'annotations': [],
    };
    final json = jsonEncode(map);
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    final entity = RecordingModel.fromJson(decoded).toEntity();
    expect(entity.id, '1017359');
    expect(entity.caseNumber, 'CRB 12/24');
    expect(entity.durationSeconds, 120.5);
  });
}
