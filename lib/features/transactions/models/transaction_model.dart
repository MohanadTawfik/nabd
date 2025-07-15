import 'package:flutter/material.dart';

enum TransactionType { expense, income }

class Transaction {
  final String category;
  final IconData icon;
  final double amount;
  final TransactionType type;
  final DateTime date;

  Transaction({
    required this.category,
    required this.icon,
    required this.amount,
    required this.type,
    required this.date,
  });
}
