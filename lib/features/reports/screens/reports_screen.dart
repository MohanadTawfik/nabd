import 'package:flutter/material.dart';
import 'package:nabd/features/reports/widgets/expenses_by_category_card.dart';
import 'package:nabd/features/reports/widgets/monthly_summary_card.dart';
import 'story_viewer_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 2. زر إطلاق القصة الجديد
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill_outlined),
                label: const Text('عرض قصة هذا الشهر',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).push(
                    // استخدام PageRoute بدون تأثير انتقال للشعور بأنها طبقة فوقية
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const StoryViewerScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0xff8952ff).withOpacity(0.8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const MonthlySummaryCard(),
            const SizedBox(height: 24),
            const ExpensesByCategoryCard(),
          ],
        ),
      ),
    );
  }
}
