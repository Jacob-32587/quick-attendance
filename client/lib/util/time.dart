int getWeekOfMonth(DateTime date) {
  final int month = date.month;
  final int year = date.year;

  final int firstWeekday = DateTime(year, month, 1).weekday % 7;
  final int offsetDate = date.day + firstWeekday - 1;

  final int week = 1 + (offsetDate ~/ 7);
  return week;
}
