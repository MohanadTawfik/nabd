import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:nabd/data/app_data.dart';
import 'package:intl/intl.dart';

// Stepper-based Add Transaction Screen
class AddTransactionStepperScreen extends StatefulWidget {
  final Transaction? transactionToEdit;
  const AddTransactionStepperScreen({Key? key, this.transactionToEdit}) : super(key: key);

  @override
  State<AddTransactionStepperScreen> createState() => _AddTransactionStepperScreenState();
}

class _AddTransactionStepperScreenState extends State<AddTransactionStepperScreen> {
  int _currentStep = 0;
  double? _amount;
  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;
  DateTime? _selectedDate;
  String? _notes;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _isEditing = true;
      _amount = t.amount;
      _selectedType = t.type;
      _selectedCategory = t.category;
      _selectedDate = t.date;
      _notes = t.notes;
    }
  }

  void _saveTransaction() {
    final amount = _amount ?? 0.0;
    if (amount == 0.0 || _selectedCategory == null || _selectedDate == null) return;
    final transaction = Transaction(
      id: _isEditing ? widget.transactionToEdit!.id : UniqueKey().toString(),
      category: _selectedCategory!,
      amount: amount,
      type: _selectedType,
      date: _selectedDate!,
      notes: _notes ?? '',
    );
    final appData = Provider.of<AppData>(context, listen: false);
    if (_isEditing) {
      appData.updateTransaction(transaction);
    } else {
      appData.addTransaction(transaction);
    }
    Navigator.pop(context);
  }

  List<Step> _buildSteps(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final categories = _selectedType == TransactionType.expense
        ? appData.expenseCategories
        : appData.incomeCategories;
    return [
      Step(
        title: const Text('المبلغ'),
        content: TextFormField(
          initialValue: _amount != null ? _amount.toString() : '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            prefixText: '﷼ ',
            hintText: '0',
          ),
          onChanged: (val) => setState(() => _amount = double.tryParse(val.replaceAll(',', '')) ?? 0.0),
        ),
        isActive: _currentStep == 0,
      ),
      Step(
        title: const Text('النوع'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('مصروف'),
              selected: _selectedType == TransactionType.expense,
              onSelected: (selected) => setState(() => _selectedType = TransactionType.expense),
            ),
            const SizedBox(width: 16),
            ChoiceChip(
              label: const Text('دخل'),
              selected: _selectedType == TransactionType.income,
              onSelected: (selected) => setState(() => _selectedType = TransactionType.income),
            ),
          ],
        ),
        isActive: _currentStep == 1,
      ),
      Step(
        title: const Text('الفئة'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((cat) {
            final isSelected = _selectedCategory?.id == cat.id;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, color: isSelected ? Colors.white : cat.color, size: 20),
                  const SizedBox(width: 6),
                  Text(cat.name),
                ],
              ),
              selected: isSelected,
              selectedColor: cat.color,
              onSelected: (_) => setState(() => _selectedCategory = cat),
              backgroundColor: Theme.of(context).colorScheme.surface,
              labelStyle: TextStyle(color: isSelected ? Colors.white : cat.color),
            );
          }).toList(),
        ),
        isActive: _currentStep == 2,
      ),
      Step(
        title: const Text('التاريخ'),
        content: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? now,
              firstDate: DateTime(now.year - 2),
              lastDate: DateTime(now.year + 2),
              locale: const Locale('ar'),
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 22),
                const SizedBox(width: 10),
                Text(
                  _selectedDate != null
                      ? DateFormat.yMMMMd('ar').format(_selectedDate!)
                      : 'اختر التاريخ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep == 3,
      ),
      Step(
        title: const Text('ملاحظات'),
        content: TextFormField(
          initialValue: _notes ?? '',
          maxLines: 2,
          minLines: 1,
          decoration: const InputDecoration(
            hintText: 'أضف ملاحظات إضافية (اختياري)',
          ),
          onChanged: (val) => setState(() => _notes = val),
        ),
        isActive: _currentStep == 4,
      ),
      Step(
        title: const Text('تأكيد'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: const Text('المبلغ'),
              trailing: Text('${_amount ?? 0.0} ﷼'),
            ),
            ListTile(
              title: const Text('النوع'),
              trailing: Text(_selectedType == TransactionType.expense ? 'مصروف' : 'دخل'),
            ),
            ListTile(
              title: const Text('الفئة'),
              trailing: Text(_selectedCategory?.name ?? '-'),
            ),
            ListTile(
              title: const Text('التاريخ'),
              trailing: Text(_selectedDate != null ? DateFormat.yMMMMd('ar').format(_selectedDate!) : '-'),
            ),
            ListTile(
              title: const Text('ملاحظات'),
              trailing: Text(_notes ?? '-'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedType == TransactionType.expense
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isEditing ? 'حفظ التعديلات' : 'حفظ',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        isActive: _currentStep == 5,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل معاملة' : 'إضافة معاملة'),
        centerTitle: false,
        leading: const BackButton(),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 5) {
            setState(() => _currentStep += 1);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: _buildSteps(context),
        controlsBuilder: (context, details) {
          if (_currentStep == 5) return const SizedBox.shrink();
          return Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: const Text('التالي'),
              ),
              const SizedBox(width: 8),
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  child: const Text('السابق'),
                ),
            ],
          );
        },
      ),
    );
  }
}
