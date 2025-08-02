import 'package:intl/intl.dart';

/// Format a DateTime object to a readable string format
String formatDate(DateTime date) {
  // Format: 12 يناير 2023
  final DateFormat formatter = DateFormat('d MMMM yyyy', 'ar');
  return formatter.format(date);
}

/// Format a DateTime object to a short date format
String formatShortDate(DateTime date) {
  // Format: 12/01/2023
  final DateFormat formatter = DateFormat('d/M/yyyy', 'ar');
  return formatter.format(date);
}

/// Format a DateTime object to show only month and year
String formatMonthYear(DateTime date) {
  // Format: يناير 2023
  final DateFormat formatter = DateFormat('MMMM yyyy', 'ar');
  return formatter.format(date);
}

/// Format a DateTime object to show only time
String formatTime(DateTime date) {
  // Format: 14:30
  final DateFormat formatter = DateFormat('HH:mm', 'ar');
  return formatter.format(date);
}

/// Format a double amount to currency format
String formatCurrency(double amount) {
  // Format: 1,234.56 ر.س
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'ar_SA',
    symbol: 'ر.س',
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

/// Format a double amount to percentage format
String formatPercentage(double percentage) {
  // Format: 12.34%
  final NumberFormat formatter = NumberFormat.percentPattern('ar');
  return formatter.format(percentage / 100);
}

/// Format a double amount to compact currency format (for small spaces)
String formatCompactCurrency(double amount) {
  // Format: 1.2ألف ر.س
  final NumberFormat formatter = NumberFormat.compactCurrency(
    locale: 'ar_SA',
    symbol: 'ر.س',
    decimalDigits: 1,
  );
  return formatter.format(amount);
}

/// Format a number with thousand separators
String formatNumber(num number) {
  // Format: 1,234
  final NumberFormat formatter = NumberFormat('#,###', 'ar');
  return formatter.format(number);
}
