import 'package:flutter/material.dart';

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

  // قائمة الأيقونات المتاحة للاختيار
  final List<IconData> _icons = [
    Icons.directions_car,
    Icons.airplanemode_active,
    Icons.laptop_mac,
    Icons.home,
    Icons.school,
    Icons.camera_alt,
    Icons.phone_android,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
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
              // 1. اختيار الأيقونة
              const Text('اختر رمزاً لهدفك',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              _buildIconSelector(),
              const SizedBox(height: 32),

              // 2. اسم الهدف
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

              // 3. المبلغ الإجمالي
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

              // 4. زر الحفظ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // منطق الحفظ (حالياً فقط نعود للشاشة السابقة)
                      print(
                          'Goal Saved: Name: ${_nameController.text}, Amount: ${_amountController.text}, Icon: $_selectedIcon');
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8952ff),
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

  // ويدجت مساعد لبناء حقل الإدخال
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

  // ويدجت مساعد لبناء شبكة اختيار الأيقونات
  Widget _buildIconSelector() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 16, crossAxisSpacing: 16),
      itemCount: _icons.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final icon = _icons[index];
        final isSelected = _selectedIcon == icon;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIcon = icon;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: const Color(0xff161b22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? const Color(0xff8952ff) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(icon,
                color: isSelected ? const Color(0xff8952ff) : Colors.white70,
                size: 32),
          ),
        );
      },
    );
  }
}
