import 'package:logging/logging.dart';

Uri? buildRecordingAudioUri({
  required String baseUrl,
  required String audioPath,
  Logger? logger,
}) {
  final trimmed = audioPath.trim();
  if (trimmed.isEmpty) return null;
  final parsed = Uri.tryParse(trimmed);
  if (parsed != null && parsed.hasScheme) {
    logger?.info('[AudioUri] Using absolute audio URL: $parsed');
    return parsed;
  }

  var normalized =
      trimmed.replaceAll('\\', '/').replaceFirst(RegExp(r'^/+'), '');
  final recordingsIndex = normalized.indexOf('recordings/');
  if (recordingsIndex >= 0) {
    normalized = normalized.substring(recordingsIndex + 'recordings/'.length);
  } else if (normalized.contains('media/recordings/')) {
    normalized = normalized.split('media/recordings/').last;
  }

  final filename = normalized.split('/').last;
  final base = Uri.parse(baseUrl);
  final resolved = base.replace(
    pathSegments: [
      ...base.pathSegments.where((segment) => segment.isNotEmpty),
      'test_stream',
      filename,
    ],
  );
  logger?.info(
    '[AudioUri] input="$audioPath" normalized="$normalized" filename="$filename" '
    'final="$resolved"',
  );
  return resolved;
}

Uri? buildMp3FallbackUri({
  required String baseUrl,
  required String audioPath,
  Logger? logger,
}) {
  final trimmed = audioPath.trim();
  if (!trimmed.toLowerCase().endsWith('.wav')) return null;
  final mp3Path = trimmed.substring(0, trimmed.length - 4) + '.mp3';
  return buildRecordingAudioUri(
    baseUrl: baseUrl,
    audioPath: mp3Path,
    logger: logger,
  );
}

