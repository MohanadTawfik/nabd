import 'package:flutter/material.dart';

class SettingsItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool showArrow;
  final EdgeInsetsGeometry? padding;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.showArrow = true,
    this.padding,
  });

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasTrailing = widget.trailing != null || widget.showArrow;

    return Padding(
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          borderRadius: BorderRadius.circular(12),
          splashColor: theme.primaryColor.withOpacity(0.1),
          highlightColor: theme.primaryColor.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isPressed
                  ? (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.02))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Leading Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: isDark ? theme.iconTheme.color : theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing Widget
                if (hasTrailing) ...[
                  if (widget.trailing != null) widget.trailing!,
                  if (widget.trailing == null && widget.showArrow)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
