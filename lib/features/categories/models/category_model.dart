import 'package:flutter/material.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';

class Category {
  final String id;
  String name;
  IconData icon;
  Color color;
  final TransactionType type;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}
