import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:provider/provider.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;
  TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Transaction _transaction;

  // Format amount with Arabic locale
  late final NumberFormat amountFormat;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
    amountFormat = NumberFormat.currency(
      locale: 'ar',
      symbol: '',
      decimalDigits: 2,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to TransactionsProvider changes and update the transaction if it was modified
    final provider = Provider.of<TransactionsProvider>(context, listen: true);
    final updatedTransaction = provider.transactions.firstWhere(
      (t) => t.id == _transaction.id,
      orElse: () => _transaction,
    );
    if (updatedTransaction.id == _transaction.id &&
        updatedTransaction != _transaction) {
      if (mounted) {
        setState(() {
          _transaction = updatedTransaction;
        });
      }
    }
  }

  Future<void> _vibrate() async {
    await HapticFeedback.lightImpact();
  }

  void _onTransactionUpdated(Transaction updatedTransaction) {
    if (!mounted) return;

    // Update the local transaction and trigger a rebuild
    setState(() {
      _transaction = updatedTransaction;
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديث المعاملة بنجاح',
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = _transaction.type == TransactionType.expense;
    final transactionColor =
        isExpense ? AppColors.expenseColor : AppColors.incomeColor;

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.pop(context, _transaction);
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'تفاصيل ${_transaction.type == TransactionType.expense ? 'المصروف' : 'الدخل'}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: theme.colorScheme.onSurface), // لون متناسق
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                ),
                onPressed: () => _showEditConfirmation(context),
                tooltip: 'تعديل',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showDeleteConfirmation(context),
                tooltip: 'حذف',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: GlassBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Spacer for AppBar under GlassBackground.SafeArea
                SizedBox(
                  height: AppBar().preferredSize.height *
                          0.5 + // مثلاً 50% من ارتفاع AppBar
                      MediaQuery.of(context).padding.top *
                          0.5, // مثلاً 70% من padding الأعلى
                ),

                // Amount card with hero animation
                GlassCard(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: transactionColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: transactionColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isExpense ? 'مصروف' : 'دخل',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: transactionColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              amountFormat.format(_transaction.amount),
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                                height: 0.9,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                '﷼',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Transaction details card
                Expanded(
                  // هذا هو المفتاح: Expanded يجعل هذا الجزء يأخذ المساحة المتبقية
                  child: SingleChildScrollView(
                    // لضمان التمرير إذا كانت التفاصيل كثيرة
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8), // Padding لهذا الجزء
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'تفاصيل المعاملة',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),

                          // Details list
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: 3 +
                                (_transaction.notes?.isNotEmpty == true
                                    ? 2
                                    : 0),
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _buildEnhancedDetailRow(
                                  context,
                                  icon: _transaction.category.icon,
                                  label: 'التصنيف',
                                  value: _transaction.category.name,
                                  iconColor: _transaction.category.color,
                                );
                              } else if (index == 1) {
                                return _buildEnhancedDetailRow(
                                  context,
                                  icon: Icons.calendar_today_outlined,
                                  label: 'التاريخ',
                                  value: DateFormat('EEEE, d MMMM y', 'ar')
                                      .format(_transaction.date),
                                );
                              } else if (index == 2) {
                                return _buildEnhancedDetailRow(
                                  context,
                                  icon: Icons.access_time,
                                  label: 'الوقت',
                                  value: DateFormat('h:mm a', 'ar')
                                      .format(_transaction.date),
                                );
                              } else if (index == 3 &&
                                  _transaction.notes?.isNotEmpty == true) {
                                return _buildNotesSection(
                                    context, _transaction.notes!);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildNotesSection(BuildContext context, String notes) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.iconTheme.color!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notes_outlined,
                  color: theme.iconTheme.color!,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'ملاحظات',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  letterSpacing: 0.5,
                  // استخدام bodyLarge
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.5),
                width: 0.5,
              ),
            ),
            child: Text(
              notes,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 2,
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? theme.iconTheme.color!).withOpacity(0.1),
              shape: BoxShape.rectangle,
              border: Border.all(
                color: (iconColor ?? theme.iconTheme.color!).withOpacity(0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? theme.iconTheme.color!,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Label and value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    letterSpacing: 0.5,
                    // استخدام bodyLarge
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    // استخدام bodyMedium
                    fontWeight:
                        FontWeight.normal, // ليكون أقل بروزاً من العنوان
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    // height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditConfirmation(BuildContext context) async {
    await _vibrate();
    final shouldEdit = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'تعديل المعاملة',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل تريد تعديل هذه المعاملة؟',
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'إلغاء',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                'تعديل',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (shouldEdit == true && context.mounted) {
      final updatedTransaction = await Navigator.push<Transaction>(
        context,
        MaterialPageRoute(
          builder: (_) => AddTransactionScreen(transactionToEdit: _transaction),
        ),
      );
      if (updatedTransaction != null && context.mounted) {
        _onTransactionUpdated(updatedTransaction);
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    await _vibrate();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'حذف المعاملة',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل أنت متأكد من حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.',
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: Text(
                'إلغاء',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: Text(
                'حذف',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (shouldDelete == true && context.mounted) {
      try {
        final provider =
            Provider.of<TransactionsProvider>(context, listen: false);
        await provider.deleteTransaction(_transaction.id);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء حذف المعاملة: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
