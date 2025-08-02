import 'package:flutter/material.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
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
      title: 'إضافة معاملة جديدة',
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
            title: const Text('إضافة معاملة يدوياً'),
            subtitle: const Text('إدخال تفاصيل المعاملة بشكل يدوي'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/add_transaction');
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.document_scanner,
                  color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('مسح فاتورة'),
            subtitle: const Text('استخدام الكاميرا لمسح وتحليل الفاتورة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/scanner');
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
