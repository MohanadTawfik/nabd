import 'package:intl/intl.dart';

/// Utility class for currency formatting
class CurrencyFormatter {
  /// Format amount to currency string
  static String format(double amount, {String currencySymbol = 'ر.ي', bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'ar',
      symbol: showSymbol ? currencySymbol : '',
      decimalDigits: 2,
    );
    
    return formatter.format(amount);
  }

  /// Format amount to compact currency string (e.g. 1K, 1M)
  static String formatCompact(double amount, {String currencySymbol = 'ر.ي', bool showSymbol = true}) {
    final formatter = NumberFormat.compactCurrency(
      locale: 'ar',
      symbol: showSymbol ? currencySymbol : '',
      decimalDigits: 1,
    );
    
    return formatter.format(amount);
  }

  /// Parse currency string to double
  static double parse(String amount) {
    // Remove currency symbol and non-numeric characters except decimal point
    final cleanedAmount = amount.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanedAmount) ?? 0.0;
  }
}