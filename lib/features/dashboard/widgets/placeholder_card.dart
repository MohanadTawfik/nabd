import 'package:flutter/material.dart';

class PlaceholderCard extends StatelessWidget {
  final String title;
  const PlaceholderCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff161b22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
