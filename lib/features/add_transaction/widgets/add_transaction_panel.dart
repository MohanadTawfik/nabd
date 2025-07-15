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
  String? _selectedCategoryName;
  // 1. متغير جديد لتتبع نوع المعاملة (مصروف أو دخل)
  TransactionType _selectedType = TransactionType.expense;

  // 2. قوائم منفصلة لفئات المصروف والدخل
  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'طعام', 'icon': Icons.fastfood},
    {'name': 'مواصلات', 'icon': Icons.directions_bus},
    {'name': 'مقاضي', 'icon': Icons.shopping_bag},
    {'name': 'فواتير', 'icon': Icons.receipt_long},
  ];
  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'راتب', 'icon': Icons.wallet},
    {'name': 'هدية', 'icon': Icons.card_giftcard},
    {'name': 'أعمال حرة', 'icon': Icons.work},
  ];

  void _saveTransaction() {
    final amount = double.tryParse(_amount) ?? 0.0;
    if (amount == 0.0 || _selectedCategoryName == null) return;

    final categories = _selectedType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;
    final selectedCategoryData =
        categories.firstWhere((c) => c['name'] == _selectedCategoryName);

    final newTransaction = Transaction(
      category: _selectedCategoryName!,
      icon: selectedCategoryData['icon'],
      amount: amount,
      type: _selectedType, // 3. استخدام النوع المختار
      date: DateTime.now(),
    );

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

          // 4. إضافة أزرار التبديل بين مصروف ودخل
          _buildTypeSelector(),
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

  // ويدجت جديد لبناء أزرار التبديل
  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff0d1117),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ToggleButtons(
        isSelected: [
          _selectedType == TransactionType.expense,
          _selectedType == TransactionType.income
        ],
        onPressed: (index) {
          setState(() {
            _selectedType =
                index == 0 ? TransactionType.expense : TransactionType.income;
            _selectedCategoryName = null; // إعادة تعيين الفئة عند تغيير النوع
          });
        },
        color: Colors.white70,
        selectedColor: Colors.white,
        fillColor: _selectedType == TransactionType.expense
            ? Colors.red.withOpacity(0.5)
            : Colors.green.withOpacity(0.5),
        splashColor: const Color(0xff8952ff).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        borderWidth: 0,
        selectedBorderColor: _selectedType == TransactionType.expense
            ? Colors.red
            : Colors.green,
        children: const [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('مصروف')),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('دخل')),
        ],
      ),
    );
  }

  // تم تحديث هذا الويدجت ليعرض الفئات الصحيحة
  Widget _buildCategoryBubbles() {
    final categories = _selectedType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: categories.map((category) {
        final isSelected = _selectedCategoryName == category['name'];
        return ChoiceChip(
          label: Text(category['name']),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategoryName = selected ? category['name'] : null;
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
                  color:
                      isSelected ? const Color(0xff8952ff) : Colors.white24)),
        );
      }).toList(),
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
