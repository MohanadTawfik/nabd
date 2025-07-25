import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/features/transactions/screens/transaction_detail_screen.dart';
import 'package:nabd/features/transactions/widgets/transaction_list_item.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:provider/provider.dart';

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
    return Consumer<AppData>(
      builder: (context, appData, child) {
        List<Transaction> transactions = List.from(appData.transactions);
        transactions = _sortTransactions(transactions);
        transactions = _filterTransactions(transactions);

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: GlassBackground(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text(
                    'سجل المعاملات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
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
                    decoration: InputDecoration(
                      hintText: 'ابحث عن معاملة...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.5),
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
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد معاملات',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18,
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface),
                                    ),
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 1),
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
            ? colorScheme.primary.withOpacity(0.1)
            : isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
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
                  style: textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : isDark
                            ? Colors.white70
                            : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: colorScheme.primary,
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
