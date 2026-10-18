import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../utils/aadhaar_validator.dart';

/// Result object for Aadhaar OCR scanning.
class AadhaarOcrResult {
  final List<String> candidates;
  final bool isSuccess;
  final String? errorMessage;

  const AadhaarOcrResult({
    required this.candidates,
    required this.isSuccess,
    this.errorMessage,
  });

  factory AadhaarOcrResult.success(List<String> candidates) {
    return AadhaarOcrResult(candidates: candidates, isSuccess: true);
  }

  factory AadhaarOcrResult.failure(String message) {
    return AadhaarOcrResult(
      candidates: const [],
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// Enhanced result containing Aadhaar number, name, and DOB extracted from the card.
class AadhaarScanResult {
  final String aadhaarNumber;
  final String? name;
  final String? dob;
  final bool isNameDetected;
  final bool isDobDetected;

  const AadhaarScanResult({
    required this.aadhaarNumber,
    this.name,
    this.dob,
    this.isNameDetected = false,
    this.isDobDetected = false,
  });
}

/// Service that performs on-device OCR and extracts Aadhaar candidate numbers.
///
/// Privacy guarantees:
/// 1. Processed entirely on-device (offline via Google ML Kit).
/// 2. Never uploads images to any remote server.
/// 3. Captured temporary image files are deleted immediately after processing.
/// 4. Full Aadhaar numbers are never logged in debug outputs or telemetry.
class AadhaarOcrService {
  /// Extracts valid 12-digit Aadhaar candidates from OCR text.
  /// Handles spaced formats (e.g. `1234 5678 9012`), unspaced (`123456789012`),
  /// and hyphenated variants.
  static List<String> extractCandidates(String text) {
    if (text.isEmpty) return const [];

    final Set<String> candidates = {};
    final List<String> verhoeffMatches = [];
    final List<String> formatMatches = [];

    // Pattern 1: 4 digits + separator + 4 digits + separator + 4 digits
    // e.g. "9876 5432 1098" or "9876-5432-1098"
    final spacedRegex = RegExp(
      r'(?:^|[^\d])([2-9]\d{3}[\s\-\–\—\.\/]\d{4}[\s\-\–\—\.\/]\d{4})(?:[^\d]|$)',
      multiLine: true,
    );
    for (final match in spacedRegex.allMatches(text)) {
      final raw = match.group(1);
      if (raw != null) {
        final clean = AadhaarValidator.normalize(raw);
        if (clean.length == 12 &&
            !clean.startsWith('0') &&
            !clean.startsWith('1')) {
          candidates.add(clean);
        }
      }
    }

    // Pattern 2: Continuous 12 digits starting with 2-9
    final continuousRegex = RegExp(
      r'(?:^|[^\d])([2-9]\d{11})(?:[^\d]|$)',
      multiLine: true,
    );
    for (final match in continuousRegex.allMatches(text)) {
      final raw = match.group(1);
      if (raw != null) {
        final clean = AadhaarValidator.normalize(raw);
        if (clean.length == 12 &&
            !clean.startsWith('0') &&
            !clean.startsWith('1')) {
          candidates.add(clean);
        }
      }
    }

    // Pattern 3: Line-by-line fallback for cases where OCR splits across lines
    final lines = text.split('\n');
    for (final line in lines) {
      final cleanLine = AadhaarValidator.normalize(line);
      if (cleanLine.length == 12 &&
          !cleanLine.startsWith('0') &&
          !cleanLine.startsWith('1')) {
        candidates.add(cleanLine);
      }
    }

    // Rank candidates: Verhoeff-verified candidates first
    for (final candidate in candidates) {
      if (AadhaarValidator.validateVerhoeff(candidate)) {
        verhoeffMatches.add(candidate);
      } else {
        formatMatches.add(candidate);
      }
    }

    // If Verhoeff matches are found, return them; otherwise fallback to format matches
    if (verhoeffMatches.isNotEmpty) {
      return verhoeffMatches;
    }
    return formatMatches;
  }

  /// Attempts to extract the cardholder's name from OCR text.
  ///
  /// Heuristic: looks for lines containing "Name" or the Hindi equivalent,
  /// then returns the next non-empty, non-label line as the name.
  static String? extractName(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (lower.contains('name') || lower.contains('\u0928\u093E\u092E')) {
        // "Name" or "नाम"
        if (i + 1 < lines.length) {
          final candidate = lines[i + 1];
          final lowerCandidate = candidate.toLowerCase();
          if (lowerCandidate.contains('dob') ||
              lowerCandidate.contains('gender') ||
              lowerCandidate.contains('male') ||
              lowerCandidate.contains('female') ||
              lowerCandidate.contains('dob') ||
              lowerCandidate.startsWith('/') ||
              RegExp(r'^\d').hasMatch(candidate)) {
            continue;
          }
          final cleaned = candidate
              .replaceAll(RegExp(r'\d+'), '')
              .replaceAll(RegExp(r'[/\\\-]+'), ' ')
              .trim();
          if (cleaned.length >= 2 && cleaned.length <= 60) {
            return cleaned;
          }
        }
      }
    }

    // Fallback: find a line between "GOVERNMENT OF INDIA" and DOB
    int govIdx = -1;
    int dobIdx = -1;
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (lower.contains('government') ||
          lower.contains('\u0938\u0930\u0915\u093E\u0930')) {
        govIdx = i;
      }
      if (lower.contains('dob') ||
          lower.contains('date of birth') ||
          lower.contains('\u091C\u0928\u094D\u092E \u0924\u093F\u0925\u093F')) {
        dobIdx = i;
        break;
      }
    }
    if (govIdx >= 0 && dobIdx > govIdx + 1) {
      for (int i = govIdx + 1; i < dobIdx; i++) {
        final line = lines[i];
        final lower = line.toLowerCase();
        if (lower.contains('govt') ||
            lower.contains('authority') ||
            line.length < 2) {
          continue;
        }
        final cleaned = line
            .replaceAll(RegExp(r'\d+'), '')
            .replaceAll(RegExp(r'[/\\\-]+'), ' ')
            .trim();
        if (cleaned.length >= 2 && cleaned.length <= 60) {
          return cleaned;
        }
      }
    }

    return null;
  }

  /// Attempts to extract a date of birth in DD/MM/YYYY format from OCR text.
  ///
  /// Searches for text near "DOB" keywords first, then falls back to any
  /// plausible date pattern in the text.
  static String? extractDob(String text) {
    // Look near DOB keyword
    final dobKeywords = [
      'dob',
      'date of birth',
      '\u091C\u0928\u094D\u092E \u0924\u093F\u0925\u093F',
    ];
    final lines = text.split('\n');
    for (final line in lines) {
      final lower = line.toLowerCase();
      for (final keyword in dobKeywords) {
        if (lower.contains(keyword)) {
          final dateMatch = RegExp(r'(\d{2})[/\-](\d{2})[/\-](\d{4})')
              .firstMatch(line);
          if (dateMatch != null) {
            return '${dateMatch.group(1)}/${dateMatch.group(2)}/${dateMatch.group(3)}';
          }
          // Date might be on the same line after the keyword
          final afterKeyword = line.substring(
            line.toLowerCase().indexOf(keyword) + keyword.length,
          );
          final dateMatch2 = RegExp(r'(\d{2})[/\-](\d{2})[/\-](\d{4})')
              .firstMatch(afterKeyword);
          if (dateMatch2 != null) {
            return '${dateMatch2.group(1)}/${dateMatch2.group(2)}/${dateMatch2.group(3)}';
          }
        }
      }
    }

    // Fallback: search for any date pattern in DD/MM/YYYY or DD-MM-YYYY format
    final dateRegex = RegExp(r'(\d{2})[/\-](\d{2})[/\-](\d{4})');
    for (final match in dateRegex.allMatches(text)) {
      final year = int.tryParse(match.group(3) ?? '') ?? 0;
      if (year >= 1900 && year <= DateTime.now().year) {
        return '${match.group(1)}/${match.group(2)}/${match.group(3)}';
      }
    }

    return null;
  }

  /// Extracts a complete [AadhaarScanResult] from raw OCR text,
  /// including Aadhaar number, name, and date of birth.
  static AadhaarScanResult extractDetailsFromText(String text) {
    final candidates = extractCandidates(text);
    final aadhaar = candidates.isNotEmpty ? candidates.first : '';
    final name = extractName(text);
    final dob = extractDob(text);

    return AadhaarScanResult(
      aadhaarNumber: aadhaar,
      name: name,
      dob: dob,
      isNameDetected: name != null && name.isNotEmpty,
      isDobDetected: dob != null && dob.isNotEmpty,
    );
  }

  /// Processes an image file using on-device ML Kit Text Recognition.
  ///
  /// Returns [AadhaarOcrResult] with Aadhaar number candidates.
  /// Guarantees immediate deletion of the temporary image file for privacy.
  static Future<AadhaarOcrResult> processImageFile(String filePath) async {
    final file = File(filePath);
    TextRecognizer? textRecognizer;

    try {
      if (!await file.exists()) {
        return AadhaarOcrResult.failure(
          "Couldn't read the captured image. Please try again.",
        );
      }

      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(filePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      final candidates = extractCandidates(recognizedText.text);

      if (candidates.isEmpty) {
        return AadhaarOcrResult.failure(
          "Couldn't read the Aadhaar number. Please place the document inside the frame and try again.",
        );
      }

      return AadhaarOcrResult.success(candidates);
    } catch (e) {
      // Never log full details that might include sensitive data
      if (kDebugMode) {
        debugPrint(
          'Aadhaar OCR processing failed gracefully: ${e.runtimeType}',
        );
      }
      return AadhaarOcrResult.failure(
        "Couldn't read the Aadhaar number. Please place the document inside the frame and try again.",
      );
    } finally {
      // Clean up OCR recognizer
      try {
        await textRecognizer?.close();
      } catch (_) {}

      // PRIVACY REQUIREMENT: Delete temporary captured image immediately
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Temporary capture file cleanup error: ${e.runtimeType}');
        }
      }
    }
  }

  /// Processes an image file and extracts full Aadhaar card details
  /// (Aadhaar number, name, and DOB).
  ///
  /// Returns [AadhaarScanResult] with all extractable fields.
  /// Guarantees immediate deletion of the temporary image file for privacy.
  static Future<AadhaarScanResult?> processImageFileFull(
    String filePath,
  ) async {
    final file = File(filePath);
    TextRecognizer? textRecognizer;

    try {
      if (!await file.exists()) return null;

      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(filePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      final candidates = extractCandidates(recognizedText.text);
      if (candidates.isEmpty) return null;

      return extractDetailsFromText(recognizedText.text);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Aadhaar OCR full processing failed: ${e.runtimeType}');
      }
      return null;
    } finally {
      try {
        await textRecognizer?.close();
      } catch (_) {}
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }
}
