import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nabd/features/reports/reports_provider.dart';
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
    final reportsProvider =
        Provider.of<ReportsProvider>(context, listen: false);
    final storyPages = _buildStoryPages(reportsProvider);
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

    // Remove animation controller to fix "A disposed RenderObject was mutated" error
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<ReportsProvider>(context);
    final storyPages = _buildStoryPages(reportsProvider);

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

  List<Widget> _buildStoryPages(ReportsProvider reportsProvider) {
    // Example: Use reportsProvider to get summary data for the story pages
    // You can further customize this logic as needed
    final monthlyReport = reportsProvider.reports.isNotEmpty
        ? reportsProvider.reports.first
        : null;
    return [
      StoryPage(
        key: const ValueKey('page1'),
        title: 'ملخص شهر يوليو',
        icon: Icons.calendar_today,
        content: Text(
          monthlyReport?.content ?? 'لا توجد بيانات متاحة',
          style:
              const TextStyle(color: Colors.white, fontSize: 24, height: 1.5),
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
