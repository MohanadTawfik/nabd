import 'package:flutter/material.dart';

class GoalItemWidget extends StatelessWidget {
  final String name;
  final IconData icon;
  final double progress;

  const GoalItemWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // هذه هي "الهالة المضيئة" التي تمثل التقدم
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 5,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xff1fddff)),
              ),
              // هذا هو "الكوكب" الذي يحتوي على الأيقونة
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xff161b22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white70, size: 28),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}
