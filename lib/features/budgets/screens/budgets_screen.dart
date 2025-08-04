import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/budgets/budgets_provider.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/budgets/screens/add_budget_screen.dart';
import 'package:nabd/features/budgets/screens/budget_detail_screen.dart';
import 'package:nabd/features/budgets/widgets/budget_filter_sheet.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/widgets/empty_state.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:provider/provider.dart';

/// الشاشة الرئيسية لعرض الميزانيات
/// تم تحويلها إلى StatefulWidget لإدارة حالة البحث والفرز محلياً
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  // حالة محلية للبحث والفرز
  String _searchQuery = '';
  String _sortBy = 'spent'; // 'spent', 'amount', 'name', 'startDate'
  bool _sortAscending = false;

  // دالة لتطبيق الفرز على الميزانيات
  List<Budget> _sortBudgets(List<Budget> budgets) {
    budgets.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'amount':
          comparison = a.totalAmount.compareTo(b.totalAmount);
          break;
        case 'spent':
          comparison = a.spentAmount.compareTo(b.spentAmount);
          break;
        case 'name':
          comparison = a.displayName.compareTo(b.displayName);
          break;
        case 'startDate':
        default:
          comparison = a.startDate.compareTo(b.startDate);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    return budgets;
  }

  // دالة لتطبيق البحث
  List<Budget> _filterBudgets(List<Budget> budgets) {
    if (_searchQuery.isEmpty) return budgets;
    final query = _searchQuery.toLowerCase();
    return budgets.where((budget) {
      final nameMatch = budget.displayName.toLowerCase().contains(query);
      final categoryMatch =
          budget.category?.name.toLowerCase().contains(query) ?? false;
      return nameMatch || categoryMatch;
    }).toList();
  }

  // دالة لفتح صفحة الفلترة
  void _openFilterSheet() async {
    final result = await BudgetFilterSheet.show(
      context,
      currentSortBy: _sortBy,
      currentSortAscending: _sortAscending,
    );
    if (result != null) {
      setState(() {
        _sortBy = result['sortBy'] as String;
        _sortAscending = result['sortAscending'] as bool;
      });
    }
  }

  // دالة لفتح صفحة إضافة ميزانية
  void _navigateToAddBudget() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBudgetScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // استخدام GlassBackground كخلفية للشاشة
      body: GlassBackground(
        child: Consumer<BudgetsProvider>(
          builder: (context, provider, child) {
            // عرض مؤشر التحميل
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            // عرض رسالة الخطأ
            if (provider.error != null) {
              return Center(child: Text('خطأ: ${provider.error}'));
            }

            // فلترة ميزانيات المصروفات فقط
            final expenseBudgets = provider.budgets
                .where((b) => b.category?.type == TransactionType.expense)
                .toList();

            // تطبيق الفرز والبحث
            final sortedBudgets = _sortBudgets(List.from(expenseBudgets));
            final displayedBudgets = _filterBudgets(sortedBudgets);

            // تجميع الميزانيات حسب الفئة
            final groupedBudgets = _groupBudgetsByCategory(displayedBudgets);

            // استخدام CustomScrollView لأداء أفضل وتأثيرات تمرير أجمل
            return CustomScrollView(
              slivers: [
                // شريط العنوان
                SliverAppBar(
                  title: Text('الميزانيات',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                      ),
                      tooltip: 'تصفية وترتيب',
                      onPressed: _openFilterSheet,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _navigateToAddBudget,
                    ),
                  ],
                ),
                // بطاقة الملخص وحقل البحث
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _SummaryCard(expenseBudgets: expenseBudgets),
                      _SearchField(
                        onChanged: (query) =>
                            setState(() => _searchQuery = query),
                      ),
                    ],
                  ),
                ),
                // عرض قائمة الميزانيات أو حالة عدم وجودها
                if (displayedBudgets.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: _searchQuery.isEmpty
                          ? 'لا توجد ميزانيات'
                          : 'لا توجد نتائج بحث',
                      message: 'أضف ميزانية جديدة لتتبع مصروفاتك',
                      actionText: _searchQuery.isEmpty ? 'إضافة ميزانية' : null,
                      onActionPressed:
                          _searchQuery.isEmpty ? _navigateToAddBudget : null,
                    ),
                  )
                else
                  _BudgetList(groupedBudgets: groupedBudgets),
              ],
            );
          },
        ),
      ),
    );
  }

  // دالة مساعدة لتجميع الميزانيات حسب الفئة
  Map<String, List<Budget>> _groupBudgetsByCategory(List<Budget> budgets) {
    final Map<String, List<Budget>> grouped = {};
    for (final budget in budgets) {
      // استخدام 'uncategorized' للميزانيات بدون فئة
      final key = budget.category?.id ?? 'uncategorized';
      grouped.putIfAbsent(key, () => []).add(budget);
    }
    return grouped;
  }
}

