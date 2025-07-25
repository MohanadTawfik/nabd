// add_transaction_screen.dart (Updated)
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      _notes = t.notes ?? '';
      _amountController.text = t.amount.toString();
      _notesController.text = _notes;
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
      source: 'Manual',
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

// Replace the entire _buildManualInputContent method with this:
  Widget _buildManualInputContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Amount Input
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor.withOpacity(0.7),
                ),
                border: InputBorder.none,
                suffixText: '﷼',
                suffixStyle: textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ),
                errorStyle: textTheme.bodySmall?.copyWith(
                  color: AppColors.errorColor,
                ),
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
          const SizedBox(height: 12),

          // Category Selection
          GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedCategory?.color.withOpacity(0.1) ??
                      theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _selectedCategory?.icon ?? Icons.category_outlined,
                  color: _selectedCategory?.color ?? theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              title: Text(
                _selectedCategory?.name ?? 'اختر الفئة',
                style: textTheme.bodyLarge?.copyWith(
                  color: _selectedCategory != null
                      ? theme.colorScheme.onSurface
                      : theme.hintColor,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.hintColor,
              ),
              onTap: () async {
                final category = await _showCategorySelector();
                if (category != null) {
                  setState(() => _selectedCategory = category);
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // Date Selection
          GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              title: Text(
                DateFormat('EEEE, d MMMM yyyy', 'ar').format(_selectedDate),
                style: textTheme.bodyLarge,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.hintColor,
              ),
              onTap: _selectDate,
            ),
          ),
          const SizedBox(height: 12),

          // Notes
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'اضف ملاحظة (اختياري)',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => _notes = value,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Date selection with theme support
  Future<void> _selectDate() async {
    try {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      // Use Builder to get a context that has access to MaterialLocalizations
      return await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: theme.colorScheme.primary,
                onPrimary: Colors.white,
                onSurface: isDark ? Colors.white : Colors.black87,
                surface: isDark ? const Color(0xFF121212) : Colors.white,
              ),
              dialogBackgroundColor:
                  isDark ? const Color(0xFF1E1E1E) : Colors.white,
            ),
            child: DatePickerDialog(
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialEntryMode: DatePickerEntryMode.calendar,
              cancelText: 'إلغاء',
              confirmText: 'تأكيد',
              helpText: 'اختر تاريخ المعاملة',
            ),
          );
        },
      ).then((picked) {
        if (picked != null && mounted) {
          setState(() {
            _selectedDate = picked;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
          // Smart Input Button - More prominent with text
          TextButton.icon(
            icon: Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
            label: Text(
              'إدخال ذكي',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SmartInputScreen(),
                ),
              );

              // If transactions were saved in the smart input screen, pop this screen
              if (result == true) {
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
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
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              // ),
              const SizedBox(height: 20),
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
