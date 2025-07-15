import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:provider/provider.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  // بيانات افتراضية للفئات التي يمكن وضع ميزانية لها
  final List<Map<String, dynamic>> _availableCategories = [
    {'name': 'ترفيه', 'icon': Icons.movie},
    {'name': 'مواصلات', 'icon': Icons.directions_bus},
    {'name': 'فواتير', 'icon': Icons.receipt_long},
  ];

  Map<String, dynamic>? _selectedCategory;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final newBudget = Budget(
        categoryName: _selectedCategory!['name'],
        icon: _selectedCategory!['icon'],
        totalAmount: double.tryParse(_amountController.text) ?? 0.0,
      );

      Provider.of<AppData>(context, listen: false).addBudget(newBudget);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة ميزانية جديدة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('اختر الفئة',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              // استخدام DropdownButton لاختيار الفئة
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedCategory,
                items: _availableCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category['icon'], color: Colors.white70),
                        const SizedBox(width: 10),
                        Text(category['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: _inputDecoration('الفئة'),
                dropdownColor: const Color(0xff161b22),
                style:
                    const TextStyle(color: Colors.white, fontFamily: 'Tajawal'),
                validator: (value) =>
                    value == null ? 'الرجاء اختيار فئة' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('المبلغ الإجمالي للميزانية'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'الرجاء إدخال المبلغ'
                    : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8952ff),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('حفظ الميزانية',
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
}
