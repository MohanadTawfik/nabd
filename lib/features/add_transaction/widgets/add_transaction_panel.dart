import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/add_transaction/widgets/round_up_suggestion_card.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; 



class AddTransactionPanel extends StatefulWidget {
  // 1. متغير جديد لاستقبال المعاملة المراد تعديلها
  final Transaction? transactionToEdit;
  // 1. متغير جديد لاستقبال النوع المبدئي
  final TransactionType? initialType;

  const AddTransactionPanel(
      {super.key, this.transactionToEdit, this.initialType});
  
  @override
  State<AddTransactionPanel> createState() => _AddTransactionPanelState();
}

class _AddTransactionPanelState extends State<AddTransactionPanel> {
  String _amount = '0';
  Category? _selectedCategory; // 1. الآن نحفظ الفئة الكاملة
  // TransactionType _selectedType = TransactionType.expense;
  // 2. متغير لتحديد إذا كنا في وضع التعديل
  late bool _isEditing;
  // 2. متغير حالة جديد للتحكم في إظهار بطاقة التقريب
  bool _showRoundUpSuggestion = false;
  late Transaction _savedTransaction;
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transactionToEdit != null;
    if (_isEditing) {
      final t = widget.transactionToEdit!;
      _amount = t.amount.toStringAsFixed(0);
      _selectedType = t.type;
      // 1. الآن يمكننا تحديد الفئة بشكل صحيح
      _selectedCategory = t.category;
    } else {
      _amount = '0';
      // 2. تحديد النوع المبدئي من البوابة السحرية
      _selectedType = widget.initialType ?? TransactionType.expense;
    }
  }


  void _saveTransaction() {
    final amount = double.tryParse(_amount) ?? 0.0;
    if (amount == 0.0 || _selectedCategory == null) return;

    final transaction = Transaction(
      id: _isEditing ? widget.transactionToEdit!.id : const Uuid().v4(),
      category: _selectedCategory!, // 2. نمرر كائن الفئة بالكامل
      amount: amount,
      type: _selectedType,
      date: _isEditing ? widget.transactionToEdit!.date : DateTime.now(),
    );

    final appData = Provider.of<AppData>(context, listen: false);
    if (_isEditing) {
      appData.updateTransaction(transaction);
    } else {
      appData.addTransaction(transaction);
    }
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    final typeColor = _selectedType == TransactionType.expense
        ? Colors.red.shade400
        : Colors.green.shade400;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      // 4. استخدام AnimatedSwitcher للانتقال السلس بين الواجهتين
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: _showRoundUpSuggestion
            ? RoundUpSuggestionCard(
                transaction: _savedTransaction,
                onDismiss: () => Navigator.pop(context),
              )
            : _buildTransactionForm(typeColor),
      ),
    );
  }

  // 5. قمنا بتغليف واجهة الإدخال في ويدجت خاص بها
  Widget _buildTransactionForm(Color typeColor) {
    return Column(
      key: const ValueKey('form'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(12))),
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
          child: ElevatedButton(
            onPressed: _saveTransaction,
            style: ElevatedButton.styleFrom(
                backgroundColor: typeColor, foregroundColor: Colors.white),
            child: const Text('حفظ'),
          ),
        ),
      ],
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
            // _selectedCategoryName = null;
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

  // 2. تحديث الويدجت ليقرأ الفئات من AppData
  Widget _buildCategoryBubbles(BuildContext context, Color typeColor) {
    final appData = Provider.of<AppData>(context);
    final categories = _selectedType == TransactionType.expense
        ? appData.expenseCategories
        : appData.incomeCategories;

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: categories.map((category) {
        final isSelected = _selectedCategory?.id == category.id;
        return ChoiceChip(
          label: Text(category.name),
          avatar: Icon(category.icon,
              color: isSelected ? Colors.white : category.color),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? category : null;
            });
          },
          selectedColor: category.color,
          labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.bold),
          shape: isSelected
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Theme.of(context).dividerColor)),
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
