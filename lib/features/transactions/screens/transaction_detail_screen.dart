import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:provider/provider.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/widgets/glass_card.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.tertiary;
    final amountFormat = NumberFormat('#,##0', 'en_US');
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'ar');
    final timeFormat = DateFormat('hh:mm a', 'ar');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
            'تفاصيل ${transaction.type == TransactionType.expense ? 'المصروف' : 'الدخل'}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddTransactionScreen(transactionToEdit: transaction),
                ),
              );
            },
            tooltip: 'تعديل',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: Theme.of(context).colorScheme.error),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'حذف',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassBackground(
        child: Column(
          children: [
            // Main content
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount card
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(
                            isExpense ? 'مصروف' : 'دخل',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ' ${amountFormat.format(transaction.amount)}',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '﷼',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Transaction details card
                  Column(
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.category,
                        title: 'الفئة',
                        value: transaction.category.name,
                        iconColor: color,
                        iconBackground: color.withOpacity(0.1),
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today,
                        title: 'التاريخ',
                        value: dateFormat.format(transaction.date),
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        context,
                        icon: Icons.access_time,
                        title: 'الوقت',
                        value: timeFormat.format(transaction.date),
                      ),
                      if (transaction.notes?.isNotEmpty ?? false) ...[
                        _buildDivider(),
                        _buildDetailRow(
                          context,
                          icon: Icons.notes,
                          title: 'ملاحظات',
                          value: transaction.notes!,
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                  // const SizedBox(height: 24),

                  // // Delete button
                  // ElevatedButton.icon(
                  //   onPressed: () => _showDeleteConfirmation(context),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor:
                  //         theme.colorScheme.error.withValues(alpha: 0.1),
                  //     foregroundColor: theme.colorScheme.error,
                  //     elevation: 0,
                  //     padding: const EdgeInsets.symmetric(vertical: 16),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //   ),
                  //   icon: const Icon(Icons.delete_outline),
                  //   label: const Text('حذف المعاملة',
                  //       style: TextStyle(fontWeight: FontWeight.bold)),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
    Color? iconBackground,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final defaultColor = theme.iconTheme.color ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBackground ?? defaultColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? defaultColor, size: 25),
          ),

          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final transaction = this.transaction;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('حذف المعاملة',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'هل أنت متأكد من حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AppData>(context, listen: false)
                    .deleteTransaction(transaction);
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('حذف',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
