import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:nabd/data/app_data.dart';
import 'package:intl/intl.dart';

// Card-based Add Transaction Screen
class AddTransactionCardScreen extends StatefulWidget {
  final Transaction? transactionToEdit;
  const AddTransactionCardScreen({Key? key, this.transactionToEdit}) : super(key: key);

  @override
  State<AddTransactionCardScreen> createState() => _AddTransactionCardScreenState();
}

class _AddTransactionCardScreenState extends State<AddTransactionCardScreen> {
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

  Widget _buildCard({required Widget child, required String label, IconData? icon, Color? color}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color ?? Theme.of(context).colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final categories = _selectedType == TransactionType.expense
        ? appData.expenseCategories
        : appData.incomeCategories;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل معاملة' : 'إضافة معاملة'),
        centerTitle: false,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
              label: 'المبلغ',
              icon: Icons.attach_money,
              color: Theme.of(context).colorScheme.primary,
              child: TextFormField(
                initialValue: _amount != null ? _amount.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: '﷼ ',
                  hintText: '0',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _amount = double.tryParse(val.replaceAll(',', '')) ?? 0.0),
              ),
            ),
            _buildCard(
              label: 'النوع',
              icon: Icons.swap_horiz,
              child: Row(
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
            ),
            _buildCard(
              label: 'الفئة',
              icon: Icons.category,
              child: Wrap(
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
            ),
            _buildCard(
              label: 'التاريخ',
              icon: Icons.date_range,
              child: InkWell(
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
            ),
            _buildCard(
              label: 'ملاحظات',
              icon: Icons.notes,
              child: TextFormField(
                initialValue: _notes ?? '',
                maxLines: 2,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'أضف ملاحظات إضافية (اختياري)',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _notes = val),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
