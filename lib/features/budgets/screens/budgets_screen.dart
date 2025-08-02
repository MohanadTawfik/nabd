import 'package:flutter/material.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/budgets/screens/add_budget_screen.dart';
import 'package:nabd/features/budgets/screens/budget_detail_screen.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/widgets/empty_state.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/features/budgets/budgets_provider.dart';

enum _ActionType { add, edit, delete }

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'spent';
  bool _sortAscending = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Budget> _filterBudgets(List<Budget> budgets) {
    if (_searchQuery.isEmpty) return budgets;
    final query = _searchQuery.toLowerCase();
    return budgets.where((budget) {
      final displayNameMatch = budget.displayName.toLowerCase().contains(query);
      final categoryMatch =
          budget.category?.name.toLowerCase().contains(query) ?? false;
      final amountMatch = budget.totalAmount.toString().contains(query);
      return displayNameMatch || categoryMatch || amountMatch;
    }).toList();
  }

  List<Budget> _sortBudgets(List<Budget> budgets) {
    switch (_sortBy) {
      case 'amount':
        budgets.sort((a, b) => _sortAscending
            ? a.totalAmount.compareTo(b.totalAmount)
            : b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'spent':
        budgets.sort((a, b) => _sortAscending
            ? a.spentAmount.compareTo(b.spentAmount)
            : b.spentAmount.compareTo(a.spentAmount));
        break;
      case 'name':
        budgets.sort((a, b) => _sortAscending
            ? a.displayName.compareTo(b.displayName)
            : b.displayName.compareTo(a.displayName));
        break;
      case 'startDate':
      default:
        budgets.sort((a, b) {
          return _sortAscending
              ? a.startDate.compareTo(b.startDate)
              : b.startDate.compareTo(a.startDate);
        });
    }
    return budgets;
  }

  void _showActionFeedback(_ActionType type) {
    switch (type) {
      case _ActionType.add:
        HapticFeedback.lightImpact();
        break;
      case _ActionType.edit:
        HapticFeedback.mediumImpact();
        break;
      case _ActionType.delete:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  Future<void> _navigateToBudgetDetail(
      BuildContext context, Budget budget) async {
    final budgetsProvider =
        Provider.of<BudgetsProvider>(context, listen: false);
    final latestBudget = budgetsProvider.budgets.firstWhere(
      (b) => b.id == budget.id,
      orElse: () => budget,
    );
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetDetailScreen(budgetId: latestBudget.id),
      ),
    );
  }

  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress < 0.5) {
      return Colors.green;
    } else if (progress < 0.9) {
      return Colors.orange;
    } else {
      return theme.colorScheme.error;
    }
  }

  String _formatCurrency(num amount, {int decimalDigits = 0}) {
    return NumberFormat.currency(
      locale: 'ar',
      symbol: '﷼',
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<BudgetsProvider>(
      builder: (context, budgetsProvider, child) {
        if (budgetsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (budgetsProvider.error != null) {
          return Center(child: Text('خطأ: ${budgetsProvider.error}'));
        }
        final expenseBudgets = budgetsProvider.budgets
            .where((b) => b.category?.type == TransactionType.expense)
            .toList();

        final totalBudget =
            expenseBudgets.fold(0.0, (sum, item) => sum + item.totalAmount);
        final totalSpent =
            expenseBudgets.fold(0.0, (sum, item) => sum + item.spentAmount);

        List<Budget> displayBudgets = List.from(expenseBudgets);
        displayBudgets = _sortBudgets(displayBudgets);
        displayBudgets = _filterBudgets(displayBudgets);

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: GlassBackground(
            child: Column(
              children: [
                _buildAppBar(context, theme),
                _buildSummaryCard(
                  totalBudget: totalBudget,
                  totalSpent: totalSpent,
                  theme: theme,
                ),
                _buildSearchAndSortControls(theme, isDark),
                Expanded(
                  child: displayBudgets.isEmpty
                      ? _buildEmptyState(context, theme, isDark)
                      : _buildBudgetsList(context, theme, displayBudgets),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required double totalBudget,
    required double totalSpent,
    required ThemeData theme,
  }) {
    final double totalRemaining = totalBudget - totalSpent;
    final double overallProgress =
        (totalBudget > 0) ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    final Color progressColor = _getProgressColor(overallProgress, theme);

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص ميزانيات المصروفات',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: overallProgress),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            builder: (context, value, child) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: progressColor.withOpacity(0.2),
                color: progressColor,
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryAmount('المصروف', totalSpent, Colors.orange, theme),
              _buildSummaryAmount(
                  'المتبقي', totalRemaining, Colors.green, theme),
              _buildSummaryAmount('الإجمالي', totalBudget,
                  theme.colorScheme.onSurface.withOpacity(0.7), theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryAmount(
      String label, double amount, Color color, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: theme.textTheme.titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSearchAndSortControls(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: TextField(
            controller: _searchController,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.textDark : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'ابحث عن ميزانية...',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.subtextDark : AppColors.textSecondary,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? AppColors.iconDark : AppColors.iconLight,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSortChip('الإجمالي', 'amount'),
                const SizedBox(width: 8),
                _buildSortChip('المصروف', 'spent'),
                const SizedBox(width: 8),
                _buildSortChip('الاسم', 'name'),
                const SizedBox(width: 8),
                _buildSortChip('التاريخ', 'startDate'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? colorScheme.primary.withOpacity(0.25)
          : (isDark
              ? AppColors.grey800.withOpacity(0.3)
              : AppColors.grey200.withOpacity(0.5)),
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
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    );
  }

  AppBar _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'الميزانيات',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
          onPressed: () {
            _showActionFeedback(_ActionType.add);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddBudgetScreen(),
                fullscreenDialog: true,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBudgetsList(
      BuildContext context, ThemeData theme, List<Budget> budgets) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        bool showDateHeader = false;
        String _formatDateHeader(DateTime date) {
          return DateFormat('MMMM yyyy', 'ar').format(date);
        }

        if (_sortBy == 'startDate') {
          showDateHeader = index == 0 ||
              budget.startDate.month != budgets[index - 1].startDate.month ||
              budget.startDate.year != budgets[index - 1].startDate.year;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8, right: 8),
                child: Text(
                  _formatDateHeader(budget.startDate),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildBudgetCard(context, theme, budget),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetCard(
      BuildContext context, ThemeData theme, Budget budget) {
    final total = budget.totalAmount;
    final spent = budget.spentAmount;
    final remaining = total - spent;
    final progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final (statusText, statusColor) = _getBudgetStatus(budget, progress, theme);
    final categoryColor = budget.category?.color ?? statusColor;

    String daysLeftText = '';
    if (DateTime.now().isBefore(budget.endDate)) {
      final days = budget.endDate.difference(DateTime.now()).inDays;
      if (days >= 0) {
        daysLeftText = 'باقي ${days + 1} يوم';
      }
    }

    return GlassCard(
      child: InkWell(
        onTap: () => _navigateToBudgetDetail(context, budget),
        borderRadius: BorderRadius.circular(18),
        splashColor: categoryColor.withOpacity(0.1),
        hoverColor: categoryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              SizedBox(
                width: 75,
                height: 75,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 6,
                      color: categoryColor.withOpacity(0.2),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, value, child) =>
                          CircularProgressIndicator(
                        value: value,
                        strokeWidth: 6,
                        color: categoryColor,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            budget.displayName,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Add delete button for test compatibility
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'حذف الميزانية',
                          onPressed: () {
                            // You may want to show a confirmation dialog here
                            final provider = Provider.of<BudgetsProvider>(
                                context,
                                listen: false);
                            provider.deleteBudget(budget.id);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFinancialDetail(
                            'المصروف', spent, theme, categoryColor),
                        const SizedBox(width: 16),
                        _buildFinancialDetail(
                            'المتبقي', remaining, theme, categoryColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (daysLeftText.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.hourglass_bottom_rounded,
                              size: 12,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text(daysLeftText, style: theme.textTheme.bodySmall),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialDetail(
      String label, double amount, ThemeData theme, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(amount),
              style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: color.withOpacity(0.85)),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _getBudgetStatus(
      Budget budget, double progress, ThemeData theme) {
    final now = DateTime.now();
    final startDate = budget.startDate;
    final endDate = budget.endDate;

    if (now.isBefore(startDate)) {
      return ('لم تبدأ بعد', Colors.blueGrey);
    }

    if (progress >= 1) {
      return ('تم التجاوز', theme.colorScheme.error);
    }

    if (now.isAfter(endDate)) {
      return ('منتهية', Colors.grey.shade700);
    }

    int totalDuration = endDate.difference(startDate).inDays;
    if (totalDuration == 0) totalDuration = 1;

    int daysPassed = now.difference(startDate).inDays;
    double idealProgress = daysPassed / totalDuration;

    if (progress > (idealProgress * 1.25)) {
      return ('تحت الضغط', Colors.orange.shade700);
    }

    return ('على المسار', Colors.green.shade600);
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isDark) {
    return EmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: _searchQuery.isEmpty
          ? 'لا توجد ميزانيات للمصروفات'
          : 'لا توجد نتائج بحث',
      message: 'أضف ميزانية جديدة لتتبع مصروفاتك',
      actionText: _searchQuery.isEmpty ? 'إضافة ميزانية للمصروفات' : null,
      onActionPressed: _searchQuery.isEmpty
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddBudgetScreen()),
              )
          : null,
    );
  }
}
