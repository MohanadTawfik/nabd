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

  // Convert to a map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color,
      'type': type.toString().split('.').last,
    };
  }

  // Create from a map (for deserialization)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: IconData(
        map['icon'] ?? Icons.category.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(map['color'] ?? Colors.grey),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${map['type']}',
        orElse: () => TransactionType.expense,
      ),
    );
  }
}
