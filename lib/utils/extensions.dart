import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  String formatAsCurrency() {
    return NumberFormat.currency(
      locale: 'ar_YE',
      symbol: '﷼',
      decimalDigits: 2,
    ).format(this);
  }
}

extension IntExtensions on int {
  String formatAsCurrency() {
    return NumberFormat.currency(
      locale: 'ar_YE',
      symbol: '﷼',
      decimalDigits: 0,
    ).format(this);
  }
}
