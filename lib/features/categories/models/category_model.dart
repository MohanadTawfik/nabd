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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    final typeStr = (map['type'] ?? 'expense').toString().toLowerCase();
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: IconData(
        map['icon'] ?? Icons.category.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(map['color'] ?? 0xFF888888),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == typeStr,
        orElse: () => TransactionType.expense,
      ),
    );
  }
}
