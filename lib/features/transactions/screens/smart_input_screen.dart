// smart_input_screen.dart (Final UI Enhancement)
import 'dart:io';
import 'dart:ui'; // لـ ImageFilter
import 'package:flutter/material.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/widgets/empty_state.dart';
import 'package:nabd/widgets/loading_state.dart';
import 'package:nabd/widgets/error_state.dart';
import 'package:nabd/utils/ui_utils.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SmartInputScreen extends StatefulWidget {
  const SmartInputScreen({super.key});

  @override
  State<SmartInputScreen> createState() => _SmartInputScreenState();
}

class _SmartInputScreenState extends State<SmartInputScreen> {
  final TextEditingController _chatInputController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Transaction> _extractedTransactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chatInputController.addListener(() {
      setState(() {
        // إعادة بناء فقط لتحديث حالة زر الإرسال
      });
    });
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    super.dispose();
  }

  Category _getCategory(String categoryName, TransactionType type) {
    final provider = Provider.of<TransactionsProvider>(context, listen: false);
    try {
      return provider.transactions
          .firstWhere(
            (t) => t.category.name == categoryName && t.category.type == type,
            orElse: () => provider.transactions.isNotEmpty
                ? provider.transactions.first
                : Transaction(
                    id: const Uuid().v4(),
                    amount: 0.0,
                    category: Category(
                      id: const Uuid().v4(),
                      name: categoryName,
                      type: type,
                      color: Colors.grey,
                      icon: Icons.category,
                    ),
                    type: type,
                    date: DateTime.now(),
                    notes: '',
                    source: '',
                  ),
          )
          .category;
    } catch (e) {
      return Category(
          id: const Uuid().v4(),
          name: categoryName,
          type: type,
          color: Colors.grey,
          icon: Icons.category);
    }
  }

  void _processTextInput(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _chatInputController.clear(); // مسح النص فور الإرسال
    });
    FocusScope.of(context).unfocus(); // إخفاء الكيبورد

    await Future.delayed(const Duration(seconds: 2));

    final randomType = (text.length % 2 == 0)
        ? TransactionType.expense
        : TransactionType.income;
    final parsedCategoryName = text.contains('طعام') ? 'طعام' : 'أخرى';
    final amount = double.tryParse(
            RegExp(r'\d+(\.\d+)?').firstMatch(text)?.group(0) ?? '0') ??
        50.0;
    final notes = text;

    final category = _getCategory(parsedCategoryName, randomType);

    setState(() {
      _extractedTransactions.insert(
          0,
          Transaction(
            id: const Uuid().v4(),
            amount: amount,
            category: category,
            type: randomType,
            date: DateTime.now(),
            notes: notes,
            source: 'NLP',
          ));
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _isLoading = true;
        });
        FocusScope.of(context).unfocus();

        await Future.delayed(const Duration(seconds: 3));

        final category = _getCategory('تسوق', TransactionType.expense);
        final Transaction newTxn = Transaction(
          id: const Uuid().v4(),
          amount: 120.0,
          category: category,
          type: TransactionType.expense,
          date: DateTime.now(),
          notes: 'فاتورة تسوق من سوبر ماركت',
          source: 'OCR',
        );

        setState(() {
          _extractedTransactions.insert(0, newTxn);
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم استخراج البيانات من الصورة بنجاح!'),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التقاط الصورة: $e'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        FocusScope.of(context).unfocus();
        await Future.delayed(const Duration(seconds: 4));

        List<Transaction> newTxns = [
          Transaction(
              id: const Uuid().v4(),
              amount: 350.0,
              category: _getCategory('إيجار', TransactionType.expense),
              type: TransactionType.expense,
              date: DateTime.now().subtract(const Duration(days: 5)),
              notes: 'إيجار شهر يوليو',
              source: 'File'),
          Transaction(
              id: const Uuid().v4(),
              amount: 500.0,
              category: _getCategory('راتب', TransactionType.income),
              type: TransactionType.income,
              date: DateTime.now().subtract(const Duration(days: 3)),
              notes: 'راتب جزئي',
              source: 'File'),
          Transaction(
              id: const Uuid().v4(),
              amount: 75.0,
              category: _getCategory('مواصلات', TransactionType.expense),
              type: TransactionType.expense,
              date: DateTime.now().subtract(const Duration(days: 1)),
              notes: 'وقود',
              source: 'File'),
        ];

        setState(() {
          _extractedTransactions.insertAll(0, newTxns);
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم استخراج البيانات من الملف بنجاح!'),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل اختيار الملف: $e'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _saveAllExtractedTransactions() async {
    if (_extractedTransactions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('لا توجد معاملات لحفظها.'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
      return false;
    }

    bool allSaved = true;
    final provider = Provider.of<TransactionsProvider>(context, listen: false);

    try {
      for (var txn in _extractedTransactions) {
        try {
          await provider.addTransaction(txn);
        } catch (e) {
          debugPrint('Error saving transaction: $e');
          allSaved = false;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('تم حفظ ${_extractedTransactions.length} معاملة بنجاح!'),
            backgroundColor:
                allSaved ? AppColors.successColor : AppColors.warningColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return allSaved;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('حدث خطأ أثناء حفظ المعاملات'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
      return false;
    }
  }

  void _deleteExtractedTransaction(int index) {
    setState(() {
      _extractedTransactions.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حذف المعاملة من قائمة المراجعة.'),
        backgroundColor: AppColors.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _editExtractedTransaction(int index) async {
    final originalTransaction = _extractedTransactions[index];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddTransactionScreen(transactionToEdit: originalTransaction),
      ),
    );

    if (result != null && result is bool && result) {
      _deleteExtractedTransaction(index);
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
          'إدخال ذكي / آلي',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
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
              icon: Icon(Icons.check_circle_outline,
                  color: AppColors.successColor),
              onPressed: () async {
                bool saved = await _saveAllExtractedTransactions();
                if (saved && mounted) {
                  setState(() {
                    _extractedTransactions.clear();
                  });
                }
              },
              tooltip: 'حفظ الكل',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GlassBackground(
              child: SafeArea(
                child: _isLoading
                    ? const LoadingState(
                        message: 'جاري معالجة البيانات...',
                      )
                    : _extractedTransactions.isEmpty
                        ? _buildEmptyState(theme)
                        : _buildTransactionList(theme),
              ),
            ),
          ),
          // منطقة الإدخال السفلية (Chat Input Bar)
          _buildBottomInputBar(theme),
        ],
      ),
    );
  }

  // Widget جديد لمنطقة الإدخال السفلية
  Widget _buildBottomInputBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6), // خلفية شفافة قليلاً
        // تأثير ضبابي خفيف للخلفية (مثل جزء من GlassCard)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // ظل أخف
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRect(
        // ClipRect لمنع الظل والتمويه من تجاوز الحدود
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // تمويه خفيف جداً
          child: SafeArea(
            top: false, // لا تترك مسافة علوية في SafeArea هذه
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0), // Padding حول حقل النص والأزرار
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text Input Field
                  Expanded(
                    child: GlassCard(
                      // حقل النص داخل GlassCard
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0), // padding داخلي لـ TextField
                      borderRadius: 12, // حواف دائرية أكثر
                      blurStrength: 8, // تمويه مناسب
                      opacity: theme.brightness == Brightness.dark
                          ? 0.1
                          : 0.05, // شفافية أدنى
                      child: TextField(
                        controller: _chatInputController,
                        minLines: 1,
                        maxLines: 4, // زيادة قليلاً
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        onSubmitted: (_) {
                          if (_chatInputController.text.trim().isNotEmpty) {
                            _processTextInput(_chatInputController.text);
                          }
                        },
                        style: theme.textTheme.bodyLarge?.copyWith(
                          // استخدام bodyLarge
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'أدخل تفاصيل مصروفاتك...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            // استخدام bodyLarge
                            color: theme.hintColor.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, // padding أكبر لراحة العين
                            horizontal: 16,
                          ),
                          isDense: true,
                          prefixIcon: IconButton(
                            icon: Icon(
                              Icons.mic_rounded,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            onPressed: () => _showVoiceInputDialog(context),
                            tooltip: 'استخدم الصوت للكتابة',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 40, minHeight: 40), // حجم ثابت
                          ),
                          suffixIcon:
                              _chatInputController.text.trim().isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.send_rounded,
                                        color: theme.colorScheme.primary,
                                        size: 24,
                                      ),
                                      onPressed: () => _processTextInput(
                                          _chatInputController.text),
                                      tooltip: 'إرسال',
                                      constraints: const BoxConstraints(
                                          minWidth: 40, minHeight: 40),
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons
                                            .attachment_rounded, // أيقونة إرفاق موحدة
                                        color: theme.colorScheme.primary,
                                        size: 24,
                                      ),
                                      onPressed: _showAttachmentOptions,
                                      tooltip: 'إرفاق ملف',
                                      constraints: const BoxConstraints(
                                          minWidth: 40, minHeight: 40),
                                    ),
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
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
    );
  }

  void _showAttachmentOptions() {
    UiUtils.showCustomBottomSheet(
      context: context,
      title: 'اختر طريقة الإدخال',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.camera_alt,
                  color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('التقاط صورة'),
            subtitle: const Text('استخدم الكاميرا لالتقاط صورة'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('اختيار صورة من المعرض'),
            subtitle: const Text('اختر صورة موجودة من معرض الصور'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.file_present,
                  color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('اختيار ملف'),
            subtitle: const Text('اختر ملف PDF أو Excel لاستخراج المعاملات'),
            onTap: () {
              Navigator.pop(context);
              _pickFile();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showVoiceInputDialog(BuildContext context) {
    UiUtils.showCustomDialog(
      context: context,
      title: 'الكتابة بالصوت',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_rounded,
              size: 60, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'تحدث الآن...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 16),
          const LoadingState(message: ""),
        ],
      ),
      barrierDismissible: false,
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ),
      ],
    );
    // يمكن هنا إضافة منطق لبدء الاستماع الصوتي وإغلاق الـ dialog تلقائياً
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      key: const ValueKey('emptyState'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: EmptyState(
            icon: Icons.auto_awesome_motion_rounded,
            iconSize: 70,
            iconColor: theme.colorScheme.onPrimary,
            iconBackground: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.7),
                theme.colorScheme.secondary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            title: 'أدخل تفاصيل مصروفاتك بطريقة ذكية',
            titleStyle: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            message:
                'يمكنك كتابة تفاصيل المعاملة أو إرفاق صورة أو ملف للاستخراج التلقائي',
            messageStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.hintColor.withOpacity(0.8),
              height: 1.5,
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      theme,
                      icon: Icons.camera_alt_outlined,
                      label: 'التقط صورة',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      theme,
                      icon: Icons.photo_library_outlined,
                      label: 'اختر صورة',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      theme,
                      icon: Icons.file_present_outlined,
                      label: 'اختر ملف',
                      onTap: _pickFile,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'أو ابدأ بالكتابة في الحقل أدناه...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Material(
          // استخدام Material لتأثير النقر
          color: Colors.transparent, // شفافية Material
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                // لون زجاجي خفيف
                color:
                    theme.colorScheme.surface.withOpacity(0.2), // شفافية أعلى
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      theme.colorScheme.onSurface.withOpacity(0.1), // حد خفيف
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05), // ظل أخف
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 32, // أيقونة أكبر قليلاً
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            // استخدام labelLarge
            color: theme.colorScheme.onSurface.withOpacity(0.9), // لون أوضح
            fontWeight: FontWeight.w600, // خط أثقل
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(ThemeData theme) {
    return ListView.builder(
      key: const ValueKey('transactionList'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _extractedTransactions.length,
      itemBuilder: (context, index) {
        final txn = _extractedTransactions[index];
        final Category displayCategory =
            _getCategory(txn.category.name, txn.type);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            blurStrength: 10,
            opacity: theme.brightness == Brightness.dark ? 0.15 : 0.1,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (txn.type == TransactionType.expense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    displayCategory.icon,
                    color: displayCategory.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayCategory.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface),
                      ),
                      Text(
                        '${DateFormat('EEEE, d MMM yyyy', 'ar').format(txn.date)} - ${txn.source}', // تنسيق تاريخ مفصل
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor.withOpacity(0.7)),
                      ),
                      if (txn.notes != null && txn.notes!.isNotEmpty)
                        Text(
                          txn.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor.withOpacity(0.6)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${txn.amount.toStringAsFixed(2)} ﷼',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: txn.type == TransactionType.expense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit,
                              size: 20, color: theme.colorScheme.primary),
                          onPressed: () => _editExtractedTransaction(index),
                          tooltip: 'تعديل',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32), // زيادة حجم منطقة النقر
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 20, color: theme.colorScheme.error),
                          onPressed: () => _deleteExtractedTransaction(index),
                          tooltip: 'حذف',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32), // زيادة حجم منطقة النقر
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
