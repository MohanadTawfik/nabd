import 'package:flutter/material.dart';
import 'package:nabd/features/reports/widgets/expenses_by_category_card.dart';
import 'package:nabd/features/reports/widgets/income_expense_trend_card.dart';
import 'package:nabd/features/reports/widgets/monthly_summary_card.dart';
import 'package:provider/provider.dart';
import 'story_viewer_screen.dart';
import 'package:nabd/features/reports/reports_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, reportsProvider, child) {
        if (reportsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (reportsProvider.error != null) {
          return Center(child: Text('خطأ: ${reportsProvider.error}'));
        }
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_fill_outlined),
                    label: const Text('عرض قصة هذا الشهر',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const StoryViewerScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.8),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const MonthlySummaryCard(),
                const SizedBox(height: 24),
                const IncomeExpenseTrendCard(),
                const SizedBox(height: 24),
                const ExpensesByCategoryCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}
