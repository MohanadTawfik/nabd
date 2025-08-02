import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart'
    show
        SfCartesianChart,
        SfCircularChart,
        CartesianSeries,
        PieSeries,
        BarSeries,
        CategoryAxis,
        MajorGridLines,
        DataLabelSettings;
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/utils/animation_config.dart';

// These widgets provide reusable chart components with proper animation handling
// to prevent the "A disposed RenderObject was mutated" error

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
          // Set animation duration to 0 when animations are disabled
          // This prevents the "A disposed RenderObject was mutated" error
          animationDuration: AnimationConfig.complexAnimationsEnabled ? 500 : 0,
          // Ensure animation is completely disabled when not needed
          animationDelay: 0,
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
      series: <CartesianSeries<ChartData, String>>[
        BarSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.y,
          color: AppColors.primaryColor,
          width: 0.6,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          // Set animation duration to 0 when animations are disabled
          // This prevents the "A disposed RenderObject was mutated" error
          animationDuration: AnimationConfig.complexAnimationsEnabled ? 500 : 0,
          // Ensure animation is completely disabled when not needed
          animationDelay: 0,
        )
      ],
    );
  }
}
