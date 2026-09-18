import 'package:flutter_test/flutter_test.dart';
import 'package:agri_queue/utils/aadhaar_validator.dart';

void main() {
  group('AadhaarValidator Tests', () {
    // Helper to calculate Verhoeff check digit for any 11 digits
    int computeVerhoeffCheckDigit(String elevenDigits) {
      const d = [
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
        [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
        [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
        [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
        [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
        [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
        [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
        [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
        [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
      ];
      const p = [
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
        [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
        [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
        [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
        [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
        [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
        [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
      ];
      const inv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9];

      int c = 0;
      final digits = elevenDigits.split('').reversed.toList();
      for (int i = 0; i < digits.length; i++) {
        c = d[c][p[(i + 1) % 8][int.parse(digits[i])]];
      }
      return inv[c];
    }

    test('Normalizes strings by removing spaces, hyphens, and non-digits', () {
      expect(AadhaarValidator.normalize('2345 6789 0123'), '234567890123');
      expect(AadhaarValidator.normalize('2345-6789-0123'), '234567890123');
      expect(AadhaarValidator.normalize('2345.6789/0123'), '234567890123');
      expect(AadhaarValidator.normalize('  2345 6789 0123  '), '234567890123');
    });

    test('Verhoeff algorithm correctly validates valid Aadhaar numbers', () {
      const base = '24893758194';
      final check = computeVerhoeffCheckDigit(base);
      final validNumber = '$base$check';

      expect(AadhaarValidator.validateVerhoeff(validNumber), isTrue);
      expect(AadhaarValidator.validateFormat(validNumber), isNull);
    });

    test('Verhoeff algorithm detects single digit errors and transpositions', () {
      const base = '39281745628';
      final check = computeVerhoeffCheckDigit(base);
      final validNumber = '$base$check';

      // Alter check digit
      final corrupted = '$base${(check + 1) % 10}';
      expect(AadhaarValidator.validateVerhoeff(corrupted), isFalse);
      expect(AadhaarValidator.validateFormat(corrupted), contains('checksum'));

      // Transposition
      final chars = validNumber.split('');
      final temp = chars[0];
      chars[0] = chars[1];
      chars[1] = temp;
      final transposed = chars.join();
      expect(AadhaarValidator.validateVerhoeff(transposed), isFalse);
    });

    test('Rejects invalid lengths', () {
      expect(AadhaarValidator.validateFormat('12345'), contains('12 digits'));
      expect(AadhaarValidator.validateFormat('12345678901234'), contains('12 digits'));
      expect(AadhaarValidator.validateFormat(''), contains('12-digit'));
      expect(AadhaarValidator.validateFormat(null), contains('12-digit'));
    });

    test('Rejects numbers starting with 0 or 1', () {
      expect(AadhaarValidator.validateFormat('012345678901'), contains('cannot start with 0 or 1'));
      expect(AadhaarValidator.validateFormat('112345678901'), contains('cannot start with 0 or 1'));
    });

    test('Masking and grouping formats correctly', () {
      const base = '24893758194';
      final check = computeVerhoeffCheckDigit(base);
      final validNumber = '$base$check';

      final masked = AadhaarValidator.formatMasked(validNumber);
      expect(masked, startsWith('XXXX XXXX '));
      expect(masked, endsWith(validNumber.substring(8)));

      final grouped = AadhaarValidator.formatGrouped(validNumber);
      expect(grouped, equals('${validNumber.substring(0, 4)} ${validNumber.substring(4, 8)} ${validNumber.substring(8)}'));
    });

    test('Verification disclaimer is present and clear', () {
      expect(AadhaarValidator.verificationDisclaimer, contains('Format validation only'));
      expect(AadhaarValidator.verificationDisclaimer, contains('UIDAI'));
    });
  });
}
