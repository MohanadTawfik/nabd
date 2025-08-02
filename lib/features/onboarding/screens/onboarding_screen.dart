import 'package:flutter/material.dart';
import 'package:nabd/features/auth/screens/login_screen.dart';
import 'package:nabd/features/onboarding/widgets/onboarding_page_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // قائمة بصفحات البداية
  final List<Widget> _pages = [
    const OnboardingPageWidget(
      icon: Icons.wallet_outlined,
      title: 'أهلاً بك في مصروفي ',
      description: 'سيطر على أموالك، وحقق أحلامك. رفيقك المالي في جيبك.',
    ),
    const OnboardingPageWidget(
      icon: Icons.lightbulb_outline,
      title: 'نصائح ذكية وبصيرة',
      description: 'احصل على رؤى مخصصة حول إنفاقك وفرص التوفير بذكاء.',
    ),
    const OnboardingPageWidget(
      icon: Icons.rocket_launch_outlined,
      title: 'أطلق العنان لأحلامك',
      description: 'حدد أهدافك المالية وشاهدها تتحقق أمام عينيك خطوة بخطوة.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. الصفحات القابلة للتمرير
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: _pages,
              ),
            ),

            // 2. مؤشر الصفحات (النقاط)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(context: context, index: index),
              ),
            ),
            const SizedBox(height: 40),

            // 3. زر "التالي" أو "لنبدأ"
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_currentPage == _pages.length - 1) {
                      // إذا كانت هذه هي الصفحة الأخيرة، حفظ حالة الإكمال والانتقال لشاشة تسجيل الدخول
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('hasCompletedOnboarding', true);

                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    } else {
                      // انتقل للصفحة التالية بحركة ناعمة
                      _pageController.jumpToPage(_currentPage + 1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'لنبدأ الرحلة!'
                        : 'التالي',
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت مساعد لبناء نقاط مؤشر الصفحة
  Widget _buildDot({required BuildContext context, required int index}) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 10,
      width: _currentPage == index ? 24 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
