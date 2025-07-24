import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/features/transactions/widgets/transaction_form_fields.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  // 1. متغير جديد لاستقبال المعاملة المراد تعديلها
  final Transaction? transactionToEdit;
  // 1. متغير جديد لاستقبال النوع المبدئي
  final TransactionType? initialType;

  const AddTransactionScreen(
      {super.key, this.transactionToEdit, this.initialType});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  double? _amount;
  Category? _selectedCategory;
  late bool _isEditing;
  late TransactionType _selectedType;
  DateTime? _selectedDate;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transactionToEdit != null;
    if (_isEditing) {
      final t = widget.transactionToEdit!;
      _amount = t.amount;
      _selectedType = t.type;
      _selectedCategory = t.category;
      _selectedDate = t.date;
      _notes = t.notes;
    } else {
      _amount = null;
      _selectedType = widget.initialType ?? TransactionType.expense;
      _selectedCategory = null;
      _selectedDate = DateTime.now();
      _notes = '';
    }
  }

  void _saveTransaction() {
    final amount = _amount ?? 0.0;
    if (amount == 0.0 || _selectedCategory == null || _selectedDate == null)
      return;

    final transaction = Transaction(
      id: _isEditing ? widget.transactionToEdit!.id : const Uuid().v4(),
      category: _selectedCategory!,
      amount: amount,
      type: _selectedType,
      date: _selectedDate!,
      notes: _notes,
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
    final isEditing = _isEditing;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            isEditing ? 'تعديل معاملة' : 'إضافة معاملة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              shadows: [
                const Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          centerTitle: false,
          leading: const BackButton(),
        ),
        body: GlassBackground(
          child: Center(
            child: SingleChildScrollView(
              // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TransactionFormFields(
                      selectedType: _selectedType,
                      selectedCategory: _selectedCategory,
                      amount: _amount,
                      selectedDate: _selectedDate,
                      notes: _notes,
                      onTypeChanged: (type) =>
                          setState(() => _selectedType = type),
                      onCategoryChanged: (cat) =>
                          setState(() => _selectedCategory = cat),
                      onAmountChanged: (amt) => setState(() => _amount = amt),
                      onDateChanged: (date) =>
                          setState(() => _selectedDate = date),
                      onNotesChanged: (n) => setState(() => _notes = n),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedType == TransactionType.expense
                                  ? AppColors.expenseColor
                                  : AppColors.incomeColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isEditing ? 'حفظ التعديلات' : 'حفظ',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