/// ويدجت لعرض بطاقة ملخص الميزانيات
class _SummaryCard extends StatelessWidget {
  final List<Budget> expenseBudgets;

  const _SummaryCard({required this.expenseBudgets});

  // دالة لتنسيق العملة
  String _formatCurrency(num amount) {
    return NumberFormat.currency(locale: 'ar', symbol: '﷼', decimalDigits: 0)
        .format(amount);
  }

  // دالة لتحديد لون شريط التقدم
  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress < 0.5) return Colors.green;
    if (progress < 0.9) return Colors.orange;
    return theme.colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalBudget =
        expenseBudgets.fold(0.0, (sum, item) => sum + item.totalAmount);
    final totalSpent =
        expenseBudgets.fold(0.0, (sum, item) => sum + item.spentAmount);
    final totalRemaining = totalBudget - totalSpent;
    final overallProgress =
        totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final progressColor = _getProgressColor(overallProgress, theme);

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded,
                  color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 8),
              Text('ملخص ميزانيات المصروفات',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 18),
          // شريط التقدم مع حركة
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: overallProgress),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
            builder: (context, value, child) => ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: progressColor.withOpacity(0.2),
                color: progressColor,
                minHeight: 14,
              ),
            ),
          ),
          const SizedBox(height: 18),
          // تفاصيل المبالغ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryAmount(
                  label: 'المصروف',
                  amount: _formatCurrency(totalSpent),
                  color: Colors.orange),
              _SummaryAmount(
                  label: 'المتبقي',
                  amount: _formatCurrency(totalRemaining),
                  color: Colors.green),
              _SummaryAmount(
                  label: 'الإجمالي',
                  amount: _formatCurrency(totalBudget),
                  color: theme.colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}

/// ويدجت صغير لعرض مبلغ في بطاقة الملخص
class _SummaryAmount extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _SummaryAmount(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7))),
        const SizedBox(height: 4),
        Text(amount,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// ويدجت حقل البحث
class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'ابحث عن ميزانية...',
          prefixIcon: Icon(Icons.search,
              color: isDark ? AppColors.iconDark : AppColors.iconLight),
          filled: true,
          fillColor: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// ويدجت لعرض قائمة الميزانيات المجمعة
class _BudgetList extends StatelessWidget {
  final Map<String, List<Budget>> groupedBudgets;

  const _BudgetList({required this.groupedBudgets});

  @override
  Widget build(BuildContext context) {
    // استخدام SliverList لعرض العناصر بكفاءة
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final categoryId = groupedBudgets.keys.elementAt(index);
          final budgets = groupedBudgets[categoryId]!;
          final category =
              budgets.first.category; // كل الميزانيات في المجموعة لها نفس الفئة

          return _BudgetCategoryGroup(
            category: category,
            budgets: budgets,
          );
        },
        childCount: groupedBudgets.length,
      ),
    );
  }
}

/// ويدجت لعرض مجموعة ميزانيات تابعة لنفس الفئة
class _BudgetCategoryGroup extends StatelessWidget {
  final Category? category;
  final List<Budget> budgets;

