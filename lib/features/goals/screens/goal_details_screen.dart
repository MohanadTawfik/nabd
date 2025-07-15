import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/goals/models/goal_model.dart';

class GoalDetailsScreen extends StatelessWidget {
  final Goal goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = (goal.savedAmount / goal.totalAmount).clamp(0.0, 1.0);
    final format = NumberFormat("#,##0", "en_US");

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        backgroundColor:
            goal.color.withOpacity(0.2), // لون الشريط العلوي من لون الهدف
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. "الكوكب" الكبير الذي يعرض التقدم
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: goal.color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(goal.icon, color: goal.color, size: 60),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. تفاصيل المبالغ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailChip('المبلغ المدخر',
                    format.format(goal.savedAmount), Colors.green),
                _buildDetailChip(
                    'المبلغ المتبقي',
                    format.format(goal.totalAmount - goal.savedAmount),
                    Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailChip(
                'المبلغ الإجمالي', format.format(goal.totalAmount), Colors.blue,
                isFullWidth: true),

            const SizedBox(height: 32),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),

            // 3. قائمة المساهمات (افتراضية الآن)
            const Text('سجل المساهمات',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildContributionItem('دفعة أولى', '500,000',
                DateTime.now().subtract(const Duration(days: 30))),
            _buildContributionItem('توفير شهري', '250,000',
                DateTime.now().subtract(const Duration(days: 5))),
          ],
        ),
      ),
    );
  }

  // ويدجت مساعد لبناء بطاقات التفاصيل الصغيرة
  Widget _buildDetailChip(String title, String value, Color color,
      {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text('$value ريال',
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ويدجت مساعد لبناء عنصر في قائمة المساهمات
  Widget _buildContributionItem(String title, String amount, DateTime date) {
    return Card(
      color: const Color(0xff161b22),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.arrow_upward)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(DateFormat.yMMMd('ar').format(date),
            style: const TextStyle(color: Colors.white70)),
        trailing: Text('+$amount',
            style: const TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
