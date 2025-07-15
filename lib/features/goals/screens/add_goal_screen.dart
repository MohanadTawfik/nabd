import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:provider/provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  IconData _selectedIcon = Icons.star;
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  Color _selectedColor = Colors.blue.shade300;

  final List<Map<String, dynamic>> _icons = [
    {'icon': Icons.directions_car, 'color': Colors.blue.shade300},
    {'icon': Icons.airplanemode_active, 'color': Colors.teal.shade300},
    {'icon': Icons.laptop_mac, 'color': Colors.purple.shade300},
    {'icon': Icons.home, 'color': Colors.green.shade300},
    {'icon': Icons.school, 'color': Colors.orange.shade300},
    {'icon': Icons.camera_alt, 'color': Colors.red.shade300},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = _icons[0]['icon'] as IconData;
    _selectedColor = _icons[0]['color'] as Color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // 1. دالة الحفظ الآن تستخدم Provider
  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final newGoal = Goal(
        name: _nameController.text,
        icon: _selectedIcon,
        totalAmount: double.tryParse(_amountController.text) ?? 0.0,
        color: _selectedColor,
      );

      // 2. إضافة الهدف مباشرة إلى AppData
      Provider.of<AppData>(context, listen: false).addGoal(newGoal);

      // 3. العودة للشاشة السابقة (لم نعد بحاجة لإرجاع بيانات)
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة هدف جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('اختر رمزاً لهدفك',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              _buildIconSelector(),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _inputDecoration('ما هو حلمك؟ (مثلاً: سيارة جديدة)'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'الرجاء إدخال اسم الهدف'
                    : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('كم المبلغ الإجمالي للهدف؟'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'الرجاء إدخال المبلغ'
                    : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8952ff),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('إطلاق الحلم!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xff161b22),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff8952ff))),
    );
  }

  Widget _buildIconSelector() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 16, crossAxisSpacing: 16),
      itemCount: _icons.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final iconData = _icons[index];
        final icon = iconData['icon'] as IconData;
        final color = iconData['color'] as Color;
        final isSelected = _selectedIcon == icon;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIcon = icon;
              _selectedColor = color;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: const Color(0xff161b22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? color : Colors.transparent, width: 2),
            ),
            child: Icon(icon,
                color: isSelected ? color : Colors.white70, size: 32),
          ),
        );
      },
    );
  }
}
