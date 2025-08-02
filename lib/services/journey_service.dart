import 'package:flutter/material.dart';
import 'package:nabd/features/journey/models/timeline_item_model.dart';
import 'package:nabd/services/database_service.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';

class JourneyService {
  final DatabaseService _dbService = DatabaseService();

  Future<JourneyResponse> getTimelineItems() async {
    try {
      final transactions = await _dbService.getTransactions();
      final budgets = await _dbService.getBudgets();
      final goals = await _dbService.getGoals();

      List<TimelineItem> items = [];

      // Map transactions to timeline items
      items.addAll(transactions.map((txn) => TimelineItem(
            id: txn.id,
            title: txn.type == TransactionType.income ? 'دخل' : 'مصروف',
            description: txn.notes ?? '',
            date: txn.date,
            icon: txn.type == TransactionType.income
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color:
                txn.type == TransactionType.income ? Colors.green : Colors.red,
            type: txn.type == TransactionType.income
                ? TimelineItemType.income
                : TimelineItemType.expense,
            data: txn,
          )));

      // Map budgets to timeline items
      items.addAll(budgets.map((budget) => TimelineItem(
            id: budget.id,
            title: 'ميزانية: ${budget.category?.name ?? ''}',
            description:
                'من ${budget.startDate.toLocal().toString().split(' ')[0]} إلى ${budget.endDate.toLocal().toString().split(' ')[0]}',
            date: budget.startDate,
            icon: Icons.account_balance_wallet,
            color: Colors.blue,
            type: TimelineItemType.budget,
            data: budget,
          )));

      // Map goals to timeline items
      items.addAll(goals.map((goal) => TimelineItem(
            id: goal.id,
            title: 'هدف: ${goal.name}',
            description: 'المبلغ المستهدف: ${goal.totalAmount}',
            date: goal.createdAt,
            icon: goal.icon,
            color: goal.color,
            type: TimelineItemType.goal,
            data: goal,
          )));

      // Sort by date descending
      items.sort((a, b) => b.date.compareTo(a.date));

      return JourneyResponse(success: true, data: items, message: '');
    } catch (e) {
      return JourneyResponse(success: false, data: null, message: e.toString());
    }
  }
}

class JourneyResponse {
  final bool success;
  final List<TimelineItem>? data;
  final String message;

  JourneyResponse(
      {required this.success, required this.data, required this.message});
}
