import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/features/dashboard/screens/dashboard_screen.dart';
import 'package:nabd/features/goals/screens/goals_screen.dart';
import 'package:nabd/features/insights_hub/screens/insights_hub_screen.dart';
import 'package:nabd/features/settings/screens/settings_screen.dart';
import 'package:nabd/widgets/magic_fab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _backgroundAnimationController;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    InsightsHubScreen(), 
    GoalsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(reverse: true);
    _colorAnimation1 = ColorTween(
            begin: AppColors.backgroundDark,
            end: AppColors.accentColor.withOpacity(0.1))
        .animate(_backgroundAnimationController);
    _colorAnimation2 = ColorTween(
            begin: AppColors.primaryLight.withOpacity(0.15),
            end: AppColors.backgroundDark)
        .animate(_backgroundAnimationController);
  }

@override
  dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. قمنا بتبسيط كل شيء هنا. الزر الآن معزول بالكامل
      extendBody: true, // مهم لجعل الجسم يمتد خلف الشريط السفلي
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_colorAnimation1.value!, _colorAnimation2.value!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          _widgetOptions.elementAt(_selectedIndex),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const MagicFab(), // استخدام البوابة السحرية
      bottomNavigationBar: _buildCustomBottomBar(),
    );
  }

  Widget _buildCustomBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      color: Theme.of(context).bottomAppBarTheme.color,
      elevation: 0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 0),
            _buildNavItem(Icons.bar_chart, 1),
            const SizedBox(width: 40),
            _buildNavItem(Icons.wallet_giftcard, 2),
            _buildNavItem(Icons.settings, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: _selectedIndex == index
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).iconTheme.color,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}
