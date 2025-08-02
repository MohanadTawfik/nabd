import 'package:intl/intl.dart';

/// Utility class for date operations
class DateUtils {
  /// Format date to localized string
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format, 'ar').format(date);
  }

  /// Format date to localized string with time
  static String formatDateTime(DateTime date, {String format = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(format, 'ar').format(date);
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// Get date range for a period
  static DateTimeRange getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    
    switch (period) {
      case 'today':
        return DateTimeRange(
          start: startOfDay(now),
          end: endOfDay(now),
        );
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: startOfDay(yesterday),
          end: endOfDay(yesterday),
        );
      case 'thisWeek':
        // Assuming week starts on Sunday (adjust as needed)
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday % 7));
        return DateTimeRange(
          start: startOfDay(firstDayOfWeek),
          end: endOfDay(now),
        );
      case 'thisMonth':
        return DateTimeRange(
          start: startOfMonth(now),
          end: endOfDay(now),
        );
      case 'lastMonth':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return DateTimeRange(
          start: startOfMonth(lastMonth),
          end: endOfMonth(lastMonth),
        );
      case 'thisYear':
        return DateTimeRange(
          start: startOfYear(now),
          end: endOfDay(now),
        );
      default:
        return DateTimeRange(
          start: startOfMonth(now),
          end: endOfDay(now),
        );
    }
  }
}

/// Extension class for DateTimeRange
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});

  /// Check if a date is within this range
  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end) || 
           date.isAtSameMomentAs(start) || 
           date.isAtSameMomentAs(end);
  }

  /// Get the duration of this range
  Duration get duration => end.difference(start);

  /// Get the number of days in this range
  int get days => duration.inDays + 1;
}