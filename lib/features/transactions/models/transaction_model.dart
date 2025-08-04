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

  static Transaction fromMap(
    Map<String, dynamic> map, {
    dynamic categoriesProvider,
  }) {
    final categoryId = map['categoryId']?.toString();

    // Try to get the category from the provider if available
    if (categoriesProvider != null && categoryId != null) {
      try {
        final foundCategory = categoriesProvider.getCategoryById(categoryId);
        if (foundCategory != null) {
          return _createTransactionFromMap(map, foundCategory);
        }
      } catch (e) {
        debugPrint('Error loading category: $e');
        // Fall through to create default category
      }
    }

    // Fallback to a default category if not found or if provider is not available
    final typeStr = (map['type'] ?? 'expense').toString().toLowerCase();
    final defaultCategory = Category(
      id: categoryId ?? '',
      name: 'غير مصنف',
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == typeStr,
        orElse: () => TransactionType.expense,
      ),
      color: const Color(0xFF888888),
      icon: Icons.category,
    );

    return _createTransactionFromMap(map, defaultCategory);
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

  // Helper method to create a transaction from map with a given category
  static Transaction _createTransactionFromMap(
    Map<String, dynamic> map,
    Category category,
  ) {
    final typeStr = (map['type'] ?? 'expense').toString().toLowerCase();
    return Transaction(
      id: map['id'],
      category: category,
      amount: map['amount'] is int
          ? (map['amount'] as int).toDouble()
          : map['amount'] is double
              ? map['amount']
              : 0.0,
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == typeStr,
        orElse: () => TransactionType.expense,
      ),
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      source: map['source'],
    );
  }

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
