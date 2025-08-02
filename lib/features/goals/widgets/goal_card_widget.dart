import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/utils/animation_config.dart';

/// A modern, animated card widget that displays a savings goal with progress.
/// Features glassmorphic design, smooth animations, and interactive elements.
class GoalCardWidget extends StatefulWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GoalCardWidget({
    super.key,
    required this.goal,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<GoalCardWidget> createState() => _GoalCardWidgetState();
}

class _GoalCardWidgetState extends State<GoalCardWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (widget.goal.savedAmount / widget.goal.totalAmount)
        .clamp(0.0, 1.0);
    final format = NumberFormat("#,##0", "ar");
    final remaining = widget.goal.totalAmount - widget.goal.savedAmount;
    final isCompleted = progress >= 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: _isPressed ? 0.9 : 1.0,
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.goal.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: Colors.green.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'مكتمل',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.green.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress indicator
              Stack(
                children: [
                  // Background track
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.goal.color,
                            widget.goal.color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: widget.goal.color.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress percentage
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isCompleted
                          ? Colors.green.shade400
                          : widget.goal.color,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),

                  // Amount saved
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${format.format(widget.goal.savedAmount)} / ${format.format(widget.goal.totalAmount)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'المتبقي: ${format.format(remaining)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