  const _BudgetCategoryGroup({this.category, required this.budgets});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category?.color ?? theme.colorScheme.secondary;
    final icon = category?.icon ?? Icons.label_important_outline;
    final name = category?.name ?? 'ميزانيات عامة';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الفئة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // قائمة بطاقات الميزانية
          ListView.separated(
            itemCount: budgets.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _BudgetCard(budget: budgets[index]);
            },
          ),
        ],
      ),
    );
  }
}

/// ويدجت لعرض بطاقة ميزانية واحدة بتصميم محسن
class _BudgetCard extends StatelessWidget {
  final Budget budget;

  const _BudgetCard({required this.budget});

  // دالة للانتقال إلى تفاصيل الميزانية
  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetDetailScreen(budgetId: budget.id),
      ),
    );
  }

  // دالة لتنسيق العملة
  String _formatCurrency(num amount) {
    return NumberFormat.currency(locale: 'ar', symbol: '﷼', decimalDigits: 0)
        .format(amount);
  }

  // دالة لتحديد حالة الميزانية ولونها
  (String, Color) _getBudgetStatus(ThemeData theme) {
    final now = DateTime.now();
    final progress = budget.totalAmount > 0
        ? (budget.spentAmount / budget.totalAmount)
        : 0.0;

    if (now.isBefore(budget.startDate)) return ('لم تبدأ', Colors.blueGrey);
    if (progress >= 1) return ('تم التجاوز', theme.colorScheme.error);
    if (now.isAfter(budget.endDate)) return ('منتهية', Colors.grey.shade700);

    final totalDuration = budget.endDate.difference(budget.startDate).inDays;
    final idealProgress = totalDuration > 0
        ? (now.difference(budget.startDate).inDays / totalDuration)
        : 0.0;

    if (progress > idealProgress * 1.2)
      return ('تحت الضغط', Colors.orange.shade700);

    return ('على المسار', Colors.green.shade600);
  }

  // دالة لجلب اسم الفترة
  String _getPeriodLabel(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'ميزانية أسبوعية';
      case BudgetPeriod.monthly:
        return 'ميزانية شهرية';
      case BudgetPeriod.yearly:
        return 'ميزانية سنوية';
      case BudgetPeriod.custom:
      default:
        return 'ميزانية مخصصة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = budget.category?.color ?? theme.colorScheme.primary;
    final progress = budget.totalAmount > 0
        ? (budget.spentAmount / budget.totalAmount).clamp(0.0, 1.0)
        : 0.0;
    final (statusText, statusColor) = _getBudgetStatus(theme);
    final remaining = budget.totalAmount - budget.spentAmount;
    final periodLabel = _getPeriodLabel(budget.period);

    return GlassCard(
      borderRadius: 20,
      child: InkWell(
        onTap: () => _navigateToDetails(context),
        borderRadius: BorderRadius.circular(20),
        splashColor: categoryColor.withOpacity(0.1),
        hoverColor: categoryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف العلوي: الفترة، اسم الميزانية، والحالة
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        periodLabel,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // شريط التقدم الخطي
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: categoryColor.withOpacity(0.2),
                  color: categoryColor,
                ),
              ),
              const SizedBox(height: 12),
              // تفاصيل المبالغ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FinancialDetail(
                    label: 'المصروف',
                    amount: _formatCurrency(budget.spentAmount),
                  ),
                  _FinancialDetail(
                    label: 'المتبقي',
                    amount: _formatCurrency(remaining),
                    isRemaining: true,
                  ),
                  _FinancialDetail(
                    label: 'الإجمالي',
                    amount: _formatCurrency(budget.totalAmount),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ويدجت صغير لعرض التفاصيل المالية في بطاقة الميزانية
class _FinancialDetail extends StatelessWidget {
  final String label;
  final String amount;
  final bool isRemaining;

  const _FinancialDetail({
    required this.label,
    required this.amount,
    this.isRemaining = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment:
          isRemaining ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7))),
        const SizedBox(height: 2),
        Text(amount,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
