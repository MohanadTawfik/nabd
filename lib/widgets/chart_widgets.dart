import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nabd/theme/app_colors.dart';

// These widgets provide reusable chart components using fl_chart

/// Model for chart data points.
class ChartData {
  final String x;
  final double y;
  final Color color;
  ChartData(this.x, this.y, {required this.color});

  // Convert to PieChartSectionData for fl_chart
  PieChartSectionData toPieChartSectionData(bool isTouched) {
    return PieChartSectionData(
      color: color,
      value: y,
      title: '${y.toInt()}',
      radius: isTouched ? 60 : 50,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // Convert to BarChartGroupData for fl_chart
  BarChartGroupData toBarChartGroupData(int x, bool isTouched) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }
}

/// Pie chart with data labels.
class PieChartWidget extends StatelessWidget {
  final List<ChartData> data;
  const PieChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sections: data.asMap().entries.map((entry) {
            return entry.value.toPieChartSectionData(false);
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          startDegreeOffset: 180,
        ),
      ),
    );
  }
}

/// Bar chart with categorical X axis.
class BarChartWidget extends StatelessWidget {
  final List<ChartData> data;
  final double? maxY;
  final bool showGrid;

  const BarChartWidget({
    Key? key,
    required this.data,
    this.maxY,
    this.showGrid = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 0,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toStringAsFixed(2),
                const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].x,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
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
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.y,
                color: item.color ?? AppColors.primaryColor,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
