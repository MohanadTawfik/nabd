import 'package:flutter/material.dart';

class Goal {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  double savedAmount;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? targetDate;

  Goal({
    required this.id,
    required this.name,
    required this.icon,
    required this.totalAmount,
    required this.color,
    this.savedAmount = 0.0,
    DateTime? createdAt,
    this.targetDate,
  }) : this.createdAt = createdAt ?? DateTime.now();
  
  // Calculate progress percentage
  double get progressPercentage => savedAmount / totalAmount;
  
  // Calculate remaining amount
  double get remainingAmount => totalAmount - savedAmount;
  
  // Convert Goal to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'savedAmount': savedAmount,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  // Factory method to create a Goal from a map
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
      savedAmount: map['savedAmount'] ?? 0.0,
      totalAmount: map['totalAmount'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
    );
  }
}
