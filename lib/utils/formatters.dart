import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  static String formatCurrency(num amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDayOfWeek(DateTime date) {
    return _dayOfWeekFormat.format(date);
  }

  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  static String formatLiveTime(DateTime time) {
    final now = time;
    return '${twoDigits(now.hour)}:${twoDigits(now.minute)}:${twoDigits(now.second)}';
  }

  static String twoDigits(int value) => value.toString().padLeft(2, '0');

  static String maskPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    final digits = clean.length > 10
        ? clean.substring(clean.length - 10)
        : clean;
    if (digits.length == 10) {
      return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return phone;
  }

  static String maskPhoneHidden(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    final digits = clean.length > 10
        ? clean.substring(clean.length - 10)
        : clean;
    if (digits.length == 10) {
      return '+91 ${digits.substring(0, 2)}••• ••${digits.substring(8)}';
    }
    return phone;
  }
}

/// Auto-formats date input as `DD/MM/YYYY` while typing.
///
/// Inserts `/` after the day (2 digits) and month (4 digits typed).
/// Supports backspace across separators, mid-text editing, and paste.
/// Maximum output length is 10 characters (`DD/MM/YYYY`).
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip everything except digits.
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Cap at 8 raw digits (DDMMYYYY).
    final capped = digits.length > 8 ? digits.substring(0, 8) : digits;

    // Build the formatted string with `/` separators.
    final buf = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 2 || i == 4) buf.write('/');
      buf.write(capped[i]);
    }
    final formatted = buf.toString();

    // Compute the new cursor position: count how many raw digits are before
    // the old cursor in the new (unformatted) value, then map that count to
    // the formatted string position.
    final rawCursor = _rawDigitCount(newValue.text, newValue.selection.end);
    final newCursor = _formattedOffset(formatted, rawCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  /// Counts digits in [text] up to character index [end].
  static int _rawDigitCount(String text, int end) {
    final clampedEnd = end.clamp(0, text.length);
    var count = 0;
    for (var i = 0; i < clampedEnd; i++) {
      if (RegExp(r'\d').hasMatch(text[i])) count++;
    }
    return count;
  }

  /// Finds the character offset in [formatted] after [digitCount] digits.
  static int _formattedOffset(String formatted, int digitCount) {
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        seen++;
        if (seen == digitCount) return i + 1;
      }
    }
    // If digitCount is 0 or exceeds available digits, return start or end.
    return digitCount <= 0 ? 0 : formatted.length;
  }
}
