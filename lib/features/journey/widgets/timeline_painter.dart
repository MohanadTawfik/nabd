import 'package:flutter/material.dart';

class TimelinePainter extends CustomPainter {
  final Color lineColor;
  TimelinePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0;

    // رسم الخط العمودي
    // canvas.drawLine(const Offset(0, 0), Offset(0, size.height), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
