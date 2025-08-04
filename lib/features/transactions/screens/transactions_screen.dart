// transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Removed unused import
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/features/transactions/screens/transaction_detail_screen.dart';
import 'package:nabd/features/transactions/widgets/transaction_list_item.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/empty_state.dart';
import 'package:provider/provider.dart';
import 'package:nabd/theme/app_colors.dart'; // إضافة استيراد AppColors
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:nabd/features/categories/categories_provider.dart';
import 'package:nabd/features/transactions/widgets/transaction_filter_sheet.dart';

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
  TransactionType? _filterType;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  RangeValues _filterAmountRange = const RangeValues(0, 50000);
  List<Category> _filterCategories = [];

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    List<Transaction> filtered = transactions;

    // // Search filter
    // if (_searchQuery.isNotEmpty) {
    //   final query = _searchQuery.toLowerCase();
    //   filtered = filtered.where((txn) {
    //     return (txn.notes?.toLowerCase().contains(query) ?? false) ||
    //         txn.amount.toString().contains(query) ||
    //         txn.category.name.toLowerCase().contains(query);
    //   }).toList();
    // }

    // // Type filter
    // if (_filterType != null) {
    //   filtered = filtered.where((txn) => txn.type == _filterType).toList();
    // }

    // // Date range filter
    // if (_filterStartDate != null) {
    //   filtered = filtered
    //       .where((txn) => txn.date
    //           .isAfter(_filterStartDate!.subtract(const Duration(days: 1))))
    //       .toList();
    // }
    // if (_filterEndDate != null) {
    //   filtered = filtered
    //       .where((txn) =>
    //           txn.date.isBefore(_filterEndDate!.add(const Duration(days: 1))))
    //       .toList();
    // }

    // // Amount range filter
    // filtered = filtered
    //     .where((txn) =>
    //         txn.amount >= _filterAmountRange.start &&
    //         txn.amount <= _filterAmountRange.end)
    //     .toList();

    // // Categories filter
    // if (_filterCategories.isNotEmpty) {
    //   filtered = filtered
    //       .where((txn) => _filterCategories.contains(txn.category))
    //       .toList();
    // }

    return filtered;
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

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load transactions when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  // Load transactions with categories
  Future<void> _loadTransactions() async {
    final transactionsProvider = Provider.of<TransactionsProvider>(
      context,
      listen: false,
    );
    final categoriesProvider = Provider.of<CategoriesProvider>(
      context,
      listen: false,
    );
    await transactionsProvider.loadTransactions(
      categoriesProvider: categoriesProvider,
    );
  }

  void _applyFilterSheet(Map<String, dynamic> filters) {
    setState(() {
      _filterType = filters['type'] as TransactionType?;
      _filterStartDate = filters['startDate'] as DateTime?;
      _filterEndDate = filters['endDate'] as DateTime?;
      _filterAmountRange =
          filters['amountRange'] as RangeValues? ?? const RangeValues(0, 50000);
      _filterCategories =
          (filters['categories'] as List?)?.cast<Category>() ?? [];
      _sortBy = filters['sortBy'] as String? ?? 'date';
      _sortAscending = filters['sortAscending'] as bool? ?? false;
    });
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
    return Consumer<TransactionsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }
        List<Transaction> transactions = List.from(provider.transactions);
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
                      icon: Icon(Icons.filter_list),
                      tooltip: 'تصفية وترتيب',
                      onPressed: () async {
                        final filters =
                            await TransactionFilterSheet.show(context);
                        if (filters != null) {
                          _applyFilterSheet(filters);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      tooltip: 'إضافة معاملة',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddTransactionScreen(),
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
                      // تم استبدال شريط الترتيب بزر التصفية والفلترة الموحد
                      ),
                ),
                Expanded(
                  child: transactions.isEmpty
                      ? const EmptyState(
                          icon: Icons.receipt_long,
                          title: "",
                          message: 'لا توجد معاملات',
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
