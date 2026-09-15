/// Helpers for annotation timestamps stored by the recording app.
///
/// Annotations use **milliseconds from the start of the recording session**
/// (not Unix time, not wall-clock). Manual edits may use `mm:ss` or `hh:mm:ss`.
Duration? parseAnnotationTimestamp(dynamic value) {
  final seconds = _parseToSeconds(value);
  if (seconds == null) return null;
  return Duration(milliseconds: (seconds * 1000).round());
}

/// Seconds from session start, or null when [value] cannot be parsed.
double? _parseToSeconds(dynamic value) {
  if (value == null) return null;
  if (value is num) {
    // Recording app stores ms integers (e.g. 2305000 -> 38:25).
    return value.toDouble() / 1000;
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'N/A') return null;
    if (trimmed.contains(':')) {
      final parts =
          trimmed.split(':').map((e) => double.tryParse(e) ?? 0).toList();
      if (parts.length == 3) {
        return parts[0] * 3600 + parts[1] * 60 + parts[2];
      }
      if (parts.length == 2) {
        return parts[0] * 60 + parts[1];
      }
      if (parts.length == 1) {
        return parts[0];
      }
    }
    final asNum = double.tryParse(trimmed);
    if (asNum == null) return null;
    return asNum / 1000;
  }
  return null;
}

/// Formats an annotation timestamp as `HH:MM:SS`.
String formatAnnotationTimestamp(dynamic value) {
  final duration = parseAnnotationTimestamp(value);
  if (duration == null) return 'N/A';
  String two(int n) => n.toString().padLeft(2, '0');
  final hours = two(duration.inHours);
  final minutes = two(duration.inMinutes.remainder(60));
  final secs = two(duration.inSeconds.remainder(60));
  return '$hours:$minutes:$secs';
}
