import 'package:flutter/material.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/budgets/screens/add_budget_screen.dart';
import 'package:nabd/features/budgets/screens/budget_detail_screen.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/theme/app_colors.dart';
// تأكد من استيراد مودل الفئة للوصول إلى نوعها (دخل/مصروف)
import 'package:nabd/features/categories/models/category_model.dart';

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
      final displayNameMatch =
          budget.displayName?.toLowerCase().contains(query) ?? false;
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
            ? (a.totalAmount ?? 0).compareTo(b.totalAmount ?? 0)
            : (b.totalAmount ?? 0).compareTo(a.totalAmount ?? 0));
        break;
      // **الإضافة الجديدة:** منطق الترتيب حسب المبلغ المصروف
      case 'spent':
        budgets.sort((a, b) => _sortAscending
            ? (a.spentAmount ?? 0).compareTo(b.spentAmount ?? 0)
            : (b.spentAmount ?? 0).compareTo(a.spentAmount ?? 0));
        break;
      case 'name':
        budgets.sort((a, b) => _sortAscending
            ? (a.displayName ?? '').compareTo(b.displayName ?? '')
            : (b.displayName ?? '').compareTo(a.displayName ?? ''));
        break;
      case 'startDate':
      default:
        budgets.sort((a, b) {
          if (a.startDate == null && b.startDate == null) return 0;
          if (a.startDate == null) return _sortAscending ? 1 : -1;
          if (b.startDate == null) return _sortAscending ? -1 : 1;
          return _sortAscending
              ? a.startDate!.compareTo(b.startDate!)
              : b.startDate!.compareTo(a.startDate!);
        });
    }
    return budgets;
  }

  void _showActionFeedback(_ActionType type) {
    // ... (نفس دالة الاهتزاز من قبل، لا تغيير هنا)
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
    // ... (نفس دالة الانتقال الآمنة من قبل، لا تغيير هنا)
    if (!mounted) return;
    _showActionFeedback(_ActionType.edit);

    try {
      final appData = Provider.of<AppData>(context, listen: false);
      final latestBudget = appData.budgets.firstWhere(
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء فتح التفاصيل: ${e.toString()}'),
          ),
        );
      }
    }
  }

  /// Returns a color based on the progress value for the progress bar.
  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress < 0.5) {
      return Colors.green;
    } else if (progress < 0.9) {
      return Colors.orange;
    } else {
      return theme
          .colorScheme.error; // Uses the theme's error color (usually red)
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

    return Consumer<AppData>(
      builder: (context, appData, child) {
        // **التحسين:** فلترة الميزانيات لعرض المصروفات فقط
        final expenseBudgets = appData.budgets
            .where((b) => b.category?.type == TransactionType.expense)
            .toList();

        // حساب الإجماليات لبطاقة الملخص
        final totalBudget = expenseBudgets.fold(
            0.0, (sum, item) => sum + (item.totalAmount ?? 0));
        final totalSpent = expenseBudgets.fold(
            0.0, (sum, item) => sum + (item.spentAmount ?? 0));

        // تطبيق الفرز والبحث على القائمة المفلترة
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

                // **التحسين:** عرض بطاقة الملخص
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

  // --- Widgets البناء ---
  Widget _buildSummaryCard({
    required double totalBudget,
    required double totalSpent,
    required ThemeData theme,
  }) {
    final double totalRemaining = totalBudget - totalSpent;
    final double overallProgress =
        (totalBudget > 0) ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    // **التحسين:** تحديد لون الشريط بناءً على نسبة التقدم الإجمالية
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
                // **التحسين:** استخدام اللون المتفاعل
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
    // ... (لا تغيير هنا)
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
    // ... (لا تغيير هنا)
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
    // ... (لا تغيير هنا)
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        bool showDateHeader = false;
        String _formatDateHeader(DateTime date) {
          return DateFormat('MMMM yyyy', 'ar').format(date);
        }

        // Show header if sorting by date and the month/year changes
        if (_sortBy == 'startDate' && budget.startDate != null) {
          showDateHeader = index == 0 ||
              budget.startDate!.month != budgets[index - 1].startDate!.month ||
              budget.startDate!.year != budgets[index - 1].startDate!.year;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8, right: 8),
                child: Text(
                  _formatDateHeader(budget.startDate!),
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
    // --- حساب المتغيرات الأساسية ---
    final total = budget.totalAmount ?? 0;
    final spent = budget.spentAmount ?? 0;
    final remaining = total - spent;
    final progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final (statusText, statusColor) = _getBudgetStatus(budget, progress, theme);
    final categoryColor = budget.category?.color ?? statusColor;

    String daysLeftText = '';
    if (budget.endDate != null && DateTime.now().isBefore(budget.endDate!)) {
      final days = budget.endDate!.difference(DateTime.now()).inDays;
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
        // التعديل: تقليل الحشو الداخلي للبطاقة
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // --- العمود الأيسر: المؤشر الدائري ---
              SizedBox(
                // التعديل: تصغير حجم المؤشر
                width: 75,
                height: 75,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 1,
                      // التعديل: تعديل سماكة الخط
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
                        // التعديل: تصغير حجم خط النسبة
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // --- العمود الأيمن: التفاصيل ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // التعديل: دمج العنوان مع شارة الحالة
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            budget.displayName ?? '',
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
                      ],
                    ),
                    // التعديل: تقليل المسافات
                    const SizedBox(height: 8),
                    // تفاصيل المصروف والمتبقي
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
                    // الوقت المتبقي
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

  // دالة مساعدة لعرض تفاصيل المصروف والمتبقي (تم تصغير الخطوط)
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
              // التعديل: استخدام حجم خط أصغر
              style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: color.withOpacity(0.85)),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Analyzes the budget and returns a status text and color.
  (String, Color) _getBudgetStatus(
      Budget budget, double progress, ThemeData theme) {
    final now = DateTime.now();
    final startDate = budget.startDate;
    final endDate = budget.endDate;

    if (startDate == null || endDate == null) {
      return ('غير محددة', Colors.grey);
    }

    if (now.isBefore(startDate)) {
      return ('لم تبدأ بعد', Colors.blueGrey);
    }

    if (progress >= 1) {
      return ('تم التجاوز', theme.colorScheme.error);
    }

    if (now.isAfter(endDate)) {
      return ('منتهية', Colors.grey.shade700);
    }

    // Calculate ideal spending rate based on time elapsed
    int totalDuration = endDate.difference(startDate).inDays;
    if (totalDuration == 0) totalDuration = 1; // Avoid division by zero

    int daysPassed = now.difference(startDate).inDays;
    double idealProgress = daysPassed / totalDuration;

    // If spending is significantly higher than the ideal rate (e.g., 25% higher)
    if (progress > (idealProgress * 1.25)) {
      return ('تحت الضغط', Colors.orange.shade700);
    }

    return ('على المسار', Colors.green.shade600);
  }

  String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return '';

    // **التحسين:** استخدام تنسيق واضح وكامل للتاريخ
    final DateFormat formatter = DateFormat('d MMMM yyyy', 'ar');

    final String startFormatted = formatter.format(startDate);
    final String endFormatted = formatter.format(endDate);

    // في حال كانت الميزانية ليوم واحد فقط
    if (startFormatted == endFormatted) {
      return 'في يوم ${startFormatted}';
    }

    // بناء النص الجديد لعرض الفترة من البداية إلى النهاية
    return 'من $startFormatted إلى $endFormatted';
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isDark) {
    // ... (تم تعديل النص هنا)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: isDark ? Colors.grey[700] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'لا توجد ميزانيات للمصروفات'
                : 'لا توجد نتائج بحث',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف ميزانية جديدة لتتبع مصروفاتك',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[600] : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddBudgetScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('إضافة ميزانية للمصروفات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
