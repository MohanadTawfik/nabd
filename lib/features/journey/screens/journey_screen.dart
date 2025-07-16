import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/journey/widgets/milestone_event_card.dart';
import 'package:nabd/features/journey/widgets/timeline_event_card.dart';
import 'package:nabd/features/journey/widgets/timeline_painter.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          // 2. استخدام القائمة المدمجة الجديدة
          final timelineItems = appData.timelineItems;

          if (timelineItems.isEmpty) {
            return const Center(child: Text('ابدأ رحلتك بتسجيل أول معاملة!'));
          }

          return Stack(
            children: [
              // 1. هذا هو الإصلاح: استخدمنا right بدلاً من left
              // ليظهر الخط على اليمين في واجهة اللغة العربية
              Positioned.fill(
                right: 24, // يترك مساحة 28 بكسل من اليمين لمركز الخط
                child: CustomPaint(
                  painter: TimelinePainter(
                      lineColor:
                          Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
              ),
              AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: timelineItems.length,
                  itemBuilder: (context, index) {
                    final item = timelineItems[index];
                    Widget card;
                    if (item.event is Transaction) {
                      card = TimelineEventCard(transaction: item.event);
                    } else if (item.event is Goal) {
                      card = MilestoneEventCard(goal: item.event);
                    } else {
                      card = const SizedBox.shrink();
                    }

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: card),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
