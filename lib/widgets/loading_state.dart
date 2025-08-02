import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

/// A reusable widget for displaying loading states
class LoadingState extends StatelessWidget {
  final String? message;
  final bool useShimmer;
  final Widget? shimmerChild;

  const LoadingState({
    super.key,
    this.message,
    this.useShimmer = false,
    this.shimmerChild,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (useShimmer && shimmerChild != null) {
      return Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: shimmerChild!,
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          if (message != null) ...[  
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  /// Create a shimmer loading effect for a list
  static Widget shimmerList({
    int itemCount = 5,
    double height = 80,
    double? width,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    return LoadingState(
      useShimmer: true,
      shimmerChild: ListView.builder(
        itemCount: itemCount,
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              width: width ?? double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Create a shimmer loading effect for a grid
  static Widget shimmerGrid({
    int crossAxisCount = 2,
    int itemCount = 6,
    double height = 120,
    EdgeInsets padding = const EdgeInsets.all(16),
    double crossAxisSpacing = 16,
    double mainAxisSpacing = 16,
  }) {
    return LoadingState(
      useShimmer: true,
      shimmerChild: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: 1,
        ),
        itemCount: itemCount,
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}