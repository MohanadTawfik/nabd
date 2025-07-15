import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:provider/provider.dart';

// // 1. الأيقونة
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: const Color(0xff8952ff).withOpacity(0.15),
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(
//             Icons.lightbulb_outline,
//             color: Color(0xff8952ff),
//             size: 28,
//           ),
//         ),

class InsightCard extends StatelessWidget {
  const InsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. نستخدم Consumer للاستماع للتغيرات في AppData
    return Consumer<AppData>(
      builder: (context, appData, child) {
        // 2. نحصل على النصيحة الذكية من الدالة الجديدة
        final insightText = appData.dailyInsight;

        return Card(
          color: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نصيحة اليوم',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      // 3. عرض النصيحة الديناميكية
                      Text(
                        insightText,
                        style: Theme.of(context).textTheme.bodyMedium,
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
}
