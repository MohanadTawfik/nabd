import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; 
class AddTransactionPanel extends StatefulWidget {
  const AddTransactionPanel({super.key});
  @override
  State<AddTransactionPanel> createState() => _AddTransactionPanelState();
}

class _AddTransactionPanelState extends State<AddTransactionPanel> {
  String _amount = '0';
  String? _selectedCategoryName;
  TransactionType _selectedType = TransactionType.expense;

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
      id: const Uuid().v4(),
      category: _selectedCategoryName!,
      icon: selectedCategoryData['icon'],
      amount: amount,
      type: _selectedType,
      date: DateTime.now(),
    );

    Provider.of<AppData>(context, listen: false).addTransaction(newTransaction);
    Navigator.pop(context);
  }

  // 1. دالة ذكية لتحديد اللون الرئيسي بناءً على النوع
  Color _getTypeColor(BuildContext context) {
    return _selectedType == TransactionType.expense
        ? Colors.red.shade400
        : Colors.green.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          _buildTypeSelector(context),
          const SizedBox(height: 24),
          _buildAmountDisplay(context, typeColor),
          const SizedBox(height: 24),
          _buildCategoryBubbles(context, typeColor),
          const SizedBox(height: 24),
          _buildNumpad(context),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            // 2. زر الحفظ الآن يأخذ لونه من النوع المختار
            child: ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('حفظ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTypeButton(context, 'مصروف', TransactionType.expense),
          _buildTypeButton(context, 'دخل', TransactionType.income),
        ],
      ),
    );
  }

  Widget _buildTypeButton(
      BuildContext context, String text, TransactionType type) {
    final bool isSelected = _selectedType == type;
    // 3. الألوان الآن ذكية
    final Color selectedColor = type == TransactionType.expense
        ? Colors.red.shade400
        : Colors.green.shade400;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedCategoryName = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBubbles(BuildContext context, Color typeColor) {
    final categories = _selectedType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;
    final chipTheme = Theme.of(context).chipTheme;

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
          backgroundColor: chipTheme.backgroundColor,
          // 4. الفئة المختارة تأخذ لون النوع (أحمر أو أخضر)
          selectedColor: typeColor,
          labelStyle: isSelected
              ? const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)
              : chipTheme.labelStyle,
          // shape: isSelected
          //     ? RoundedRectangleBorder(
          //         // borderRadius: BorderRadius.circular(12),
          //         side: BorderSide(color: typeColor, width: 1.5))
          //     : chipTheme.shape as OutlinedBorder?,
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

  Widget _buildAmountDisplay(BuildContext context, Color typeColor) {
    return Column(children: [
      // 5. الرقم أيضاً يأخذ لون النوع
      Text(_amount,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontSize: 52, color: typeColor)),
      Text('ريال يمني',
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18)),
    ]);
  }

  Widget _buildNumpad(BuildContext context) {
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
          foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
          shape: const CircleBorder(),
        ),
        child: Text(buttons[index],
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
