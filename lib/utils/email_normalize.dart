/// Matches typical server behavior: trim + lowercase for lookups.
String normalizeEmailForAuth(String email) =>
    email.trim().toLowerCase();
