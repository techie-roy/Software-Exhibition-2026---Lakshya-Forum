/// Aadhaar format validation and utility routines.
///
/// Note: This performs client-side format and Verhoeff checksum validation.
/// It distinguishes format correctness from actual government identity verification.
class AadhaarValidator {
  static const String verificationDisclaimer =
      'Format validation only. This does not verify identity or authenticity with UIDAI.';

  // Verhoeff algorithm tables
  static const List<List<int>> _d = [
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

  static const List<List<int>> _p = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
  ];

  /// Strips all spaces, hyphens, and non-digit characters.
  static String normalize(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  /// Validates a numeric string using the Verhoeff checksum algorithm.
  static bool validateVerhoeff(String numStr) {
    final clean = normalize(numStr);
    if (clean.isEmpty) return false;

    int c = 0;
    final chars = clean.split('').reversed.toList();
    for (int i = 0; i < chars.length; i++) {
      final digit = int.tryParse(chars[i]);
      if (digit == null) return false;
      c = _d[c][_p[i % 8][digit]];
    }
    return c == 0;
  }

  /// Validates if the given string satisfies the 12-digit Aadhaar format requirements:
  /// - Non-empty
  /// - Exactly 12 digits after normalization
  /// - First digit cannot be 0 or 1
  /// - Passes Verhoeff checksum
  static String? validateFormat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your 12-digit Aadhaar number';
    }

    final normalized = normalize(value);
    if (normalized.length != 12) {
      return 'Aadhaar number must be exactly 12 digits';
    }

    if (normalized.startsWith('0') || normalized.startsWith('1')) {
      return 'Aadhaar number cannot start with 0 or 1';
    }

    if (!validateVerhoeff(normalized)) {
      return 'Invalid Aadhaar number (checksum failed)';
    }

    return null;
  }

  /// Formats a 12-digit number as masked: `XXXX XXXX 1234`
  static String formatMasked(String value) {
    final clean = normalize(value);
    if (clean.length == 12) {
      return 'XXXX XXXX ${clean.substring(8)}';
    }
    return value;
  }

  /// Formats a 12-digit number with standard 4-digit grouping: `1234 5678 9012`
  static String formatGrouped(String value) {
    final clean = normalize(value);
    if (clean.length == 12) {
      return '${clean.substring(0, 4)} ${clean.substring(4, 8)} ${clean.substring(8)}';
    }
    return value;
  }
}
