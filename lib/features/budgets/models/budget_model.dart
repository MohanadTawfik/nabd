import 'package:flutter/material.dart';

class Budget {
  final String categoryName;
  final IconData icon;
  final double totalAmount;

  // المبلغ المصروف سيتم حسابه لاحقاً
  double spentAmount;

  Budget({
    required this.categoryName,
    required this.icon,
    required this.totalAmount,
    this.spentAmount = 0.0,
  });
}
