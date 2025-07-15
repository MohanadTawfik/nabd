import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';

class AddTransactionPanel extends StatefulWidget {
  const AddTransactionPanel({super.key});
  @override
  State<AddTransactionPanel> createState() => _AddTransactionPanelState();
}

class _AddTransactionPanelState extends State<AddTransactionPanel> {
  String _amount = '0';
  String? _selectedCategory;
  final List<Map<String, dynamic>> _categories = [
    {'name': 'طعام', 'icon': Icons.fastfood},
    {'name': 'مواصلات', 'icon': Icons.directions_bus},
    {'name': 'مقاضي', 'icon': Icons.shopping_bag},
    {'name': 'فواتير', 'icon': Icons.receipt_long},
  ];

  void _saveTransaction() {
    final amount = double.tryParse(_amount) ?? 0.0;
    if (amount == 0.0 || _selectedCategory == null) return;

    final selectedCategoryData =
        _categories.firstWhere((c) => c['name'] == _selectedCategory);

    // 1. إنشاء المعاملة الجديدة
    final newTransaction = Transaction(
      category: _selectedCategory!,
      icon: selectedCategoryData['icon'],
      amount: amount,
      type: TransactionType.expense, // كمثال، كل المعاملات مصروفات
      date: DateTime.now(),
    );

    // 2. استخدام Provider للوصول لمركز البيانات وإضافة المعاملة
    // listen: false لأننا لا نريد إعادة بناء هذا الويدجت عند التغيير
    Provider.of<AppData>(context, listen: false).addTransaction(newTransaction);

    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 24),
          _buildAmountDisplay(),
          const SizedBox(height: 24),
          _buildCategoryBubbles(),
          const SizedBox(height: 24),
          _buildNumpad(),
          const SizedBox(height: 16),
          _buildSaveButton(),
        ],
      ),
    );
  }

  void _onNumpadTapped(String value) {
    setState(() {
      if (value == '⌫') {
        _amount =
            _amount.length > 1 ? _amount.substring(0, _amount.length - 1) : '0';
      } else if (_amount == '0' && value != '.') {
        _amount = value;
      } else {
        if (value == '.' && _amount.contains('.')) return;
        _amount += value;
      }
    });
  }

  Widget _buildAmountDisplay() {
    return Column(children: [
      Text(_amount,
          style: const TextStyle(
              color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold)),
      const Text('ريال يمني',
          style: TextStyle(color: Colors.white54, fontSize: 18))
    ]);
  }

  Widget _buildCategoryBubbles() {
    return Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        alignment: WrapAlignment.center,
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category['name'];
          return ChoiceChip(
              label: Text(category['name']),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category['name'] : null;
                });
              },
              backgroundColor: const Color(0xff0d1117),
              selectedColor: const Color(0xff8952ff),
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: isSelected
                          ? const Color(0xff8952ff)
                          : Colors.white24)));
        }).toList());
  }

  Widget _buildNumpad() {
    final buttons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '.',
      '0',
      '⌫'
    ];
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1.5),
        itemCount: buttons.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => TextButton(
            onPressed: () => _onNumpadTapped(buttons[index]),
            style: TextButton.styleFrom(
                foregroundColor: Colors.white, shape: const CircleBorder()),
            child: Text(buttons[index],
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold))));
  }
  
  Widget _buildSaveButton() {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed: _saveTransaction,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff8952ff),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('حفظ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))));
  }
}
