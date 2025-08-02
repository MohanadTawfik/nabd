import 'package:flutter/material.dart';
import 'package:nabd/features/journey/models/timeline_item_model.dart';
import 'package:nabd/features/journey/widgets/timeline_painter.dart';
import 'package:nabd/services/journey_service.dart';
import 'package:nabd/widgets/empty_state.dart';
import 'package:nabd/widgets/error_state.dart';
import 'package:nabd/widgets/loading_state.dart';
import 'package:nabd/widgets/timeline_item_card.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  bool _isLoading = true;
  String? _error;
  List<TimelineItem> _timelineItems = [];

  // Build a timeline card based on the timeline item type
  Widget _buildTimelineCard(
      BuildContext context, TimelineItem item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Right side: Date column
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.date.day}/${item.date.month}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${item.date.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Center: Timeline dot
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(item.icon, color: Colors.white, size: 16),
          ),

          // Left side: Content card
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (item.type == TimelineItemType.achievement)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('إنجاز',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    if (item.type == TimelineItemType.alert)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text('تنبيه',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTimelineItems();
  }

  Future<void> _loadTimelineItems() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await JourneyService().getTimelineItems();

      if (response.success && response.data != null) {
        setState(() {
          _timelineItems = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'جاري تحميل الخط الزمني...');
    }

    if (_error != null) {
      return ErrorState(
        message: _error!,
        onActionPressed: _loadTimelineItems,
      );
    }

    if (_timelineItems.isEmpty) {
      return const EmptyState(
        icon: Icons.timeline_outlined,
        message: 'ابدأ رحلتك بتسجيل أول معاملة!',
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTimelineItems,
        child: Stack(
          children: [
            // Timeline line on the right side
            Positioned.fill(
              right: 24, // Right padding for the timeline line
              child: CustomPaint(
                painter: TimelinePainter(
                  lineColor: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
            ),
            // Timeline items list (static, no animation)
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _timelineItems.length,
              itemBuilder: (context, index) {
                final item = _timelineItems[index];
                return _buildTimelineCard(context, item, index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
