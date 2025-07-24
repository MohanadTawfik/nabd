import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:nabd/theme/app_colors.dart';

/// Model for chart data points.
class ChartData {
  final String x;
  final double y;
  final Color color;
  ChartData(this.x, this.y, {required this.color});
}

/// Pie chart with data labels.
class PieChartWidget extends StatelessWidget {
  final List<ChartData> data;
  const PieChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      series: <PieSeries<ChartData, String>>[
        PieSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.y,
          pointColorMapper: (d, _) => d.color,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          radius: '80%',
        )
      ],
    );
  }
}

/// Bar chart with categorical X axis.
class BarChartWidget extends StatelessWidget {
  final List<ChartData> data;
  const BarChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      series: <BarSeries<ChartData, String>>[
        BarSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.y,
          color: AppColors.primaryColor,
          width: 0.6,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
    );
  }
}
