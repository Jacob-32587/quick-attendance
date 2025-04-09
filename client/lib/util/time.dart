import 'package:intl/intl.dart';

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
