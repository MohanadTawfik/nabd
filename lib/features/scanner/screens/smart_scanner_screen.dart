import 'dart:async';
import 'package:flutter/material.dart';

class SmartScannerScreen extends StatefulWidget {
  const SmartScannerScreen({super.key});

  @override
  State<SmartScannerScreen> createState() => _SmartScannerScreenState();
}

class _SmartScannerScreenState extends State<SmartScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerAnimationController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerAnimationController.dispose();
    super.dispose();
  }

  void _startProcessing() {
    setState(() {
      _isProcessing = true;
    });
    // محاكاة عملية المعالجة
    Timer(const Duration(seconds: 3), () {
      // هنا يمكننا إرجاع البيانات المستخرجة
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. محاكاة واجهة الكاميرا
          Container(
            color: Colors.black,
            child: const Center(
                child: Text('Camera Preview',
                    style: TextStyle(color: Colors.grey))),
          ),

          // 2. إطار التوجيه للمسح
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // 3. خط المسح المتحرك
          AnimatedBuilder(
            animation: _scannerAnimationController,
            builder: (context, child) {
              return Positioned(
                top: (MediaQuery.of(context).size.height * 0.35) +
                    (_scannerAnimationController.value *
                        MediaQuery.of(context).size.height *
                        0.3),
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor,
                        blurRadius: 8.0,
                        spreadRadius: 1.0,
                      )
                    ],
                  ),
                ),
              );
            },
          ),

          // 4. طبقة علوية مع زر الإغلاق
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // 5. زر المسح والطبقة السفلية
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: GestureDetector(
                  onTap: _startProcessing,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 4),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 6. شاشة المعالجة (تظهر عند الضغط على المسح)
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text('جاري تحليل الفاتورة...',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
