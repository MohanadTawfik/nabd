import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/utils/animation_config.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

// 1. حولنا الويدجت إلى StatefulWidget لإدارة الأنيميشن
class CashFlowRiverCard extends StatefulWidget {
  const CashFlowRiverCard({super.key});

  @override
  State<CashFlowRiverCard> createState() => _CashFlowRiverCardState();
}

class _CashFlowRiverCardState extends State<CashFlowRiverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // 2. إعداد متحكم الأنيميشن ليعمل عند ظهور الويدجت
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationConfig.standardDuration,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionsProvider>(
      builder: (context, txProvider, child) {
        final totalIncome = txProvider.transactions
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final expenseMap = <String, double>{};
        for (var t in txProvider.transactions
            .where((t) => t.type == TransactionType.expense)) {
          expenseMap.update(t.category.name, (value) => value + t.amount,
              ifAbsent: () => t.amount);
        }
        final expenses = expenseMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (expenses.isEmpty || totalIncome == 0) {
          return Card(
              color: Theme.of(context).cardColor,
              child: const Padding(
                  padding: EdgeInsets.all(60.0),
                  child: Center(
                      child: Text('أضف دخلاً ومصروفات لترى نهر التدفق.'))));
        }

        return Card(
          color: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نهر التدفق المالي',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: (expenses.length * 55.0) + 40.0,
                  child: Row(
                    children: [
                      _buildNode(context, 'الدخل', totalIncome,
                          Theme.of(context).primaryColor),
                      Expanded(
                        // 3. استخدام AnimatedBuilder لإعادة رسم النهر مع الأنيميشن
                        child: AnimationConfig.complexAnimationsEnabled
                            ? AnimatedBuilder(
                                animation: _animationController,
                                // Don't use child parameter here as we can't modify painter property
                                builder: (context, _) {
                                  // Create a new CustomPaint with the current animation value
                                  return CustomPaint(
                                    painter: RiverPainter(
                                      expenses: expenses,
                                      totalIncome: totalIncome,
                                      theme: Theme.of(context),
                                      animationProgress:
                                          _animationController.value,
                                    ),
                                  );
                                },
                              )
                            : CustomPaint(
                                painter: RiverPainter(
                                  expenses: expenses,
                                  totalIncome: totalIncome,
                                  theme: Theme.of(context),
                                  animationProgress:
                                      1.0, // Full progress when animations disabled
                                ),
                              ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: expenses.map((expense) {
                          return _buildNode(context, expense.key, expense.value,
                              Colors.red.shade400);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNode(
      BuildContext context, String name, double value, Color color) {
    final format = NumberFormat.compact(locale: 'ar');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(minWidth: 80),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(format.format(value),
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// 4. رسام النهر المطور والاحترافي
class RiverPainter extends CustomPainter {
  final List<MapEntry<String, double>> expenses;
  final double totalIncome;
  final ThemeData theme;
  final double animationProgress;

  RiverPainter({
    required this.expenses,
    required this.totalIncome,
    required this.theme,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startPoint = Offset(0, size.height / 2);
    final maxRiverThickness = size.height * 0.6; // السماكة الإجمالية للنهر

    for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      final expenseRatio = expense.value / totalIncome;
      // 5. سماكة كل فرع من النهر تعتمد على قيمته
      final strokeWidth = expenseRatio * maxRiverThickness;

      final paint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // 6. استخدام تدرج لوني لكل فرع ليبدو حياً
      paint.shader = ui.Gradient.linear(
        Offset(0, startPoint.dy),
        Offset(size.width, startPoint.dy),
        [
          theme.primaryColor.withOpacity(0.7),
          Colors.red.withOpacity(0.7),
        ],
      );

      final endPoint = Offset(
          size.width, (size.height / (expenses.length * 2)) * (1 + i * 2));

      final path = Path();
      path.moveTo(startPoint.dx, startPoint.dy);
      path.cubicTo(
        startPoint.dx + size.width / 2,
        startPoint.dy,
        endPoint.dx - size.width / 2,
        endPoint.dy,
        endPoint.dx,
        endPoint.dy,
      );

      // 7. رسم النهر بناءً على تقدم الأنيميشن
      for (ui.PathMetric pathMetric in path.computeMetrics()) {
        final extractPath = pathMetric.extractPath(
          0.0,
          pathMetric.length * animationProgress, // النقطة السحرية
        );
        canvas.drawPath(extractPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RiverPainter oldDelegate) {
    // إعادة الرسم فقط عند تغير قيمة الأنيميشن
    return oldDelegate.animationProgress != animationProgress;
  }
}
