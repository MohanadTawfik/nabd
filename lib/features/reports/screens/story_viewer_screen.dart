import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/app_data.dart';
import '../widgets/story_page.dart';
import '../widgets/story_progress_bar.dart';

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({super.key});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStory(index: 0);
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
  }

  void _loadStory({required int index, bool animateToPage = true}) {
    _animationController.stop();
    _animationController.reset();
    _animationController.duration = const Duration(seconds: 5);
    _animationController.forward();

    if (animateToPage && _pageController.hasClients) {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
    }
  }

  void _nextStory() {
    final appData = Provider.of<AppData>(context, listen: false);
    final storyPages = _buildStoryPages(appData);
    if (_currentPageIndex < storyPages.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
      _loadStory(index: _currentPageIndex);
    } else {
      // هذا هو الإصلاح: نستخدم Future.delayed لضمان إغلاق الشاشة بسلاسة
      // بعد انتهاء كل عمليات الأنيميشن.
      Future.delayed(Duration.zero, () {
        if (mounted) {
          // نتأكد أن الويدجت لا يزال موجوداً
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _previousStory() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
      _loadStory(index: _currentPageIndex);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final storyPages = _buildStoryPages(appData);

    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dx = details.globalPosition.dx;
        if (dx < screenWidth / 3) {
          _previousStory();
        } else if (dx > screenWidth * 2 / 3) {
          _nextStory();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff161b22),
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: storyPages,
              ),
              Positioned(
                top: 12.0,
                left: 10.0,
                right: 10.0,
                child: StoryProgressBar(
                  pageCount: storyPages.length,
                  currentPageIndex: _currentPageIndex,
                  animationController: _animationController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStoryPages(AppData appData) {
    // ... (هذا الجزء لم يتغير)
    return [
      StoryPage(
        key: const ValueKey('page1'),
        title: 'ملخص شهر يوليو',
        icon: Icons.calendar_today,
        content: Text.rich(
          TextSpan(
            style:
                const TextStyle(color: Colors.white, fontSize: 24, height: 1.5),
            children: [
              const TextSpan(text: 'كان شهراً حافلاً! \n دخلك الإجمالي كان '),
              TextSpan(
                  text: '${appData.totalIncome.toStringAsFixed(0)} ريال',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
              const TextSpan(text: '\n ومجموع مصروفاتك وصل إلى '),
              TextSpan(
                  text: '${appData.totalExpense.toStringAsFixed(0)} ريال',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      StoryPage(
        key: const ValueKey('page2'),
        title: 'أكبر فئة إنفاق',
        icon: Icons.pie_chart,
        content: Text(
            'معظم أموالك ذهبت إلى فئة "الطعام"، استمر في متابعة نفقاتك!',
            style: const TextStyle(color: Colors.white, fontSize: 24)),
      ),
      StoryPage(
        key: const ValueKey('page3'),
        title: 'نحو تحقيق الأحلام',
        icon: Icons.rocket_launch,
        content: Text('عمل رائع! لقد اقتربت أكثر من تحقيق هدفك "سيارة أحلامي".',
            style: const TextStyle(color: Colors.white, fontSize: 24)),
      ),
    ];
  }
}
