import 'package:bcrypt/bcrypt.dart';
import 'package:testimony_transcriber/utils/email_normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Offline auth helpers', () {
    test('BCrypt verifies password against generated hash', () {
      final salt = BCrypt.gensalt(logRounds: 8);
      final hash = BCrypt.hashpw('court_secret_92', salt);
      expect(hash.startsWith(r'$2'), isTrue);
      expect(BCrypt.checkpw('court_secret_92', hash), isTrue);
      expect(BCrypt.checkpw('wrong', hash), isFalse);
    });

    test('email normalization trims and lowercases', () {
      expect(normalizeEmailForAuth('  User@Court.gov  '), 'user@court.gov');
    });
  });
}
