import 'package:flutter/material.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:flutter/animation.dart';
import 'package:nabd/utils/animation_config.dart';

/// Animated display for the current balance with glassmorphic effect.
class AnimatedBalanceCard extends StatefulWidget {
  final double balance;
  const AnimatedBalanceCard({Key? key, required this.balance})
      : super(key: key);

  @override
  State<AnimatedBalanceCard> createState() => _AnimatedBalanceCardState();
}

class _AnimatedBalanceCardState extends State<AnimatedBalanceCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24, // Increased border radius for more modern look
      blurStrength: 10, // Increased blur for better glass effect
      child: _buildCardContent(theme, isDark),
    );
  }

  Widget _buildCardContent(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance Label with improved styling
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'الرصيد الحالي',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'شهري',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16), // Increased spacing

        // Balance Amount
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.balance.toStringAsFixed(2),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                height: 1.1,
                fontSize: 32,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'ريال',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress Indicator
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.65, // Example value, should be dynamic
            minHeight: 4,
            backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Progress Text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '65% من الميزانية الشهرية',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
            Text(
              '3,200 / 5,000 ريال',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.white70 : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
