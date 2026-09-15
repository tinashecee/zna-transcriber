/// Normalizes province names for case-insensitive comparison.
String normalizeProvince(String? value) {
  if (value == null) return '';
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

/// Common spelling variants (e.g. profile vs courts API).
String canonicalProvinceKey(String normalized) {
  return normalized.replaceAll('matebeleland', 'matabeleland');
}

/// True when both values refer to the same province (case/spacing insensitive).
bool provincesMatch(String? a, String? b) {
  final na = canonicalProvinceKey(normalizeProvince(a));
  final nb = canonicalProvinceKey(normalizeProvince(b));
  if (na.isEmpty || nb.isEmpty) return false;
  return na == nb;
}
