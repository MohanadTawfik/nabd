import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      content: Text(content, style: Theme.of(context).textTheme.bodyMedium),
      actions: <Widget>[
        TextButton(
          child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          onPressed: onConfirm,
          child: const Text('تأكيد الحذف'),
        ),
      ],
    );
  }
}
