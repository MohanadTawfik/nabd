import 'package:flutter/material.dart';


enum TransactionType { expense, income }

class Transaction {
  // 1. إضافة ID فريد لكل معاملة
  final String id;
  final String category;
  final IconData icon;
  final double amount;
  final TransactionType type;
  final DateTime date;

  Transaction({
    required this.id, // ID مطلوب الآن
    required this.category,
    required this.icon,
    required this.amount,
    required this.type,
    required this.date,
  });
}
