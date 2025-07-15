import 'package:flutter/material.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم نفس تصميم البطاقة الأساسي
    return Card(
      color: const Color(0xff161b22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          // نرتب العناصر بشكل أفقي
          children: [
            // 1. الأيقونة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff8952ff).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                color: Color(0xff8952ff),
                size: 28,
              ),
            ),
            const SizedBox(width: 16), // مسافة بين الأيقونة والنص

            // 2. النص
            Expanded(
              // Expanded تجعل النص يأخذ كل المساحة المتبقية
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'نصيحة اليوم',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'إنفاقك على المقاهي أقل هذا الأسبوع. عمل رائع! استمر بذلك.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
