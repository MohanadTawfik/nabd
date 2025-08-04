import 'package:flutter/material.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/features/transactions/screens/smart_input_screen.dart';
import 'package:nabd/features/dashboard/screens/dashboard_screen.dart';
import 'package:nabd/features/budgets/screens/budgets_screen.dart';
import 'package:nabd/features/insights/screens/insights_hub_screen.dart';
import 'package:nabd/features/settings/screens/settings_screen.dart';
import 'package:nabd/widgets/animated_bottom_nav_bar.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/utils/ui_utils.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    BudgetsScreen(),
    InsightsHubScreen(),
    SettingsScreen(),
  ];

  // Show options for adding transaction or scanning receipt
  void _showAddOptions(BuildContext context) {
    UiUtils.showCustomBottomSheet(
      context: context,
      title: 'كيف تود إضافة معاملتك اليوم؟',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child:
                  Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('إدخال يدوي سريع'),
            subtitle: const Text('سجّل معاملتك بنفسك بخطوات بسيطة وسريعة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddTransactionScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.smart_toy,
                  color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('إدخال ذكي (تجريبي)'),
            subtitle: const Text('دع الذكاء الاصطناعي يملأ التفاصيل عنك!'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SmartInputScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

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
            // Show options for add transaction or scan receipt
            _showAddOptions(context);
          },
        ));
  }
}
