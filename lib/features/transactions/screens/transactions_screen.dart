// transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/features/transactions/screens/transaction_detail_screen.dart';
import 'package:nabd/features/transactions/widgets/transaction_list_item.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:provider/provider.dart';
import 'package:nabd/theme/app_colors.dart'; // إضافة استيراد AppColors

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'date';
  bool _sortAscending = false;

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    if (_searchQuery.isEmpty) return transactions;

    final query = _searchQuery.toLowerCase();
    return transactions.where((txn) {
      return (txn.notes?.toLowerCase().contains(query) ?? false) ||
          txn.amount.toString().contains(query) ||
          txn.category.name.toLowerCase().contains(query);
    }).toList();
  }

  List<Transaction> _sortTransactions(List<Transaction> transactions) {
    switch (_sortBy) {
      case 'amount':
        transactions.sort((a, b) => _sortAscending
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));
        break;
      case 'category':
        transactions.sort((a, b) => _sortAscending
            ? a.category.name.compareTo(b.category.name)
            : b.category.name.compareTo(a.category.name));
        break;
      case 'date':
      default:
        transactions.sort((a, b) => _sortAscending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date));
    }
    return transactions;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppData>(
      builder: (context, appData, child) {
        List<Transaction> transactions = List.from(appData.transactions);
        transactions = _sortTransactions(transactions);
        transactions = _filterTransactions(transactions);

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent, // تم تعيينها شفافة
          body: GlassBackground(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent, // شفافية تامة
                  elevation: 0,
                  title: Text(
                    'سجل المعاملات',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.add,
                          color:
                              theme.colorScheme.onSurface), // استخدام onSurface
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTransactionScreen(
                                // initialType: TransactionType.expense,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          isDark ? AppColors.textDark : AppColors.textPrimary,
                    ), // لون نص الإدخال
                    decoration: InputDecoration(
                      hintText: 'ابحث عن معاملة...',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.subtextDark
                            : AppColors.textSecondary,
                      ), // لون نص التلميح
                      prefixIcon: Icon(
                        Icons.search,
                        color:
                            isDark ? AppColors.iconDark : AppColors.iconLight,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white
                              .withOpacity(0.08) // شفافية أقل ودمج أفضل
                          : Colors.black.withOpacity(0.05), // شفافية أقل
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSortChip('التاريخ', 'date'),
                        const SizedBox(width: 8),
                        _buildSortChip('المبلغ', 'amount'),
                        const SizedBox(width: 8),
                        _buildSortChip('الفئة', 'category'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد معاملات',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  // استخدام headlineSmall
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final txn = transactions[index];
                            bool showDateHeader = index == 0 ||
                                txn.date.day !=
                                    transactions[index - 1].date.day ||
                                txn.date.month !=
                                    transactions[index - 1].date.month ||
                                txn.date.year !=
                                    transactions[index - 1].date.year;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showDateHeader)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 12,
                                      bottom: 8,
                                      right: 8,
                                    ),
                                    child: Text(
                                      _formatDateHeader(txn.date),
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                              // استخدام headlineSmall
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical:
                                          4), // زيادة المسافة العمودية بين البطاقات
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              TransactionDetailScreen(
                                                  transaction: txn),
                                        ),
                                      );
                                    },
                                    child:
                                        TransactionListItem(transaction: txn),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.2) // شفافية أعلى للزر المحدد
            : (isDark
                ? AppColors.grey800.withOpacity(0.3) // لون رمادي داكن شفاف
                : AppColors.grey200.withOpacity(0.5)), // لون رمادي فاتح شفاف
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (isSelected) {
                _sortAscending = !_sortAscending;
              } else {
                _sortBy = value;
                _sortAscending = false;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    // استخدام labelLarge
                    color: isSelected
                        ? colorScheme.onPrimary // لون النص على primary
                        : (isDark
                            ? AppColors.textDark
                                .withOpacity(0.7) // لون نص أقل حدة
                            : AppColors.textPrimary
                                .withOpacity(0.8)), // لون نص أقل حدة
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: colorScheme.onPrimary, // لون الأيقونة على primary
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لتنسيق عنوان التاريخ
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'اليوم';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'الأمس';
    } else {
      return DateFormat('EEEE, d MMMM yyyy', 'ar').format(date);
    }
  }
}
