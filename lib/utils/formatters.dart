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
