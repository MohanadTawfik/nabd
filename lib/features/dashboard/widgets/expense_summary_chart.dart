import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/utils/extensions.dart';

// Import transaction type from transaction model

/// A widget that displays a summary of expenses by category using a pie chart.
class ExpenseSummaryChart extends StatefulWidget {
  final List<Transaction> transactions;
  const ExpenseSummaryChart({super.key, required this.transactions});

  @override
  State<ExpenseSummaryChart> createState() => _ExpenseSummaryChartState();
}

class _ExpenseSummaryChartState extends State<ExpenseSummaryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Get expenses for the current month
    final currentMonthExpenses = widget.transactions.where((t) =>
        t.type == TransactionType.expense &&
        t.date.month == now.month &&
        t.date.year == now.year);

    // Group expenses by category
    final expensesByCategory = <Category, double>{};
    for (final expense in currentMonthExpenses) {
      expensesByCategory.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    // Sort categories by amount (descending)
    final sortedCategories = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Prepare chart data
    final chartData = <PieChartSectionData>[];
    final totalExpense =
        sortedCategories.fold<double>(0, (sum, e) => sum + e.value);

    // Add top 5 categories
    for (var i = 0; i < sortedCategories.length && i < 5; i++) {
      final entry = sortedCategories[i];
      final percentage = (entry.value / totalExpense * 100).toStringAsFixed(1);

      chartData.add(
        PieChartSectionData(
          color: entry.key.color,
          value: entry.value,
          title: '$percentage%',
          radius: 60,
          titleStyle: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          showTitle: true,
        ),
      );
    }

    // Add "Other" category if needed
    if (sortedCategories.length > 5) {
      final otherAmount =
          sortedCategories.skip(5).fold(0.0, (sum, entry) => sum + entry.value);
      final percentage = (otherAmount / totalExpense * 100).toStringAsFixed(1);

      chartData.add(
        PieChartSectionData(
          color: Colors.grey,
          value: otherAmount,
          title: '$percentage% أخرى',
          radius: 60,
          titleStyle: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          showTitle: true,
        ),
      );
    }

    // Empty state
    if (chartData.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 48,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مصروفات لهذا الشهر',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'توزيع المصروفات',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'الشهر الحالي',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                // Pie Chart
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (event is FlTapUpEvent ||
                              event is FlPanEndEvent ||
                              event is FlLongPressEnd) {
                            touchedIndex = -1;
                          } else if (pieTouchResponse != null &&
                              pieTouchResponse.touchedSection != null) {
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          }
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: chartData.asMap().entries.map((entry) {
                      final isTouched = entry.key == touchedIndex;
                      final data = entry.value;
                      return data.copyWith(
                        radius: isTouched ? 90.0 : 80.0,
                        showTitle: isTouched,
                      );
                    }).toList(),
                  ),
                ),
                // Center text with total
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'إجمالي المصروفات',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalExpense.formatAsCurrency(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Legend
          if (sortedCategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: sortedCategories
                  .take(5)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) => _buildLegendItem(
                        context,
                        entry.value.key,
                        entry.value.value,
                        entry.key == touchedIndex,
                      ))
                  .toList(),
            ),
            if (sortedCategories.length > 5) ...[
              const SizedBox(height: 8),
              _buildLegendItem(
                context,
                Category(
                  id: 'other',
                  name: 'أخرى',
                  color: Colors.grey,
                  icon: Icons.category,
                  type: TransactionType.expense,
                ),
                sortedCategories
                    .skip(5)
                    .fold(0.0, (sum, entry) => sum + entry.value),
                touchedIndex == 5,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    Category category,
    double amount,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? category.color.withOpacity(0.2)
            : theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border:
            isSelected ? Border.all(color: category.color, width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${category.name} • ${amount.formatAsCurrency()}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
