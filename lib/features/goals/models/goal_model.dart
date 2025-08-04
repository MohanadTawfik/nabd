import 'package:flutter/material.dart';

class Goal {
  final String id;
  final String name;
  final String? description;
  final IconData icon;
  final Color color;
  double savedAmount;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? targetDate;
  DateTime? updatedAt;

  Goal({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.totalAmount,
    required this.color,
    this.savedAmount = 0.0,
    DateTime? createdAt,
    this.targetDate,
    this.updatedAt,
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
      description: map['description'],
      icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
      savedAmount: map['savedAmount'] ?? 0.0,
      totalAmount: map['totalAmount'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
  
  // Create a copy of the goal with updated fields
  Goal copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    double? savedAmount,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      savedAmount: savedAmount ?? this.savedAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
