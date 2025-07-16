import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:provider/provider.dart';

class LevelIndicatorWidget extends StatelessWidget {
  const LevelIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final score = appData.financialHealthScore;
        final levelName = appData.financialLevelName;
        final levelColor = Color.lerp(Colors.grey, Colors.amber, score)!;

        return Card(
          color: Theme.of(context).cardColor..withValues(alpha: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('مستواك المالي: $levelName',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Icon(Icons.shield_outlined, color: levelColor),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: score,
                  backgroundColor: levelColor..withValues(alpha: 0.2),
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
