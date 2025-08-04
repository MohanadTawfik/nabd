import 'package:intl/intl.dart';

extension CurrencyExtension on double {
  String toCurrencyString() {
    final formatter = NumberFormat.currency(
      symbol: '﷼',
      decimalDigits: 2,
      locale: 'ar_YE',
    );
    return formatter.format(this);
  }
}

extension IntCurrencyExtension on int {
  String toCurrencyString() {
    return toDouble().toCurrencyString();
  }
}
