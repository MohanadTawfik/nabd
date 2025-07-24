import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';

enum TransactionType { expense, income, debt }

class Transaction {
  final String id;
  // 1. الآن نحفظ كائن الفئة بالكامل، وليس مجرد اسمها
  final Category category;
  final double amount;
  final TransactionType type;
  final DateTime date;
  // حقل الملاحظات
  final String notes;

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.notes = '',
  });
}
