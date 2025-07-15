import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title,
          style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.9),
              fontSize: 16)),
      // 1. إذا كان الـ trailing هو Switch، لا نعرض السهم
      trailing: (trailing is Switch)
          ? trailing
          : trailing ??
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Theme.of(context).iconTheme.color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
