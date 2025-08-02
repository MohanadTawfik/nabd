import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';

enum TransactionType { expense, income, transfer }

class Transaction {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': category.id,
      'amount': amount,
      'type': type.toString().split('.').last,
      'date': date.toIso8601String(),
      'notes': notes,
      'source': source,
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    // You will need to fetch the Category by id from your provider or pass it in
    // For now, this is a placeholder and should be replaced with actual category lookup
    final dummyCategory = Category(
      id: map['categoryId'] ?? '',
      name: 'غير مصنف',
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == (map['type'] ?? 'expense'),
        orElse: () => TransactionType.expense,
      ),
      color: const Color(0xFF888888),
      icon: Icons.category,
    );
    return Transaction(
      id: map['id'],
      category: dummyCategory, // TODO: Replace with actual category lookup
      amount: map['amount'] is int
          ? (map['amount'] as int).toDouble()
          : map['amount'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == (map['type'] ?? 'expense'),
        orElse: () => TransactionType.expense,
      ),
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      source: map['source'],
    );
  }

  final String id;
  // 1. الآن نحفظ كائن الفئة بالكامل، وليس مجرد اسمها
  final Category category;
  final double amount;
  final TransactionType type;
  final DateTime date;
  // حقل الملاحظات
  final String? notes;
  final String? source; // مثلاً: 'OCR', 'NLP', 'Excel'

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.notes,
    this.source,
  });
}
