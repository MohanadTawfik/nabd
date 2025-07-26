import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';

enum BudgetPeriod { weekly, monthly, yearly, custom }

class Budget {
  final String id;
  final Category category;
  final double totalAmount;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPeriod period;
  final bool receiveNotifications;
  final double notificationThreshold; // Percentage (0-100)
  double spentAmount;

  Budget({
    String? id,
    required this.category,
    required this.totalAmount,
    DateTime? startDate,
    DateTime? endDate,
    this.period = BudgetPeriod.monthly,
    this.receiveNotifications = true,
    this.notificationThreshold = 80.0,
    this.spentAmount = 0.0,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? _calculateEndDate(DateTime.now(), period);

  static DateTime _calculateEndDate(DateTime startDate, BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return startDate.add(const Duration(days: 7));
      case BudgetPeriod.monthly:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case BudgetPeriod.yearly:
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
      case BudgetPeriod.custom:
        return startDate.add(const Duration(days: 30)); // Default 30 days
    }
  }

  double get remainingAmount => (totalAmount - spentAmount).clamp(0, double.infinity);
  
  double get progressPercentage => totalAmount > 0 
      ? (spentAmount / totalAmount * 100).clamp(0, 100) 
      : 0;

  bool get isExceeded => spentAmount >= totalAmount;
  
  bool get isNearLimit => !isExceeded && 
      progressPercentage >= notificationThreshold;

  Budget copyWith({
    Category? category,
    double? totalAmount,
    double? spentAmount,
    DateTime? startDate,
    DateTime? endDate,
    BudgetPeriod? period,
    bool? receiveNotifications,
    double? notificationThreshold,
  }) {
    return Budget(
      id: id,
      category: category ?? this.category,
      totalAmount: totalAmount ?? this.totalAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      period: period ?? this.period,
      receiveNotifications: receiveNotifications ?? this.receiveNotifications,
      notificationThreshold: notificationThreshold ?? this.notificationThreshold,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': category.id,
      'categoryName': category.name,
      'icon': category.icon.codePoint,
      'color': category.color.value,
      'totalAmount': totalAmount,
      'spentAmount': spentAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'period': period.toString(),
      'receiveNotifications': receiveNotifications,
      'notificationThreshold': notificationThreshold,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: Category(
        id: map['categoryId'] ?? '',
        name: map['categoryName'] ?? '',
        icon: IconData(
          map['icon'] ?? Icons.category.codePoint,
          fontFamily: 'MaterialIcons',
        ),
        color: Color(map['color'] ?? Colors.grey.value),
        type: TransactionType.expense, // Default to expense, adjust as needed
      ),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (map['spentAmount'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.toString() == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      receiveNotifications: map['receiveNotifications'] ?? true,
      notificationThreshold: (map['notificationThreshold'] as num?)?.toDouble() ?? 80.0,
    );
  }
}
