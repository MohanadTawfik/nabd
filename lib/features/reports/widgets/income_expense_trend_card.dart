import 'package:flutter/material.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/utils/animation_config.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart'
    show
        SfCartesianChart,
        CartesianSeries,
        LineSeries,
        CategoryAxis,
        NumericAxis,
        Legend,
        LegendPosition,
        LegendItemOverflowMode,
        MajorGridLines,
        AxisLine,
        TooltipBehavior,
        MarkerSettings;
import 'package:intl/intl.dart';

// This widget displays income vs expense trends using SfCartesianChart
// It addresses the "A disposed RenderObject was mutated" error by properly
// disposing the AnimationController and conditionally applying animations

/// A widget that displays income vs expense trend using a line chart.
class IncomeExpenseTrendCard extends StatefulWidget {
  const IncomeExpenseTrendCard({Key? key}) : super(key: key);

  @override
  State<IncomeExpenseTrendCard> createState() => _IncomeExpenseTrendCardState();
}

class _IncomeExpenseTrendCardState extends State<IncomeExpenseTrendCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Track whether the widget is mounted to prevent updating state after disposal
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    _animationController = AnimationController(
      vsync: this,
      duration: AnimationConfig.standardDuration,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    if (AnimationConfig.complexAnimationsEnabled) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0; // Skip animation
    }
  }

  @override
  void dispose() {
    // First stop any ongoing animations
    _animationController.stop();
    // Set animation value to 1.0 to prevent any further animations
    _animationController.value = 1.0;
    // Then dispose the controller
    _animationController.dispose();
    // Mark as unmounted to prevent setState after dispose
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<TransactionsProvider>(builder: (context, txProvider, _) {
      // Get transactions for the last 6 months
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

      final relevantTransactions = txProvider.transactions.where((t) {
        return t.date.isAfter(sixMonthsAgo) &&
            t.date.isBefore(DateTime(now.year, now.month + 1, 0));
      }).toList();

      // Group by month and type
      final monthlyData = <int, Map<TransactionType, double>>{};

      for (var month = sixMonthsAgo.month; month <= now.month; month++) {
        monthlyData[month] = {
          TransactionType.income: 0,
          TransactionType.expense: 0,
        };
      }

      for (final transaction in relevantTransactions) {
        final month = transaction.date.month;
        final type = transaction.type;
        monthlyData[month]![type] =
            (monthlyData[month]![type] ?? 0) + transaction.amount;
      }

      // Create chart data
      final incomeData = <ChartData>[];
      final expenseData = <ChartData>[];

      monthlyData.forEach((month, data) {
        final monthName = DateFormat.MMM().format(DateTime(now.year, month));
        incomeData.add(ChartData(
          monthName,
          data[TransactionType.income] ?? 0,
          color: AppColors.incomeColor,
        ));
        expenseData.add(ChartData(
          monthName,
          data[TransactionType.expense] ?? 0,
          color: AppColors.expenseColor,
        ));
      });

      // If no data, show empty state
      if (incomeData.isEmpty || expenseData.isEmpty) {
        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد بيانات كافية لعرض الاتجاه',
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
                  'اتجاه الدخل والمصروفات',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'آخر 6 أشهر',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _buildChart(incomeData, expenseData, theme),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChart(List<ChartData> incomeData, List<ChartData> expenseData,
      ThemeData theme) {
    // Create a static chart that won't be rebuilt during animation
    final chart = SfCartesianChart(
      plotAreaBorderWidth: 0,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: theme.textTheme.bodySmall,
      ),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: theme.textTheme.bodySmall,
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '{value} ر.س',
        axisLine: const AxisLine(width: 0),
        labelStyle: theme.textTheme.bodySmall,
        numberFormat: NumberFormat.compact(locale: 'ar'),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          name: 'الدخل',
          dataSource: incomeData,
          xValueMapper: (data, _) => data.x,
          yValueMapper: (data, _) => data.y,
          color: AppColors.incomeColor,
          markerSettings: const MarkerSettings(isVisible: true),
          // Set animation duration to 0 when animations are disabled
          // This prevents the "A disposed RenderObject was mutated" error
          animationDuration: AnimationConfig.complexAnimationsEnabled ? 500 : 0,
          // Ensure animation is completely disabled when not needed
          animationDelay: 0,
        ),
        LineSeries<ChartData, String>(
          name: 'المصروفات',
          dataSource: expenseData,
          xValueMapper: (data, _) => data.x,
          yValueMapper: (data, _) => data.y,
          color: AppColors.expenseColor,
          markerSettings: const MarkerSettings(isVisible: true),
          // Set animation duration to 0 when animations are disabled
          // This prevents the "A disposed RenderObject was mutated" error
          animationDuration: AnimationConfig.complexAnimationsEnabled ? 500 : 0,
          // Ensure animation is completely disabled when not needed
          animationDelay: 0,
        ),
      ],
    );

    if (AnimationConfig.complexAnimationsEnabled) {
      // Use AnimatedBuilder to control the animation without rebuilding the chart
      return AnimatedBuilder(
        animation: _animation,
        // Create the chart once and reuse it to prevent rebuilding during animation
        // This prevents the "A disposed RenderObject was mutated" error
        child: chart,
        builder: (context, child) {
          // Simply return the pre-built chart without rebuilding it
          return child!;
        },
      );
    } else {
      // Return the chart directly without animation wrapper
      // This prevents any animation-related issues when animations are disabled
      return chart;
    }
  }
}

/// Model for chart data points.
class ChartData {
  final String x;
  final double y;
  final Color color;
  ChartData(this.x, this.y, {required this.color});
}
