import '../models/slot.dart';

class VoiceParsedRequest {
  final String? cropId;
  final int? targetHour;
  final String rawText;

  const VoiceParsedRequest({
    this.cropId,
    this.targetHour,
    required this.rawText,
  });

  bool get isComplete => cropId != null && targetHour != null;
}

class SlotMatch {
  final MandiSlot slot;
  final int hourDifference;

  const SlotMatch(this.slot, this.hourDifference);
}

class VoiceBookingService {
  const VoiceBookingService._();

  static const Map<String, String> _cropSynonyms = {
    'wheat': 'wheat',
    'गेहूं': 'wheat',
    'गेहूँ': 'wheat',
    'गेहुं': 'wheat',
    'gehu': 'wheat',
    'gehun': 'wheat',
    'gahu': 'wheat',
    'कनक': 'wheat',
    'paddy': 'paddy',
    'धान': 'paddy',
    'चावल': 'paddy',
    'dhan': 'paddy',
    'paddi': 'paddy',
    'chawal': 'paddy',
    'rice': 'paddy',
    'mustard': 'mustard',
    'सरसों': 'mustard',
    'sarson': 'mustard',
    'saraso': 'mustard',
    'raya': 'mustard',
    'maize': 'maize',
    'भुट्टा': 'maize',
    'मक्का': 'maize',
    'makka': 'maize',
    'bhutta': 'maize',
    'makai': 'maize',
    'corn': 'maize',
    'sugarcane': 'sugarcane',
    'गन्ना': 'sugarcane',
    'गन्ने': 'sugarcane',
    'ganna': 'sugarcane',
    'ikkar': 'sugarcane',
    'potato': 'potato',
    'आलू': 'potato',
    'ालू': 'potato',
    'alu': 'potato',
    'aloo': 'potato',
  };

  static const List<String> _availableCropIds = [
    'wheat',
    'paddy',
    'mustard',
    'maize',
    'sugarcane',
    'potato',
  ];

  /// Parses a crop ID out of recognized speech. Returns null when no known
  /// crop is present in [text].
  static String? recognizeCrop(String text) {
    final normalized = _normalize(text);
    for (final entry in _cropSynonyms.entries) {
      final word = _normalize(entry.key);
      if (word.isEmpty) continue;
      if (normalized.contains(word)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Parses an hour (0-23) from recognized speech. Understands phrases like
  /// "9", "9 AM", "9:00", "9 a.m.", "नौ बजे", "सुबह 9", "रात 10", "11 baje".
  static int? recognizeHour(String text) {
    final normalized = _normalize(text);

    // Hindi/English hour words
    const hourWords = {
      'one': 1,
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
      'six': 6,
      'seven': 7,
      'eight': 8,
      'nine': 9,
      'ten': 10,
      'eleven': 11,
      'twelve': 12,
      'एक': 1,
      'दो': 2,
      'तीन': 3,
      'चार': 4,
      'पांच': 5,
      'पाँच': 5,
      'छह': 6,
      'छः': 6,
      'सात': 7,
      'आठ': 8,
      'नौ': 9,
      'दस': 10,
      'ग्यारह': 11,
      'बारह': 12,
    };

    for (final entry in hourWords.entries) {
      final word = _normalize(entry.key);
      if (word.isEmpty) continue;
      if (_containsWord(normalized, word)) {
        return _applyMeridian(normalized, entry.value);
      }
    }

    // Numeric: "9", "9:00", "9.00", "9 am", "11 baje"
    final numericPattern = RegExp(r'\b(\d{1,2})(?::|\.)?(\d{0,2})\b');
    for (final match in numericPattern.allMatches(normalized)) {
      final hourRaw = match.group(1);
      if (hourRaw == null) continue;
      var hour = int.tryParse(hourRaw);
      if (hour == null || hour < 1 || hour > 12) continue;
      return _applyMeridian(normalized, hour);
    }

    return null;
  }

  static int _applyMeridian(String normalized, int hour12) {
    if (hour12 == 12) {
      if (normalized.contains('am') || normalized.contains('सुबह')) {
        return 0;
      }
      if (normalized.contains('pm') ||
          normalized.contains('शाम') ||
          normalized.contains('रात')) {
        return 12;
      }
      return 12;
    }
    final isPm =
        normalized.contains('pm') ||
        normalized.contains('p m') ||
        normalized.contains('सायं') ||
        normalized.contains('शाम') ||
        normalized.contains('रात');
    final isAm =
        normalized.contains('am') ||
        normalized.contains('a m') ||
        normalized.contains('सुबह') ||
        normalized.contains('प्रातः');
    if (isPm) return hour12 + 12;
    if (isAm) return hour12;
    // No meridian given -> assume daytime working hours (9-17).
    if (hour12 >= 6 && hour12 <= 12) return hour12;
    return 12 + hour12;
  }

  /// Finds the closest available slots to [targetHour] for [cropId],
  /// preferring the same day first. Slots that are full are excluded.
  static List<SlotMatch> findBestSlots({
    required List<MandiSlot> slots,
    required String cropId,
    required int targetHour,
  }) {
    final matches = slots
        .where(
          (s) =>
              s.crop == cropId &&
              s.status != SlotStatus.full &&
              s.availableCapacity > 0,
        )
        .map((slot) {
          final hour = _slotStartHour(slot.timeRange);
          return SlotMatch(slot, hour - targetHour);
        })
        .toList();

    matches.sort((a, b) {
      final diffCompare = a.hourDifference.abs().compareTo(
        b.hourDifference.abs(),
      );
      if (diffCompare != 0) return diffCompare;
      return a.slot.date.compareTo(b.slot.date);
    });

    return matches;
  }

  static int _slotStartHour(String timeRange) {
    final match = RegExp(r'(\d{1,2})(?::\d{2})?\s*(am|pm)')
        .firstMatch(timeRange.toLowerCase());
    if (match == null) return 6;
    var hour = int.parse(match.group(1)!);
    final meridiem = match.group(2)!;
    if (meridiem == 'pm' && hour != 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;
    return hour;
  }

  static String _normalize(String text) => text.trim().toLowerCase();

  static bool _containsWord(String haystack, String needle) {
    if (haystack == needle) return true;
    final escaped = RegExp.escape(needle);
    return RegExp('(^|[^a-z0-9])$escaped([^a-z0-9]|\$)').hasMatch(haystack);
  }

  static bool supportsCrop(String cropId) => _availableCropIds.contains(cropId);
}
