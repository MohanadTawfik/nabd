import 'package:flutter/material.dart';
import '../add_transaction/widgets/add_transaction_panel.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../reports/screens/reports_screen.dart';
import '../goals/screens/goals_screen.dart';
import '../settings/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // لتتبع أيقونة الشريط السفلي المختارة

  // قائمة الشاشات التي سنتنقل بينها
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(), // الشاشة الأولى (الرئيسية)
    ReportsScreen(), // الشاشة الثانية (التقارير)
    GoalsScreen(), // شاشة الأهداف
    SettingsScreen(), // شاشة الإعدادات
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // الجسم الآن يعرض الشاشة المختارة من القائمة
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xff161b22),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddTransactionPanel(),
          );
        },
        backgroundColor: const Color(0xff8952ff),
        child: const Icon(Icons.add, color: Colors.white70, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xff161b22),
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
      ),
    );
  }

  // ويدجت مساعد لبناء أيقونة التنقل
  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color:
            _selectedIndex == index ? const Color(0xff8952ff) : Colors.white54,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}
