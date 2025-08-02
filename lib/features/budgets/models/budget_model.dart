import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
// Removed unused import

// Extension to parse enum from string
T? _enumFromString<T>(Iterable<T> values, String value) {
  try {
    return values.firstWhere(
      (type) => type.toString().split('.').last == value,
    );
  } catch (_) {
    return null;
  }
}

enum BudgetPeriod { weekly, monthly, yearly, custom }

class Budget {
  final String id;
  final String? categoryId;
  final Category? category; // Null for general budget
  final double totalAmount;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPeriod period;
  final bool receiveNotifications;
  final double notificationThreshold; // Percentage (0-100)
  double spentAmount;

  Budget({
    String? id,
    String? categoryId,
    this.category, // Can be null for general budget
    required this.totalAmount,
    DateTime? startDate,
    DateTime? endDate,
    this.period = BudgetPeriod.monthly,
    this.receiveNotifications = true,
    this.notificationThreshold = 80.0,
    this.spentAmount = 0.0,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId = categoryId,
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

  double get remainingAmount =>
      (totalAmount - spentAmount).clamp(0, double.infinity);

  double get progressPercentage =>
      totalAmount > 0 ? (spentAmount / totalAmount * 100).clamp(0, 100) : 0;

  bool get isExceeded => spentAmount >= totalAmount;

  bool get isNearLimit =>
      !isExceeded && progressPercentage >= notificationThreshold;

  String get title {
    if (category == null) return 'General Budget - ${_getPeriodString(period)}';
    return '${category!.name} - ${_getPeriodString(period)}';
  }

  String get subtitle =>
      '${totalAmount.toStringAsFixed(0)} ${_getCurrencySymbol()}';

  String get remainingText =>
      '${remainingAmount.toStringAsFixed(0)} ${_getCurrencySymbol()} remaining';

  String get periodText => _getPeriodString(period);

  String get progressText =>
      '${progressPercentage.toStringAsFixed(1)}% of budget';

  String get displayName {
    if (category == null) return 'الميزانية العامة';
    return category?.name ?? '';
  }

  IconData get displayIcon {
    if (category == null) return Icons.account_balance_wallet_outlined;
    return category?.icon ?? Icons.category;
  }

  Color get displayColor {
    if (category == null) return Colors.blue;
    return category?.color ?? Colors.grey;
  }

  String _getPeriodString(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'أسبوعي';
      case BudgetPeriod.monthly:
        return 'شهري';
      case BudgetPeriod.yearly:
        return 'سنوي';
      case BudgetPeriod.custom:
        return 'مخصص';
    }
  }

  String _getCurrencySymbol() {
    // Implement logic to get the currency symbol
    return '';
  }

  Budget copyWith({
    String? categoryId,
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
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      totalAmount: totalAmount ?? this.totalAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      period: period ?? this.period,
      receiveNotifications: receiveNotifications ?? this.receiveNotifications,
      notificationThreshold:
          notificationThreshold ?? this.notificationThreshold,
    );
  }

  // Convert to a map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId ?? category?.id,
      'totalAmount': totalAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'period': period.toString().split('.').last,
      'receiveNotifications': receiveNotifications ? 1 : 0,
      'notificationThreshold': notificationThreshold,
      'spentAmount': spentAmount,
    };
  }

  // Create from a map (for deserialization)
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      categoryId: map['categoryId'],
      category:
          null, // Should be resolved by provider after fetch using categoryId
      totalAmount: (map['totalAmount'] as num).toDouble(),
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      period: _enumFromString(BudgetPeriod.values, map['period']) ??
          BudgetPeriod.monthly,
      receiveNotifications: (map['receiveNotifications'] == 1),
      notificationThreshold:
          (map['notificationThreshold'] as num?)?.toDouble() ?? 80.0,
      spentAmount: (map['spentAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Alias for toMap for compatibility
  Map<String, dynamic> toJson() => toMap();

  // Alias for fromMap for compatibility
  factory Budget.fromJson(Map<String, dynamic> json) => Budget.fromMap(json);
}
