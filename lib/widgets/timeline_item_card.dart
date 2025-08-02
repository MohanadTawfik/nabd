import 'package:flutter/material.dart';
import 'package:nabd/features/journey/models/timeline_item_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/utils/formatters.dart';
import 'package:nabd/theme/app_colors.dart';

class TimelineItemCard extends StatelessWidget {
  final TimelineItem item;
  const TimelineItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineDot(context),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCardContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDot(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            item.icon,
            color: Colors.white,
            size: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDate(item.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            _buildTypeSpecificContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificContent(BuildContext context) {
    switch (item.type) {
      case TimelineItemType.expense:
        if (item.data is Transaction) {
          final transaction = item.data as Transaction;
          return _buildTransactionContent(context, transaction);
        }
        break;
      case TimelineItemType.income:
        if (item.data is Transaction) {
          final transaction = item.data as Transaction;
          return _buildTransactionContent(context, transaction);
        }
        break;
      case TimelineItemType.budget:
        return _buildBudgetContent(context);
      case TimelineItemType.goal:
        if (item.data is Goal) {
          final goal = item.data as Goal;
          return _buildGoalContent(context, goal);
        }
        break;
      case TimelineItemType.milestone:
        return _buildMilestoneContent(context);
      case TimelineItemType.achievement:
        return _buildAchievementContent(context);
      case TimelineItemType.alert:
        return _buildAlertContent(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildTransactionContent(
      BuildContext context, Transaction transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.expense : AppColors.income;
    final amountPrefix = isExpense ? '-' : '+';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          transaction.category.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
        Text(
          '$amountPrefix ${formatCurrency(transaction.amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildBudgetContent(BuildContext context) {
    return const Text('تم إنشاء ميزانية جديدة');
  }

  Widget _buildGoalContent(BuildContext context, Goal goal) {
    final progress = goal.savedAmount / goal.totalAmount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المبلغ المستهدف:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              formatCurrency(goal.totalAmount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المبلغ المدخر:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              formatCurrency(goal.savedAmount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.successColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.successColor),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMilestoneContent(BuildContext context) {
    return const Text('تم الوصول إلى مرحلة مهمة');
  }

  Widget _buildAchievementContent(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.emoji_events, color: Colors.amber),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red[800],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
