// smart_input_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart'; // ستحتاج لإضافة هذه الحزمة: file_picker
import 'package:image_picker/image_picker.dart'; // ستحتاج لإضافة هذه الحزمة: image_picker
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// نموذج مبسط لبيانات المعاملة المستخرجة
class ExtractedTransaction {
  final double amount;
  final String categoryName;
  final TransactionType type;
  final DateTime date;
  final String? notes;
  final String source; // مثلاً: 'OCR', 'NLP', 'Excel'

  ExtractedTransaction({
    required this.amount,
    required this.categoryName,
    required this.type,
    required this.date,
    this.notes,
    required this.source,
  });
}

class SmartInputScreen extends StatefulWidget {
  const SmartInputScreen({super.key});

  @override
  State<SmartInputScreen> createState() => _SmartInputScreenState();
}

class _SmartInputScreenState extends State<SmartInputScreen> {
  final TextEditingController _chatInputController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // قائمة بالمعاملات المستخرجة لعرضها في جدول
  List<ExtractedTransaction> _extractedTransactions = [];
  bool _isLoading = false; // حالة التحميل

  @override
  void dispose() {
    _chatInputController.dispose();
    super.dispose();
  }

  // محاكاة لعملية معالجة النص
  void _processTextInput(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // محاكاة لزمن المعالجة

    // مثال على استخراج بيانات وهمية من النص
    final random = (text.length % 2 == 0) ? TransactionType.expense : TransactionType.income;
    final categoryName = text.contains('طعام') ? 'طعام' : 'أخرى';
    final amount = double.tryParse(RegExp(r'\d+(\.\d+)?').firstMatch(text)?.group(0) ?? '0') ?? 50.0;
    final notes = text;

    setState(() {
      _extractedTransactions.add(ExtractedTransaction(
        amount: amount,
        categoryName: categoryName,
        type: random,
        date: DateTime.now(),
        notes: notes,
        source: 'NLP',
      ));
      _isLoading = false;
      _chatInputController.clear();
    });
  }

  // محاكاة لعملية مسح الصورة (OCR)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(const Duration(seconds: 3)); // محاكاة لزمن OCR

        // مثال على بيانات مستخرجة من صورة
        final ExtractedTransaction newTxn = ExtractedTransaction(
          amount: 120.0,
          categoryName: 'تسوق',
          type: TransactionType.expense,
          date: DateTime.now(),
          notes: 'فاتورة تسوق من سوبر ماركت',
          source: 'OCR',
        );

