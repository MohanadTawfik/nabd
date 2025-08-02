import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';

/// A reusable widget for displaying empty states
class EmptyState extends StatelessWidget {
  final String? title;
  final String message;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final dynamic iconBackground;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? child;

  const EmptyState({
    super.key,
    this.title,
    required this.message,
    this.icon = Icons.search_off_rounded,
    this.iconSize = 72,
    this.iconColor,
    this.iconBackground,
    this.titleStyle,
    this.messageStyle,
    this.actionText,
    this.onActionPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.grey400
        : AppColors.grey600;
    
    final defaultTextStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.grey600
              : AppColors.grey400,
        );
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(context, defaultIconColor),
            const SizedBox(height: 16),
            if (title != null && title!.isNotEmpty) ...[  
              Text(
                title!,
                textAlign: TextAlign.center,
                style: titleStyle ?? defaultTextStyle,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: messageStyle ?? defaultTextStyle,
            ),
            if (onActionPressed != null && actionText != null) ...[  
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
            if (child != null) ...[  
              const SizedBox(height: 16),
              child!,
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildIcon(BuildContext context, Color defaultColor) {
    // Handle different types of icon backgrounds
    if (iconBackground != null) {
      return Container(
        width: iconSize + 16,
        height: iconSize + 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: iconBackground is Gradient ? iconBackground : null,
          color: iconBackground is Color ? iconBackground : null,
        ),
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? Colors.white,
          ),
        ),
      );
    } else {
      return Icon(
        icon,
        size: iconSize,
        color: iconColor ?? defaultColor,
      );
    }
  }
}
