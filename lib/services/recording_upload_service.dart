import 'dart:io';

import 'package:dio/dio.dart';

class RecordingUploadService {
  RecordingUploadService({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  static const int _defaultChunkSizeBytes = 5 * 1024 * 1024; // 5MB

  Future<String> uploadV2({
    required File file,
    required String filename,
    required CancelToken cancelToken,
    required void Function(double progress01) onProgress,
    int chunkSizeBytes = _defaultChunkSizeBytes,
  }) async {
    final totalBytes = await file.length();
    if (totalBytes <= 0) {
      throw Exception('File is empty');
    }

    onProgress(0.0);

    final initResp = await _dio.post<Map<String, dynamic>>(
      '/upload_v2_init',
      data: {
        'filename': filename,
        'total_bytes': totalBytes.toString(),
      },
      cancelToken: cancelToken,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final initData = initResp.data ?? const <String, dynamic>{};
    final uploadId = (initData['upload_id'] ?? '').toString();
    final serverFilename = (initData['filename'] ?? filename).toString();
    if (uploadId.trim().isEmpty) {
      throw Exception('Upload init failed: missing upload_id');
    }

    final raf = await file.open();
    try {
      int start = 0;
      while (start < totalBytes) {
        final endExclusive = (start + chunkSizeBytes) > totalBytes
            ? totalBytes
            : (start + chunkSizeBytes);
        final endInclusive = endExclusive - 1;

        await raf.setPosition(start);
        final chunk = await raf.read(endExclusive - start);

        await _dio.put<void>(
          '/upload_v2_chunk/$uploadId',
          data: Stream<List<int>>.fromIterable([chunk]),
          cancelToken: cancelToken,
          options: Options(
            contentType: 'application/octet-stream',
            responseType: ResponseType.plain,
            headers: {
              'Content-Range': 'bytes $start-$endInclusive/$totalBytes',
              Headers.contentLengthHeader: chunk.length,
            },
          ),
        );

        start = endExclusive;
        onProgress(start / totalBytes);
      }
    } finally {
      await raf.close();
    }

    final completeResp = await _dio.post<Map<String, dynamic>>(
      '/upload_v2_complete/$uploadId',
      cancelToken: cancelToken,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final done = completeResp.data ?? const <String, dynamic>{};
    final finalFilename = (done['filename'] ?? serverFilename).toString();
    if (finalFilename.trim().isEmpty) {
      throw Exception('Upload complete failed: missing filename');
    }
    onProgress(1.0);
    return finalFilename;
  }

  Future<String> postRecordingMetadata({
    required Map<String, String> fields,
    required CancelToken cancelToken,
  }) async {
    final resp = await _dio.post<dynamic>(
      '/upload_recording',
      data: fields,
      cancelToken: cancelToken,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = resp.data;
      if (data is Map) {
        final id = (data['id'] ?? data['recording_id'] ?? '').toString();
        return id.isEmpty ? 'ok' : id;
      }
      return 'ok';
    }
    throw Exception('Metadata upload failed: HTTP ${resp.statusCode}');
  }
}

