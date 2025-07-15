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

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // 1. نجعل المتحكمات قابلة للـ null لتجنب أي أخطاء تهيئة
  AnimationController? _animationController;
  Animation<Color?>? _colorAnimation1;
  Animation<Color?>? _colorAnimation2;
  Animation<Color?>? _colorAnimation3;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    ReportsScreen(),
    GoalsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 2. نقوم بتهيئة المتحكمات كالمعتاد
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));

    _colorAnimation1 = ColorTween(
      begin: const Color(0xff0d1117),
      end: const Color(0xff161b22).withOpacity(0.5),
    ).animate(_animationController!);

    _colorAnimation2 = ColorTween(
      begin: const Color(0xff1fddff).withOpacity(0.1),
      end: const Color(0xff8952ff).withOpacity(0.1),
    ).animate(_animationController!);

    _colorAnimation3 = ColorTween(
      begin: const Color(0xff8952ff).withOpacity(0.15),
      end: const Color(0xff0d1117),
    ).animate(_animationController!);

    _animationController!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController?.dispose(); // استخدام ?. للأمان
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 3. نضيف فحصاً للتأكد من أن المتحكمات قد تم تهيئتها قبل استخدامها
    // هذا يمنع الخطأ بشكل نهائي
    if (_animationController == null) {
      // عرض شاشة فارغة آمنة أثناء تحميل الأنيميشن في أول جزء من الثانية
      return const Scaffold(backgroundColor: Color(0xff0d1117));
    }

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationController!, // الآن نستخدم ! بأمان
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _colorAnimation1!.value!,
                    _colorAnimation2!.value!,
                    _colorAnimation3!.value!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
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
            // 1. استخدام لون الثيم الأساسي
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add, color: Colors.white54, size: 30),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            // 2. استخدام لون الثيم للشريط السفلي
            color: Theme.of(context).bottomAppBarTheme.color,
            elevation: Theme.of(context).bottomAppBarTheme.elevation,
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
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        // 3. استخدام لون الثيم للأيقونات
        color: _selectedIndex == index
            ? Theme.of(context).primaryColor
            : Theme.of(context).iconTheme.color,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}
