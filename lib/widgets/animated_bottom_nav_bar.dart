import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';

/// A floating glassmorphic bottom navigation bar with animated icons.
class AnimatedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  const AnimatedBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white.withOpacity(0.6)
              : Colors.black.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                index: 0,
                isSelected: selectedIndex == 0,
                onTap: onItemSelected,
              ),
              _NavItem(
                icon: Icons.list,
                index: 1,
                isSelected: selectedIndex == 1,
                onTap: onItemSelected,
              ),
              SizedBox(width: 56), // spacing for FAB
              _NavItem(
                icon: Icons.emoji_events,
                index: 2,
                isSelected: selectedIndex == 2,
                onTap: onItemSelected,
              ),
              _NavItem(
                icon: Icons.settings,
                index: 3,
                isSelected: selectedIndex == 3,
                onTap: onItemSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _NavItem({
    Key? key,
    required this.index,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          size: isSelected ? 28 : 24,
          color: isSelected
              ? AppColors.primaryColor
              : Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}
