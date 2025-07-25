// add_transaction_screen.dart (Updated)
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/widgets/categories_panal.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/features/transactions/screens/smart_input_screen.dart'; // استيراد الشاشة الجديدة

// لم نعد بحاجة لـ InputMethod enum هنا
// enum InputMethod { manual, ocr, nlp }

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transactionToEdit;
  final TransactionType? initialType;

  const AddTransactionScreen({
    super.key,
    this.transactionToEdit,
    this.initialType,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // تم إزالة _currentMethod

  // Transaction data
  double? _amount;
  Category? _selectedCategory;
  late bool _isEditing;
  DateTime _selectedDate = DateTime.now();
  String _notes = '';

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  // تم إزالة _nlpController

  // تم إزالة OCR state
  // bool _isScanning = false;
  // String? _ocrResult;
  // String? _ocrParsedData;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transactionToEdit != null;

    if (_isEditing) {
      final t = widget.transactionToEdit!;
      _amount = t.amount;
      _selectedCategory = t.category;
      _selectedDate = t.date;
      _notes = t.notes;
      _amountController.text = t.amount.toString();
      _notesController.text = t.notes;
    } else {
      _selectedCategory =
          null; // نتركها null في البداية، ويجب على المستخدم اختيار فئة
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    // تم إزالة _nlpController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null || _amount == null || _amount! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إدخال المبلغ وتحديد الفئة بشكل صحيح.',
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final transactionType = _selectedCategory!.type;

    final transaction = Transaction(
      id: _isEditing ? widget.transactionToEdit!.id : const Uuid().v4(),
      category: _selectedCategory!,
      amount: _amount!,
      type: transactionType,
      date: _selectedDate,
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

  // تم إزالة _processNLP و _startOCRScan
  // لأنهما سينتقلان إلى شاشة الإدخال الذكي

  // تم إزالة _buildMethodChip
  // تم إزالة _buildTypeToggle
  // تم إزالة _buildTypeToggleButton

  Future<Category?> _showCategorySelector() async {
    final allCategories =
        Provider.of<AppData>(context, listen: false).categories;

    return await showModalBottomSheet<Category>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CategorySelectorBottomSheet(
        allCategories: allCategories,
        selectedCategory: _selectedCategory,
        selectedType: _selectedCategory?.type ?? TransactionType.expense,
        onTypeChanged: (type) {
          setState(() {
            _selectedCategory = _selectedCategory;
          });
        },
        // _displayType سيتم إدارتها داخل BottomSheet نفسها
      ),
    );
  }

  // تم نقل الـ Widgets _buildManualInput, _buildOCRInput, _buildNLPInput
  // إلى امتدادات أو في ملفات منفصلة إذا كانت ستُستخدم فقط في شاشات معينة.
  // في هذه الحالة، سأبقيهم هنا مؤقتًا لكن أضعهم ضمن الـ build
  // وسأقوم بتعديلهم لاحقاً ليتوافقوا مع الهيكل الجديد.
  // حالياً، _buildManualInput سيكون هو المحتوى الرئيسي.

  Widget _buildManualInputContent() {
    // دالة مساعدة لتضمين محتوى الإدخال اليدوي
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: ListView(
        // استخدام ListView بدلاً من Column لتجنب مشكلة الكيبورد
        padding: EdgeInsets.zero, // إزالة أي padding افتراضي
        children: [
          // _buildTypeToggle(), // تم إزالته
          // const SizedBox(height: 16), // لا حاجة للمسافة هنا بعد إزالة الـ Toggle
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor.withOpacity(0.7),
                ),
                border: InputBorder.none,
                suffixText: '﷼',
                suffixStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ),
                errorStyle: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.errorColor),
              ),
              onChanged: (value) {
                setState(() {
                  _amount = double.tryParse(value) ?? 0.0;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال المبلغ';
                }
                if (double.tryParse(value) == null ||
                    double.tryParse(value)! <= 0) {
                  return 'قيمة غير صالحة';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8),

          GlassCard(
            padding: const EdgeInsets.all(10),
            child: ListTile(
              leading: _selectedCategory != null
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedCategory!.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _selectedCategory!.icon,
                        color: _selectedCategory!.color,
                      ),
                    )
                  : Icon(
                      Icons.category,
                      color: (isDark ? AppColors.iconDark : AppColors.iconLight)
                          .withOpacity(0.7),
                    ),
              title: Text(
                _selectedCategory?.name ?? 'اختر الفئة',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _selectedCategory != null
                      ? theme.colorScheme.onSurface
                      : theme.hintColor.withOpacity(0.8),
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: (isDark ? AppColors.iconDark : AppColors.iconLight)
                    .withOpacity(0.7),
              ),
              onTap: () async {
                final category = await _showCategorySelector();
                if (category != null) {
                  setState(() => _selectedCategory = category);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.calendar_today,
                  color: (isDark ? AppColors.iconDark : AppColors.iconLight)
                      .withOpacity(0.7)),
              title: Text(
                DateFormat('yyyy/MM/dd').format(_selectedDate),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              trailing: Icon(Icons.calendar_month,
                  color: (isDark ? AppColors.iconDark : AppColors.iconLight)
                      .withOpacity(0.7)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        colorScheme: theme.colorScheme.copyWith(
                          primary: AppColors.primaryColor,
                          onSurface: theme.colorScheme.onSurface,
                          onPrimary: AppColors.textDark,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'ملاحظات (اختياري)',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor.withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) => _notes = value,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'تعديل معاملة' : 'إضافة معاملة',
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        leading: BackButton(
          color: theme.colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            // زر جديد للإدخال الذكي
            icon:
                Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SmartInputScreen(), // الانتقال للشاشة الجديدة
                ),
              );
            },
            tooltip: 'إدخال ذكي / آلي',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassBackground(
        child: SafeArea(
          // SafeArea هنا ستعتني بالمسافة العلوية
          child: Column(
            children: [
              // لم يعد هناك حاجة لـ Method Selector
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       Expanded(
              //           child: _buildMethodChip(
              //               InputMethod.manual, Icons.edit_note, 'يدوي')),
              //       const SizedBox(width: 8),
              //       Expanded(
              //           child: _buildMethodChip(
              //               InputMethod.ocr, Icons.camera_alt, 'مسح')),
              //       const SizedBox(width: 8),
              //       Expanded(
              //           child: _buildMethodChip(
              //               InputMethod.nlp, Icons.chat_bubble, 'نصي')),
              //     ],
              //   ),
              // ),

              Expanded(
                // المحتوى الرئيسي سيكون دائماً الإدخال اليدوي
                child: _buildManualInputContent(),
              ),

              // Save Button (always visible at the bottom)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedCategory != null &&
                            _amount != null &&
                            _amount! > 0
                        ? _saveTransaction
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedCategory?.type == TransactionType.expense
                              ? AppColors.expenseColor
                              : AppColors.incomeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _isEditing ? 'حفظ التعديلات' : 'حفظ',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
