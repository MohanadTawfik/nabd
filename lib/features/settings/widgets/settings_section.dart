import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';

import 'settings_item.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;
  final bool showDivider;

  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                title.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => showDivider
                    ? Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 16,
                        endIndent: 16,
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                      )
                    : const SizedBox.shrink(),
                itemBuilder: (context, index) => items[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
