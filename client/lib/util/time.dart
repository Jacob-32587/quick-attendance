import 'package:intl/intl.dart';

int? getWeekOfMonthNullable(DateTime? date) {
  if (date == null) {
    return null;
  }
  return getWeekOfMonth(date);
}

int getWeekOfMonth(DateTime date) {
  final int month = date.month;
  final int year = date.year;

  final int firstWeekday = DateTime(year, month, 1).weekday % 7;
  final int offsetDate = date.day + firstWeekday - 1;

  final int week = 1 + (offsetDate ~/ 7);
  return week;
}

String formatDate(DateTime? date) {
  if (date == null) {
    return "";
  }

  final day = date.day;
  final suffix = _getDaySuffix(day);
  final month = DateFormat.MMMM().format(date);
  final year = date.year;

  return '$month $day$suffix, $year';
}

String _getDaySuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

/// Returns a 12hour AM PM string from the provided DateTime object. Returns blank if null.
String displayTimeOfDateTime(DateTime? date) {
  if (date == null) {
    return "";
  }
  final DateFormat timeFormat = DateFormat('hh:mm a');
  return timeFormat.format(date);
}
