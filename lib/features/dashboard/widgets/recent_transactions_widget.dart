import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:nabd/widgets/empty_state.dart';

import 'package:intl/intl.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:provider/provider.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/transactions/screens/transactions_screen.dart';
import 'package:nabd/features/transactions/screens/transaction_detail_screen.dart';
import 'package:nabd/widgets/glass_card.dart';

class RecentTransactionsWidget extends StatelessWidget {
  RecentTransactionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<TransactionsProvider>(
      builder: (context, provider, child) {
        final recentTransactions = provider.transactions.take(4).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with View All button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'آخر المعاملات',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionsScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'عرض الكل',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (recentTransactions.isEmpty)
              _buildEmptyState(context)
            else
              GlassCard(
                padding: const EdgeInsets.all(1),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: theme.dividerColor.withOpacity(0.1),
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final transaction = recentTransactions[index];
                    return _TransactionTile(
                      key: ValueKey(transaction.id),
                      transaction: transaction,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  /// Builds an empty state widget when there are no recent transactions
  /// to display. Shows an icon and helpful message to the user.
  Widget _buildEmptyState(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'لا توجد معاملات بعد',
        message: 'انقر على زر + لإضافة معاملة جديدة',
      ),
    );
  }
}

/// A single transaction tile widget that displays transaction details
/// without animations and interactive feedback.
class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const _TransactionTile({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor =
        isExpense ? theme.colorScheme.error : theme.colorScheme.tertiary;
    final format = NumberFormat.currency(locale: 'ar', symbol: '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailScreen(
                transaction: transaction,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: transaction.category.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  transaction.category.icon,
                  color: transaction.category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.yMMMd('ar').format(transaction.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                '${isExpense ? '−' : '+'}${format.format(transaction.amount)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
