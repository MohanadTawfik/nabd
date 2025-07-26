import 'package:flutter/material.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/features/dashboard/screens/dashboard_screen.dart';
import 'package:nabd/features/goals/screens/goals_screen.dart';
import 'package:nabd/features/insights_hub/screens/insights_hub_screen.dart';
import 'package:nabd/features/settings/screens/settings_screen.dart';
import 'package:nabd/widgets/animated_bottom_nav_bar.dart';
import 'package:nabd/widgets/glass_background.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    InsightsHubScreen(),
    GoalsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        // 2. قمنا بتبسيط كل شيء هنا. الزر الآن معزول بالكامل
        extendBody: true, // مهم لجعل الجسم يمتد خلف الشريط السفلي
        body: GlassBackground(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          onAddPressed: () {
            // Handle FAB tap
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddTransactionScreen(),
            );
          },
        ));
  }
}
