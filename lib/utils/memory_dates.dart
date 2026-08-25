import 'package:intl/intl.dart';

class MemoryDates {
  static final DateFormat _full = DateFormat('MMMM d, yyyy');
  static final DateFormat _short = DateFormat('MMM d, yyyy');
  static final DateFormat _weekday = DateFormat('EEEE');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');

  static String short(DateTime date) => _short.format(date);

  static String full(DateTime date) => _full.format(date);

  static String monthYear(DateTime date) => _monthYear.format(date);

  static String relative(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 1 && diff < 7) return _weekday.format(date);
    return _short.format(date);
  }
}

int gridColumnsForWidth(double width) {
  if (width >= 1200) return 4;
  if (width >= 840) return 3;
  return 2;
}
