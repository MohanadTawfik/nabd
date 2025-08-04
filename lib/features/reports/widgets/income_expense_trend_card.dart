import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// A widget that displays income vs expense trend using a line chart.
/// Uses fl_chart for rendering the chart with a clean, modern look.
class IncomeExpenseTrendCard extends StatefulWidget {
  const IncomeExpenseTrendCard({Key? key}) : super(key: key);

  @override
  State<IncomeExpenseTrendCard> createState() => _IncomeExpenseTrendCardState();
}

class _IncomeExpenseTrendCardState extends State<IncomeExpenseTrendCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _isMounted = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionsProvider>(
      builder: (context, transactionsProvider, _) {
        final transactions = transactionsProvider.transactions;

        // Group transactions by month
        final monthlyData = <String, Map<String, double>>{};

        for (final transaction in transactions) {
          final monthYear = DateFormat('MMM yyyy').format(transaction.date);
          monthlyData.putIfAbsent(
              monthYear, () => {'income': 0.0, 'expense': 0.0});

          if (transaction.type == TransactionType.income) {
            monthlyData[monthYear]!['income'] =
                (monthlyData[monthYear]!['income']! + transaction.amount)
                    .toDouble();
          } else {
            monthlyData[monthYear]!['expense'] =
                (monthlyData[monthYear]!['expense']! + transaction.amount)
                    .abs()
                    .toDouble();
          }
        }

        // Sort months chronologically
        final sortedMonths = monthlyData.keys.toList()
          ..sort((a, b) => DateFormat('MMM yyyy')
              .parse(a)
              .compareTo(DateFormat('MMM yyyy').parse(b)));

        // Limit to last 6 months for better readability
        final recentMonths = sortedMonths.length <= 6
            ? sortedMonths
            : sortedMonths.sublist(sortedMonths.length - 6);

        // Prepare data for the chart
        final incomeData = recentMonths
            .map((month) => monthlyData[month]!['income']!)
            .toList();

        final expenseData = recentMonths
            .map((month) => monthlyData[month]!['expense']!)
            .toList();

        // Find max value for Y axis scaling
        final maxY =
            [...incomeData, ...expenseData].reduce((a, b) => a > b ? a : b) *
                1.2;

        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اتجاه الدخل والمصروفات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value >= 0 && value < recentMonths.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      recentMonths[value.toInt()],
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: recentMonths.length - 1,
                        minY: 0,
                        maxY: maxY,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            // tooltipRoundedRadius: 8,
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 0,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((touchedSpot) {
                                return LineTooltipItem(
                                  '${touchedSpot.y.toStringAsFixed(2)}',
                                  const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: incomeData.asMap().entries.map((e) {
                              return FlSpot(
                                e.key.toDouble(),
                                e.value * _animation.value,
                              );
                            }).toList(),
                            isCurved: true,
                            color: AppColors.incomeColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.incomeColor.withOpacity(0.1),
                            ),
                          ),
                          LineChartBarData(
                            spots: expenseData.asMap().entries.map((e) {
                              return FlSpot(
                                e.key.toDouble(),
                                e.value * _animation.value,
                              );
                            }).toList(),
                            isCurved: true,
                            color: AppColors.expenseColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.expenseColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('الدخل', AppColors.incomeColor),
                  const SizedBox(width: 16),
                  _buildLegendItem('المصروفات', AppColors.expenseColor),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

/// Model for chart data points.
class ChartData {
  final String x;
  final double y;
  final Color color;
  ChartData(this.x, this.y, {required this.color});
}
