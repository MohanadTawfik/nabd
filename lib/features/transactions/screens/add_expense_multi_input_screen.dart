import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:provider/provider.dart';
import 'package:nabd/data/app_data.dart';
import 'package:intl/intl.dart';

// Multi-Input Add Expense Screen (Manual, OCR, NLP)
class AddExpenseMultiInputScreen extends StatefulWidget {
  const AddExpenseMultiInputScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseMultiInputScreen> createState() =>
      _AddExpenseMultiInputScreenState();
}

enum ExpenseInputMethod { manual, ocr, nlp }

class _AddExpenseMultiInputScreenState
    extends State<AddExpenseMultiInputScreen> {
  ExpenseInputMethod _method = ExpenseInputMethod.manual;

  // Manual fields
  double? _amount;
  Category? _selectedCategory;
  DateTime? _selectedDate;
  String? _notes;

  // NLP field
  String? _nlpText;

  // OCR stub (real OCR integration would require plugins)
  String? _ocrResult;
  bool _isScanning = false;

  void _saveManualExpense() {
    final amount = _amount ?? 0.0;
    if (amount == 0.0 || _selectedCategory == null || _selectedDate == null)
      return;
    final transaction = Transaction(
      id: UniqueKey().toString(),
      category: _selectedCategory!,
      amount: amount,
      type: TransactionType.expense,
      date: _selectedDate!,
      notes: _notes ?? '',
    );
    final appData = Provider.of<AppData>(context, listen: false);
    appData.addTransaction(transaction);
    Navigator.pop(context);
  }

  void _saveNlpExpense() {
    // Simulate parsing NLP text (stub)
    if ((_nlpText ?? '').trim().isEmpty) return;
    // For demo: just add a transaction with the text as notes
    final transaction = Transaction(
      id: UniqueKey().toString(),
      category:
          Provider.of<AppData>(context, listen: false).expenseCategories.first,
      amount: 0.0,
      type: TransactionType.expense,
      date: DateTime.now(),
      notes: _nlpText ?? '',
    );
    final appData = Provider.of<AppData>(context, listen: false);
    appData.addTransaction(transaction);
    Navigator.pop(context);
  }

  void _simulateOcrScan() async {
    setState(() {
      _isScanning = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _ocrResult =
          'المبلغ: 1500\nالفئة: طعام\nالتاريخ: 2025-07-24\nالوصف: غداء في مطعم';
      _isScanning = false;
    });
  }

  Widget _buildManualInput(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final categories = appData.expenseCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            prefixText: '﷼ ',
            hintText: '0',
            labelText: 'المبلغ',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => setState(
              () => _amount = double.tryParse(val.replaceAll(',', '')) ?? 0.0),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<Category>(
          value: _selectedCategory,
          items: categories
              .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name),
                  ))
              .toList(),
          onChanged: (cat) => setState(() => _selectedCategory = cat),
          decoration: const InputDecoration(
            labelText: 'الفئة',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? now,
              firstDate: DateTime(now.year - 2),
              lastDate: DateTime(now.year + 2),
              locale: const Locale('ar'),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'التاريخ',
              border: OutlineInputBorder(),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 20),
                const SizedBox(width: 8),
                Text(_selectedDate != null
                    ? DateFormat.yMMMMd('ar').format(_selectedDate!)
                    : 'اختر التاريخ'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextFormField(
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'الوصف',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => setState(() => _notes = val),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saveManualExpense,
          child: const Text('إضافة المصروف'),
        ),
      ],
    );
  }

  Widget _buildOcrInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isScanning) const Center(child: CircularProgressIndicator()),
        if (!_isScanning && _ocrResult == null) ...[
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
                child: Icon(Icons.camera_alt, size: 80, color: Colors.black38)),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _simulateOcrScan,
            icon: const Icon(Icons.document_scanner),
            label: const Text('مسح الإيصال'),
          ),
        ],
        if (_ocrResult != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child:
                Text(_ocrResult!, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تأكيد وإضافة المصروف'),
          ),
        ],
      ],
    );
  }

  Widget _buildNlpInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText:
                'وصف المصروف (مثال: اشتريت قهوة 1500 ريال من ستاربكس اليوم)',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => setState(() => _nlpText = val),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saveNlpExpense,
          child: const Text('إضافة المصروف'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'إضافة معاملة',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input method selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('يدوي'),
                    selected: _method == ExpenseInputMethod.manual,
                    onSelected: (_) =>
                        setState(() => _method = ExpenseInputMethod.manual),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('مسح إيصال'),
                    selected: _method == ExpenseInputMethod.ocr,
                    onSelected: (_) =>
                        setState(() => _method = ExpenseInputMethod.ocr),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('لغة طبيعية'),
                    selected: _method == ExpenseInputMethod.nlp,
                    onSelected: (_) =>
                        setState(() => _method = ExpenseInputMethod.nlp),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _method == ExpenseInputMethod.manual
                      ? _buildManualInput(context)
                      : _method == ExpenseInputMethod.ocr
                          ? _buildOcrInput(context)
                          : _buildNlpInput(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
