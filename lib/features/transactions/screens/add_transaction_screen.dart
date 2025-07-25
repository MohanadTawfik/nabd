// add_transaction_screen.dart
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

enum InputMethod { manual, ocr, nlp }

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
  // Input method state
  InputMethod _currentMethod = InputMethod.manual;

  // Transaction data
  double? _amount;
  Category? _selectedCategory;
  late bool _isEditing;
  late TransactionType _selectedType;
  DateTime _selectedDate = DateTime.now();
  String _notes = '';

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _nlpController = TextEditingController();

  // OCR state
  bool _isScanning = false;
  String? _ocrResult; // النص الخام المستخرج من OCR
  String? _ocrParsedData; // البيانات المعالجة التي تظهر للمستخدم

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
      _amountController.text = t.amount.toString();
      _notesController.text = t.notes;
    } else {
      _selectedType = widget.initialType ?? TransactionType.expense;
      // تعيين فئة افتراضية للمدخلات الجديدة لتحسين تجربة المستخدم
      // _selectedCategory = Provider.of<AppData>(context, listen: false)
      //     .categories
      //     .firstWhere((cat) => cat.name == 'أخرى' && cat.type == _selectedType);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _nlpController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    // التأكد من أن حقل الكمية يتم التحقق منه فقط في الوضع اليدوي
    if (_currentMethod == InputMethod.manual &&
        !_formKey.currentState!.validate()) {
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

    final transaction = Transaction(
      id: _isEditing ? widget.transactionToEdit!.id : const Uuid().v4(),
      category: _selectedCategory!,
      amount: _amount!,
      type: _selectedType,
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

  void _processNLP(String text) {
    // Simulate NLP processing
    setState(() {
      _amount = 100.0; // Example parsed amount
      // البحث عن فئة "طعام" أو "أخرى" إذا لم توجد "طعام"
      _selectedCategory = Provider.of<AppData>(context, listen: false)
          .categories
          .firstWhere((cat) => cat.name == 'طعام' && cat.type == _selectedType,
              orElse: () => Provider.of<AppData>(context, listen: false)
                  .categories
                  .firstWhere((cat) =>
                      cat.name == 'أخرى' && cat.type == _selectedType));
      _notes = text;
      _ocrParsedData =
          'المبلغ: ${_amount?.toStringAsFixed(2)} ر.ي، الفئة: ${_selectedCategory?.name}'; // تحديث النص المعالج
      _amountController.text = _amount.toString();
      _notesController.text = _notes;
    });
    // يمكن هنا الانتقال تلقائياً إلى الوضع اليدوي أو إظهار تأكيد
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحليل البيانات بنجاح!')));
  }

  Future<void> _startOCRScan() async {
    setState(() => _isScanning = true);

    // Simulate OCR processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isScanning = false;
      _ocrResult = 'مطعم بيتزا - 75.50 ريال'; // النص الخام
      _processNLP(_ocrResult!); // معالجة النص المستخرج
    });
  }

  Widget _buildMethodChip(InputMethod method, IconData icon, String label) {
    final isSelected = _currentMethod == method;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _currentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.2)
              : (isDark
                  ? AppColors.grey800.withOpacity(0.3)
                  : AppColors.grey200.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark ? AppColors.iconDark : AppColors.iconLight)
                        .withOpacity(0.8)),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark
                        ? AppColors.textDark.withOpacity(0.7)
                        : AppColors.textPrimary.withOpacity(0.8)),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        selectedType: _selectedType,
        onTypeChanged: (type) {
          setState(() {
            _selectedType = type;
            // Clear the selected category when changing types to avoid confusion
            if (_selectedCategory?.type != type) {
              _selectedCategory = null;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark; // Not used directly in build method

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
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // No SizedBox here, AppBar handles its own spacing with SafeArea
              // Method Selector
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: _buildMethodChip(
                            InputMethod.manual, Icons.edit_note, 'يدوي')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildMethodChip(
                            InputMethod.ocr, Icons.camera_alt, 'مسح')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildMethodChip(
                            InputMethod.nlp, Icons.chat_bubble, 'نصي')),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentMethod == InputMethod.manual
                        ? _buildManualInput()
                        : _currentMethod == InputMethod.ocr
                            ? _buildOCRInput()
                            : _buildNLPInput(),
                  ),
                ),
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
                      backgroundColor: _selectedType == TransactionType.expense
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

// امتداد لـ _AddTransactionScreenState لتضمين الـ Widgets الداخلية
extension _AddTransactionScreenWidgets on _AddTransactionScreenState {
  Widget _buildManualInput() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: ListView(
        // استخدام ListView بدلاً من Column لتجنب مشكلة الكيبورد
        padding: EdgeInsets.zero, // إزالة أي padding افتراضي
        children: [
          // _buildTypeToggle(),
          const SizedBox(height: 16),
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
                    ?.copyWith(color: AppColors.errorColor), // لون رسالة الخطأ
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
                  return 'قيمة غير صالحة'; // تأكيد أن المبلغ أكبر من 0
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
                hintText: 'ملاحظات (اختياري)', // إضافة كلمة (اختياري)
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor.withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) => _notes = value,
            ),
          ),
          const SizedBox(height: 16), // مسافة إضافية قبل زر الحفظ إن وجد
        ],
      ),
    );
  }

  Widget _buildOCRInput() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            // إضافة SingleChildScrollView للسماح بالتمرير
            child: _isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                            color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'جاري مسح الفاتورة...',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  )
                : _ocrParsedData != null
                    ? GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt,
                                  size: 64,
                                  color: (isDark
                                          ? AppColors.iconDark
                                          : AppColors.iconLight)
                                      .withOpacity(0.8)),
                              const SizedBox(height: 16),
                              Text(
                                'تم مسح وتحليل الفاتورة بنجاح!', // رسالة أوضح
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color:
                                      AppColors.successColor, // لون أخضر للنجاح
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _ocrParsedData!, // عرض البيانات المعالجة
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor.withOpacity(0.7)),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                // زر لتعديل يدوياً
                                onPressed: () {
                                  setState(() =>
                                      _currentMethod = InputMethod.manual);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary
                                      .withOpacity(0.1),
                                  foregroundColor: theme.colorScheme.secondary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.edit),
                                label: Text('تعديل يدوياً',
                                    style: theme.textTheme.labelSmall),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.document_scanner_outlined,
                            size: 100,
                            color: (isDark
                                    ? AppColors.iconDark
                                    : AppColors.iconLight)
                                .withOpacity(0.7),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'مسح الفاتورة ضوئياً', // نص أوضح
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              'قم بتصوير فاتورتك لاستخراج المعلومات تلقائياً.', // نص إرشادي أوضح
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
        const SizedBox(height: 24),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isScanning ? null : _startOCRScan,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.8),
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isScanning) ...[
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'جاري المسح...',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'بدء المسح',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNLPInput() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            // إضافة SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 64,
                    color: (isDark ? AppColors.iconDark : AppColors.iconLight)
                        .withOpacity(0.7)),
                const SizedBox(height: 24),
                Text(
                  'أدخل وصف المصروف',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: _nlpController,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'مثال: أنفقت 50 ريال على العشاء في مطعم بيتزا',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                    ),
                    onSubmitted: _processNLP,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'أو',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _currentMethod = InputMethod.ocr);
                  },
                  icon: Icon(Icons.camera_alt_outlined,
                      color: theme.colorScheme.primary),
                  label: Text('مسح الفاتورة',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.colorScheme.primary)),
                ),
              ],
            ),
          ),
        ),
        if (_amount != null) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.incomeColor),
              title: Text(
                'تم التعرف على المعاملة',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurface),
              ),
              subtitle: Text(
                '${_amount?.toStringAsFixed(2)} ر.ي - ${_selectedCategory?.name}',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit,
                    color: (isDark ? AppColors.iconDark : AppColors.iconLight)),
                onPressed: () {
                  setState(() => _currentMethod = InputMethod.manual);
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
