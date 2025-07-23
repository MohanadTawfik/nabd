import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/theme/app_colors.dart';
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
            padding: AppPaddings.allMedium,
            child: Row(
              children: [
                Container(
                  padding: AppPaddings.allSmall,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                AppPaddings.mediumWidth,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نصيحة اليوم',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.onSurface),
                      ),
                      AppPaddings.extraSmallHeight,
                      // 3. عرض النصيحة الديناميكية
                      Text(
                        insightText,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface),
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
