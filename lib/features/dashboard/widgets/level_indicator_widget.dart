import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:provider/provider.dart';

class LevelIndicatorWidget extends StatelessWidget {
  const LevelIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final score = appData.financialHealthScore;
        final levelName = appData.financialLevelName;
        final levelColor =
            Color.lerp(AppColors.textSecondary, AppColors.accentColor, score)!;

        return Card(
          color: Theme.of(context).cardColor.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('مستواك المالي: $levelName',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold)),
                    Icon(Icons.shield_outlined,
                        color: Theme.of(context).iconTheme.color),
                  ],
                ),
                AppPaddings.smallHeight,
                LinearProgressIndicator(
                  value: score,
                  backgroundColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
