import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nabd/features/add_transaction/widgets/add_transaction_panel.dart';
import 'package:nabd/features/scanner/screens/smart_scanner_screen.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';

class MagicFab extends StatefulWidget {
  const MagicFab({super.key});

  @override
  State<MagicFab> createState() => _MagicFabState();
}

class _MagicFabState extends State<MagicFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  OverlayEntry? _overlayEntry;
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  Future<void> _toggleMenu() async {
    if (_controller.isDismissed) {
      _showOverlay();
      await _controller.forward();
    } else {
      await _controller.reverse();
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // الطبقة الأولى: الخلفية المعتمة
            GestureDetector(
              onTap: _toggleMenu,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            // الطبقة الثانية: الأزرار المتحركة
            ..._buildExpandingActionButtons(),

            // 3. الطبقة الثالثة (الأخيرة): الزر الرئيسي نفسه، ليكون دائماً في المقدمة
            _buildMainFab(),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  List<Widget> _buildExpandingActionButtons() {
    final buttons = <Widget>[];
    if (_fabKey.currentContext == null) return [];

    final fabRenderBox =
        _fabKey.currentContext!.findRenderObject() as RenderBox;
    final fabCenter =
        fabRenderBox.localToGlobal(fabRenderBox.size.center(Offset.zero));

    const count = 3;
    const distance = 100.0;
    // 1. زوايا جديدة ومضبوطة لتوزيع مثالي على شكل قوس
    final degrees = [195.0, 270.0, 345.0];
    final actions = [
      {
        'label': 'مصروف',
        'icon': Icons.arrow_downward,
        'color': Colors.red.shade400,
        'type': TransactionType.expense
      },
      {
        'label': 'مسح فاتورة',
        'icon': Icons.camera_alt,
        'color': Colors.blue.shade400,
        'type': null
      },
      {
        'label': 'دخل',
        'icon': Icons.arrow_upward,
        'color': Colors.green.shade400,
        'type': TransactionType.income
      },
    ];

    for (int i = 0; i < count; i++) {
      final action = actions[i];
      final angle = degrees[i] * (pi / 180);
      buttons.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final animation = CurvedAnimation(
                parent: _controller, curve: Curves.easeInOutBack);
            // 2. هذا هو الإصلاح النهائي لمشكلة المحاذاة.
            // الحساب الآن دقيق 100% ويضع كل زر في مكانه الصحيح رياضياً.
            const widgetSize = 80.0; // حجم الويدجت الكامل (الزر + التسمية)
            final x = fabCenter.dx -
                (widgetSize / 2) +
                (distance * cos(angle) * animation.value);
            final y = fabCenter.dy -
                (widgetSize / 2) +
                (distance * sin(angle) * animation.value);

            return Positioned(
              left: x,
              top: y,
              child: Transform.scale(
                scale: animation.value,
                child: Transform.rotate(
                  angle: (1.0 - animation.value) * pi / 2,
                  child: child,
                ),
              ),
            );
          },
          child: _actionButton(
            action['label'] as String,
            action['icon'] as IconData,
            action['color'] as Color,
            () {
              if (action['type'] != null) {
                _showAddPanel(action['type'] as TransactionType);
              } else {
                _showScanner();
              }
            },
          ),
        ),
      );
    }
    return buttons;
  }



  // 4. ويدجت جديد لبناء الزر الرئيسي داخل الـ Overlay
  Widget _buildMainFab() {
    if (_fabKey.currentContext == null) return const SizedBox.shrink();
    final fabRenderBox =
        _fabKey.currentContext!.findRenderObject() as RenderBox;
    final fabCenter =
        fabRenderBox.localToGlobal(fabRenderBox.size.center(Offset.zero));

    return Positioned(
      top: fabCenter.dy - (56 / 2), // 56 هو حجم الزر الافتراضي
      left: fabCenter.dx - (56 / 2),
      child: FloatingActionButton(
        onPressed: _toggleMenu,
        backgroundColor: Theme.of(context).primaryColor,
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _controller,
          color: Colors.white,
          size: 30,

        ),
      ),
    );
  }
  
  Widget _actionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    // 3. تغليف الويدجت بـ SizedBox لضمان حجم ثابت ومحاذاة صحيحة
    return SizedBox(
      width: 80,
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: color,  
            mini: true,
            heroTag: label,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            type: MaterialType.transparency,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPanel(TransactionType type) async {
    await _toggleMenu();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionPanel(initialType: type),
    );
  }

  Future<void> _showScanner() async {
    await _toggleMenu();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SmartScannerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 5. الزر الرئيسي الآن هو مجرد "مرساة" غير مرئية لتحديد الموقع
    // وهو أيضاً الزر الذي يظهر عندما تكون القائمة مغلقة
    return FloatingActionButton(
      key: _fabKey,
      onPressed: _toggleMenu,
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }

  
}