        setState(() {
          _extractedTransactions.add(newTxn);
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم استخراج البيانات من الصورة بنجاح!'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التقاط الصورة: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // محاكاة لعملية اختيار ملف (Excel/CSV/PDF)
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(const Duration(seconds: 4)); // محاكاة لزمن معالجة الملف

        // مثال على بيانات مستخرجة من ملف (عدة معاملات)
        List<ExtractedTransaction> newTxns = [
          ExtractedTransaction(amount: 350.0, categoryName: 'إيجار', type: TransactionType.expense, date: DateTime.now().subtract(Duration(days: 5)), notes: 'إيجار شهر يوليو', source: 'File'),
          ExtractedTransaction(amount: 500.0, categoryName: 'راتب', type: TransactionType.income, date: DateTime.now().subtract(Duration(days: 3)), notes: 'راتب جزئي', source: 'File'),
          ExtractedTransaction(amount: 75.0, categoryName: 'مواصلات', type: TransactionType.expense, date: DateTime.now().subtract(Duration(days: 1)), notes: 'وقود', source: 'File'),
        ];

        setState(() {
          _extractedTransactions.addAll(newTxns);
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم استخراج البيانات من الملف بنجاح!'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل اختيار الملف: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // دالة لحفظ المعاملات المستخرجة بعد المراجعة
  void _saveAllExtractedTransactions() {
    if (_extractedTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد معاملات لحفظها.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final appData = Provider.of<AppData>(context, listen: false);
    for (var et in _extractedTransactions) {
      // البحث عن الفئة المطابقة، أو تعيين فئة افتراضية "أخرى"
      final category = appData.categories.firstWhere(
        (c) => c.name == et.categoryName && c.type == et.type,
        orElse: () => appData.categories.firstWhere(
          (c) => c.name == 'أخرى' && c.type == et.type,
          orElse: () => appData.categories.first, // fallback لأي فئة متاحة
        ),
      );

      final transaction = Transaction(
        id: const Uuid().v4(),
        category: category,
        amount: et.amount,
        type: et.type,
        date: et.date,
        notes: et.notes ?? 'تم الإدخال عبر ${et.source}',
      );
      appData.addTransaction(transaction);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ ${_extractedTransactions.length} معاملة بنجاح!'),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    Navigator.pop(context); // العودة للشاشة السابقة بعد الحفظ
  }

  // دالة لحذف معاملة مستخرجة من القائمة (قبل الحفظ النهائي)
  void _deleteExtractedTransaction(int index) {
    setState(() {
      _extractedTransactions.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف المعاملة من قائمة المراجعة.'),
        backgroundColor: AppColors.warningColor,
      ),
    );
  }

  // دالة لتعديل معاملة مستخرجة (فتح شاشة يدوية للتعديل)
  Future<void> _editExtractedTransaction(int index) async {
    final originalTransaction = _extractedTransactions[index];
    final appData = Provider.of<AppData>(context, listen: false);

    // بناء Transaction model مؤقت للتعديل في شاشة AddTransactionScreen
    final tempTransaction = Transaction(
      id: const Uuid().v4(), // id مؤقت
      amount: originalTransaction.amount,
      category: appData.categories.firstWhere(
        (c) => c.name == originalTransaction.categoryName && c.type == originalTransaction.type,
        orElse: () => appData.categories.firstWhere((c) => c.name == 'أخرى' && c.type == originalTransaction.type,
          orElse: () => appData.categories.first
        ),
      ),
      type: originalTransaction.type,
      date: originalTransaction.date,
      notes: originalTransaction.notes ?? 'تم الإدخال عبر ${originalTransaction.source}',
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(transactionToEdit: tempTransaction),
      ),
    );

    // إذا تم تعديل وحفظ المعاملة في الشاشة الأخرى (AddTransactionScreen)
    // يمكننا تحديثها هنا أو التعامل معها بطريقة أخرى.
    // حالياً، AddTransactionScreen تحفظها مباشرة، لذلك لا نحتاج لتحديثها هنا.
    // يمكننا ببساطة إزالتها من قائمة _extractedTransactions لأنها حُفظت.
    if (result != null && result is bool && result) { // افتراض أن result true إذا تم الحفظ
      _deleteExtractedTransaction(index);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'إدخال ذكي / آلي',
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        leading: BackButton(
          color: theme.colorScheme.onSurface,
        ),
        actions: [
          if (_extractedTransactions.isNotEmpty && !_isLoading)
            IconButton(
              icon: Icon(Icons.check_circle_outline, color: AppColors.successColor),
              onPressed: _saveAllExtractedTransactions,
              tooltip: 'حفظ الكل',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // حقل إدخال الشات
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatInputController,
                          minLines: 1,
                          maxLines: 5,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'أدخل تفاصيل مصروفاتك أو فواتيرك هنا (مثال: دفعت 50 ريال للكهرباء)',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor.withOpacity(0.7),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: _processTextInput,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary),
                            onPressed: () => _processTextInput(_chatInputController.text),
                            tooltip: 'إرسال النص',
                          ),
                          const SizedBox(height: 8), // مسافة بين الأزرار
                          IconButton(
                            icon: Icon(Icons.camera_alt_outlined, color: theme.colorScheme.secondary),
                            onPressed: () => _pickImage(ImageSource.camera),
                            tooltip: 'التقاط صورة فاتورة',
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            icon: Icon(Icons.upload_file, color: theme.colorScheme.secondary),
                            onPressed: _pickFile,
                            tooltip: 'رفع فاتورة/ملف (PDF, Excel, CSV)',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('جاري معالجة البيانات...', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)),
                    ],
                  ),
                ),

              // عرض المعاملات المستخرجة في جدول
              Expanded(
                child: _extractedTransactions.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 80, color: theme.hintColor.withOpacity(0.4)),
                            const SizedBox(height: 24),
                            Text(
                              'لا توجد معاملات مستخرجة بعد.',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.hintColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'أدخل نصًا أو ارفع صورة / ملف لبدء الاستخراج التلقائي.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: _extractedTransactions.length,
                        itemBuilder: (context, index) {
                          final txn = _extractedTransactions[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: GlassCard(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: (txn.type == TransactionType.expense ? AppColors.expenseColor : AppColors.incomeColor).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      txn.type == TransactionType.expense ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: txn.type == TransactionType.expense ? AppColors.expenseColor : AppColors.incomeColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          txn.categoryName,
                                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                                        ),
                                        Text(
                                          '${DateFormat('yyyy/MM/dd').format(txn.date)} - ${txn.source}',
                                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor.withOpacity(0.7)),
                                        ),
                                        if (txn.notes != null && txn.notes!.isNotEmpty)
                                          Text(
                                            txn.notes!,
                                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor.withOpacity(0.6)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${txn.amount.toStringAsFixed(2)} ﷼',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: txn.type == TransactionType.expense ? AppColors.expenseColor : AppColors.incomeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 20, color: theme.colorScheme.primary),
                                    onPressed: () => _editExtractedTransaction(index),
                                    tooltip: 'تعديل',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                                    onPressed: () => _deleteExtractedTransaction(index),
                                    tooltip: 'حذف',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}