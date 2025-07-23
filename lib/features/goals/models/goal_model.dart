import 'package:flutter/material.dart';

class Goal {
  final String name;
  final IconData icon;
  final Color color;
  double savedAmount;
  final double totalAmount;

  Goal({
    required this.name,
    required this.icon,
    required this.totalAmount,
    required this.color,
    this.savedAmount = 0.0,
  });
}
