import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';

/// A reusable widget for displaying error states
class ErrorState extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final IconData icon;

  const ErrorState({
    super.key,
    required this.message,
    this.actionText = 'إعادة المحاولة',
    this.onActionPressed,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: AppColors.errorColor.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.grey700
                        : AppColors.grey300,
                  ),
            ),
            if (onActionPressed != null && actionText != null) ...[  
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Create an error state for network errors
  factory ErrorState.network({
    VoidCallback? onRetry,
    String message = 'حدث خطأ في الاتصال بالشبكة',
  }) {
    return ErrorState(
      message: message,
      actionText: 'إعادة المحاولة',
      onActionPressed: onRetry,
      icon: Icons.wifi_off_rounded,
    );
  }

  /// Create an error state for server errors
  factory ErrorState.server({
    VoidCallback? onRetry,
    String message = 'حدث خطأ في الخادم',
  }) {
    return ErrorState(
      message: message,
      actionText: 'إعادة المحاولة',
      onActionPressed: onRetry,
      icon: Icons.cloud_off_rounded,
    );
  }

  /// Create an error state for not found errors
  factory ErrorState.notFound({
    VoidCallback? onRetry,
    String message = 'لم يتم العثور على البيانات المطلوبة',
  }) {
    return ErrorState(
      message: message,
      actionText: 'إعادة المحاولة',
      onActionPressed: onRetry,
      icon: Icons.search_off_rounded,
    );
  }
}