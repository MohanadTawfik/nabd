import 'package:flutter/material.dart';
import 'package:nabd/features/journey/screens/journey_screen.dart';
import 'package:nabd/features/reports/screens/reports_screen.dart';

class InsightsHubScreen extends StatelessWidget {
  const InsightsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. استخدام DefaultTabController لتنظيم كل شيء
    return DefaultTabController(
      length: 2, // لدينا قسمين
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مركز الرؤى'),
          // 2. بناء شريط التبويب الأنيق
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3.0,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Tajawal'),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Tajawal',
              // fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'التحليلات والتقارير'),
              Tab(text: 'رحلتك المالية'),
            ],
          ),
        ),
        // 3. عرض المحتوى بناءً على التبويب المختار
        body: const TabBarView(
          children: [
            ReportsScreen(), // شاشة التقارير التحليلية
            JourneyScreen(), // شاشة الرحلة العاطفية
          ],
        ),
      ),
    );
  }
}
