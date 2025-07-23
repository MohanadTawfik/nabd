import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
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

  void _onNumpadTap(String value) {
    setState(() {
      if (value == 'backspace') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
        if (_amount.isEmpty) {
          _amount = '0';
        }
      } else if (value == '.') {
        if (!_amount.contains('.')) {
          _amount += value;
        }
      } else {
        if (_amount == '0' && value != '.') {
          _amount = value;
        } else {
          _amount += value;
        }
      }
    });
  }

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
        ? AppColors.expenseColor
        : AppColors.incomeColor;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
            )),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
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
          child: ElevatedButton(
            onPressed: _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: typeColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'حفظ',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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
        ? AppColors.expenseColor
        : AppColors.incomeColor;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
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

  Widget _buildAmountDisplay(BuildContext context, Color typeColor) {
    return Column(
      children: [
        Text(
          _amount,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: typeColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'ريال يمني',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildNumpad(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.8,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final String text = _getNumpadText(index);
        return _buildNumpadButton(context, text);
      },
    );
  }

  String _getNumpadText(int index) {
    if (index < 9) {
      return (index + 1).toString();
    } else if (index == 9) {
      return '.';
    } else if (index == 10) {
      return '0';
    } else {
      return 'backspace';
    }
  }

  Widget _buildNumpadButton(BuildContext context, String text) {
    return InkWell(
      onTap: () => _onNumpadTap(text),
      borderRadius: BorderRadius.circular(12),
      hoverColor: Theme.of(context).cardColor.withOpacity(0.5),
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: text == 'backspace'
              ? Icon(Icons.backspace_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: Theme.of(context).textTheme.headlineMedium?.fontSize)
              : Text(
                  text,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
        ),
      ),
    );
  }
}
