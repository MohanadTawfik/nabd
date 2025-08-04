import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/utils/extensions.dart';

/// نموذج بيانات لتمرير البيانات المعالجة من المنطق إلى الواجهة.
class _ChartData {
  final List<PieChartSectionData> sections;
  final List<MapEntry<Category, double>> legendItems;
  final double totalExpense;

  _ChartData({
    required this.sections,
    required this.legendItems,
    required this.totalExpense,
  });
}

/// ويدجت يعرض ملخص المصروفات الشهرية على شكل مخطط دائري تفاعلي.
class ExpenseSummaryChart extends StatefulWidget {
  final List<Transaction> transactions;
  const ExpenseSummaryChart({super.key, required this.transactions});

  @override
  State<ExpenseSummaryChart> createState() => _ExpenseSummaryChartState();
}

class _ExpenseSummaryChartState extends State<ExpenseSummaryChart> {
  int touchedIndex = -1;

  /// يعالج البيانات الخام للمعاملات ويجهزها للعرض في المخطط.
  _ChartData _prepareChartData() {
    final now = DateTime.now();

    // 1. فلترة مصروفات الشهر الحالي
    final currentMonthExpenses = widget.transactions.where((t) =>
        t.type == TransactionType.expense &&
        t.date.month == now.month &&
        t.date.year == now.year);

    if (currentMonthExpenses.isEmpty) {
      return _ChartData(sections: [], legendItems: [], totalExpense: 0);
    }

    // 2. تجميع المصروفات حسب الفئة
    final expensesByCategory = <Category, double>{};
    for (final expense in currentMonthExpenses) {
      expensesByCategory.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    // 3. ترتيب الفئات تنازلياً حسب المبلغ
    final sortedCategories = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalExpense =
        sortedCategories.fold<double>(0, (sum, e) => sum + e.value);
    final chartSections = <PieChartSectionData>[];
    final legendItems = <MapEntry<Category, double>>[];

    const int maxVisibleCategories = 5;
    final visibleCategories = sortedCategories.take(maxVisibleCategories);

    // 4. إعداد بيانات المخطط للفئات الظاهرة
    for (final entry in visibleCategories) {
      chartSections.add(PieChartSectionData(
        color: entry.key.color,
        value: entry.value,
        showTitle: false, // سيتم التحكم بالعنوان عند اللمس
        radius: 60,
      ));
      legendItems.add(entry);
    }

    // 5. تجميع بقية الفئات تحت "أخرى"
    if (sortedCategories.length > maxVisibleCategories) {
      final otherAmount = sortedCategories
          .skip(maxVisibleCategories)
          .fold(0.0, (sum, entry) => sum + entry.value);
      final otherCategory = Category(
        id: 'other',
        name: 'أخرى',
        color: Colors.grey.shade600,
        icon: Icons.more_horiz,
        type: TransactionType.expense,
      );

      chartSections.add(PieChartSectionData(
        color: otherCategory.color,
        value: otherAmount,
        showTitle: false,
        radius: 60,
      ));
      legendItems.add(MapEntry(otherCategory, otherAmount));
    }

    return _ChartData(
      sections: chartSections,
      legendItems: legendItems,
      totalExpense: totalExpense,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();

    if (chartData.sections.isEmpty) {
      return _buildEmptyState(context);
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 80),
          _buildChartSection(context, chartData),
          const SizedBox(height: 80),
          _buildLegendSection(context, chartData.legendItems),
        ],
      ),
    );
  }

  /// بناء رأس البطاقة
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'توزيع مصروفات الشهر',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            DateFormat.yMMMM('ar').format(DateTime.now()),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// بناء قسم المخطط الدائري
  Widget _buildChartSection(BuildContext context, _ChartData data) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 1.5,
              centerSpaceRadius: 80,
              sections: List.generate(data.sections.length, (i) {
                final isTouched = i == touchedIndex;
                final section = data.sections[i];
                final radius = isTouched ? 50.0 : 40.0;
                final percentage = (section.value / data.totalExpense * 100);

                return section.copyWith(
                  radius: radius,
                  title: '${percentage.toStringAsFixed(1)}%',
                  showTitle: isTouched,
                  titleStyle: TextStyle(
                    fontSize: isTouched ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                );
              }),
            ),
          ),
          _buildCenterText(context, data.totalExpense),
        ],
      ),
    );
  }

  /// بناء النص في منتصف المخطط
  Widget _buildCenterText(BuildContext context, double total) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'الإجمالي',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        const SizedBox(height: 4),
        Text(
          total.formatAsCurrency(),
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// بناء قسم مفتاح المخطط
  Widget _buildLegendSection(
      BuildContext context, List<MapEntry<Category, double>> legendItems) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(legendItems.length, (i) {
        final entry = legendItems[i];
        return _buildLegendItem(
          context: context,
          category: entry.key,
          amount: entry.value,
          isSelected: i == touchedIndex,
          onTap: () =>
              setState(() => touchedIndex = (touchedIndex == i) ? -1 : i),
        );
      }),
    );
  }

  /// بناء عنصر واحد في مفتاح المخطط
  Widget _buildLegendItem({
    required BuildContext context,
    required Category category,
    required double amount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? category.color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? category.color : theme.dividerColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: category.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '${category.name} (${amount.formatAsCurrency()})',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? category.color : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء واجهة الحالة الفارغة
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline,
                  size: 48, color: theme.colorScheme.primary.withOpacity(0.6)),
              const SizedBox(height: 16),
              Text('لا توجد مصروفات مسجلة لهذا الشهر',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('أضف معاملة جديدة للبدء',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor)),
            ],
          ),
        ),
      ),
    );
  }
}
