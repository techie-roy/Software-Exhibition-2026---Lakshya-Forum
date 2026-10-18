import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:agri_queue/services/aadhaar_ocr_service.dart';

void main() {
  group('AadhaarOcrService Extraction Tests', () {
    test('Extracts candidate from spaced 4-4-4 format', () {
      const text =
          'Unique Identification Authority of India\n5432 1098 7654\nGovernment of India';
      final candidates = AadhaarOcrService.extractCandidates(text);

      expect(candidates, contains('543210987654'));
    });

    test('Extracts candidate from continuous 12-digit format', () {
      const text = 'UIDAI Card 543210987654 Farmer';
      final candidates = AadhaarOcrService.extractCandidates(text);

      expect(candidates, contains('543210987654'));
    });

    test('Ignores non-12-digit numbers (PIN codes, phone, helpline, DOB)', () {
      const noisyText = '''
        GOVERNMENT OF INDIA
        Name: Ramesh Patel
        DOB: 12/05/1985
        Gender: Male
        Phone: 9876543210
        Pin Code: 226001
        Toll Free: 1947
      ''';
      // Notice: 9876543210 is 10 digits (phone), 226001 is 6 digits (PIN), 1947 is 4 digits.
      // None of them are 12 digits.
      final candidates = AadhaarOcrService.extractCandidates(noisyText);

      expect(candidates, isEmpty);
    });

    test('Extracts only 12-digit candidate from mixed realistic OCR text', () {
      const realisticCardText = '''
        भारत सरकार
        GOVERNMENT OF INDIA
        राकेश कुमार / Rakesh Kumar
        जन्म तिथि / DOB: 15/08/1980
        पुरुष / MALE
        3928 1745 6289
        मेरा आधार, मेरी पहचान
        1947
      ''';

      final candidates = AadhaarOcrService.extractCandidates(realisticCardText);
      expect(candidates.length, equals(1));
      expect(candidates.first, equals('392817456289'));
    });

    test('Detects multiple candidates when document contains multiple 12-digit numbers', () {
      const text = '''
        Primary Aadhaar: 3928 1745 6289
        Secondary Aadhaar: 5821 4902 3814
      ''';

      final candidates = AadhaarOcrService.extractCandidates(text);
      expect(candidates.length, equals(2));
      expect(candidates, contains('392817456289'));
      expect(candidates, contains('582149023814'));
    });

    test('Ignores candidates starting with 0 or 1', () {
      const text = 'Invalid: 0123 4567 8901 and 1928 3746 5829';
      final candidates = AadhaarOcrService.extractCandidates(text);

      expect(candidates, isEmpty);
    });

    test('Returns empty list for empty or non-numeric text', () {
      expect(AadhaarOcrService.extractCandidates(''), isEmpty);
      expect(
        AadhaarOcrService.extractCandidates('Just random text without numbers'),
        isEmpty,
      );
    });

    test('processImageFile handles non-existent file gracefully', () async {
      final result = await AadhaarOcrService.processImageFile(
        'non_existent_file.jpg',
      );
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains("Couldn't read"));
    });

    test('Privacy: deletes temporary image file after processing attempt', () async {
      // Create a temporary mock image file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/test_aadhaar_ocr_cleanup_${DateTime.now().millisecondsSinceEpoch}.tmp',
      );
      await tempFile.writeAsString('dummy file content for privacy testing');

      expect(await tempFile.exists(), isTrue);

      // Attempt processing
      await AadhaarOcrService.processImageFile(tempFile.path);

      // Verify that the file was deleted in the finally block
      expect(await tempFile.exists(), isFalse);
    });
  });
}
