import 'package:flutter/material.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/goals/goals_provider.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:nabd/theme/app_colors.dart';

/// QuickStatsWidget displays a summary of key financial stats: total balance, monthly expense/income, and goals progress.
class QuickStatsWidget extends StatelessWidget {
  const QuickStatsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionsProvider = Provider.of<TransactionsProvider>(context);
    final goalsProvider = Provider.of<GoalsProvider>(context);
    
    // Calculate total balance
    final double totalBalance = transactionsProvider.transactions.fold<double>(
      0,
      (sum, t) => t.type == TransactionType.income ? sum + t.amount : sum - t.amount,
    );
    
    // Calculate monthly expenses and income
    final now = DateTime.now();
    final monthlyTransactions = transactionsProvider.transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();
    
    final double monthlyExpense = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    
    final double monthlyIncome = monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    
    // Calculate goals progress
    final double goalsProgress = goalsProvider.goals.isNotEmpty
        ? goalsProvider.goals
                .map((g) => (g.savedAmount / g.totalAmount).clamp(0.0, 1.0))
                .reduce((a, b) => a + b) /
            goalsProvider.goals.length
        : 0.0;

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // _StatItem(
          //   label: 'الرصيد الكلي',
          //   value: totalBalance.toStringAsFixed(0),
          //   icon: Icons.account_balance_wallet_rounded,
          //   color: AppColors.primaryColor,
          // ),
          _StatItem(
            label: 'مصروفات الشهر',
            value: monthlyExpense.toStringAsFixed(0),
            icon: Icons.trending_down_rounded,
            color: AppColors.expenseColor,
          ),
          _StatItem(
            label: 'دخل الشهر',
            value: monthlyIncome.toStringAsFixed(0),
            icon: Icons.trending_up_rounded,
            color: AppColors.incomeColor,
          ),
          _ProgressStatItem(
            label: 'تقدم الأهداف',
            progress: goalsProgress,
            color: AppColors.successColor,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _ProgressStatItem extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;
  const _ProgressStatItem({
    required this.label,
    required this.progress,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
