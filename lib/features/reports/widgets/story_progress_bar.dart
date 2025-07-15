import 'package:flutter/material.dart';

class StoryProgressBar extends StatelessWidget {
  final int pageCount;
  final int currentPageIndex;
  final AnimationController animationController;

  const StoryProgressBar({
    super.key,
    required this.pageCount,
    required this.currentPageIndex,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        pageCount,
        (index) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: (index == currentPageIndex)
                      ? animationController.value
                      : (index < currentPageIndex ? 1.0 : 0.0),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3.0,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
