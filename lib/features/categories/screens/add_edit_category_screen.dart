import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? categoryToEdit;
  const AddEditCategoryScreen({super.key, this.categoryToEdit});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditing;
  late String _name;
  late TransactionType _type;
  // 1. متغيرات حالة جديدة للأيقونة واللون
  late IconData _selectedIcon;
  late Color _selectedColor;

  // 2. قوائم الأيقونات والألوان المتاحة للاختيار
  final List<IconData> _icons = [
    Icons.fastfood,
    Icons.shopping_bag,
    Icons.directions_bus,
    Icons.receipt_long,
    Icons.movie,
    Icons.school,
    Icons.home,
    Icons.health_and_safety,
    Icons.wallet,
    Icons.card_giftcard,
    Icons.work,
    Icons.savings,
  ];
  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.categoryToEdit != null;
    _name = _isEditing ? widget.categoryToEdit!.name : '';
    _type = _isEditing ? widget.categoryToEdit!.type : TransactionType.expense;
    _selectedIcon = _isEditing ? widget.categoryToEdit!.icon : _icons.first;
    _selectedColor = _isEditing ? widget.categoryToEdit!.color : _colors.first;
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final appData = Provider.of<AppData>(context, listen: false);

      final category = Category(
        id: _isEditing ? widget.categoryToEdit!.id : const Uuid().v4(),
        name: _name,
        type: _type,
        icon: _selectedIcon,
        color: _selectedColor,
      );

      if (_isEditing) {
        appData.updateCategory(category);
      } else {
        appData.addCategory(category);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الفئة' : 'إضافة فئة جديدة'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          // استخدام ListView لتجنب أي مشاكل overflow
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'اسم الفئة'),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'الرجاء إدخال الاسم'
                  : null,
              onSaved: (value) => _name = value!,
            ),
            const SizedBox(height: 20),
            if (!_isEditing)
              DropdownButtonFormField<TransactionType>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                      value: TransactionType.expense, child: Text('مصروف')),
                  DropdownMenuItem(
                      value: TransactionType.income, child: Text('دخل')),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'نوع الفئة'),
              ),
            const SizedBox(height: 24),
            Text('اختر أيقونة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildIconSelector(),
            const SizedBox(height: 24),
            Text('اختر لوناً', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildColorSelector(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCategory,
                child: const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _icons.map((icon) {
        final isSelected = _selectedIcon == icon;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _selectedColor
                    : Theme.of(context).dividerColor,
                width: 2,
              ),
            ),
            child: Icon(icon,
                color: isSelected
                    ? _selectedColor
                    : Theme.of(context).iconTheme.color),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).textTheme.bodyMedium!.color!
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
