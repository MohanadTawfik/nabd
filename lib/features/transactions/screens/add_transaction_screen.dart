import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/theme/app_colors.dart';
// Import statements are managed by the IDE
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
  String? _ocrResult;

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
    if (!_formKey.currentState!.validate()) return;

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
      _selectedCategory = Category(
          id: '1',
          name: 'طعام',
          icon: Icons.fastfood,
          color: Colors.blue,
          type: TransactionType.expense);
      _notes = text;
      _amountController.text = _amount.toString();
      _notesController.text = _notes;
    });
  }

  Future<void> _startOCRScan() async {
    setState(() => _isScanning = true);

    // Simulate OCR processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isScanning = false;
      _ocrResult = 'مطعم بيتزا - 75.50 ريال';
      _processNLP(_ocrResult!);
    });
  }

  Widget _buildMethodChip(InputMethod method, IconData icon, String label) {
    final isSelected = _currentMethod == method;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _currentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected
                    ? theme.primaryColor
                    : theme.iconTheme.color?.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.primaryColor
                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Transaction type toggle widget
  Widget _buildTypeToggle() {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      borderRadius: 12,
      child: Row(
        children: [
          // Expense Button
          Expanded(
            child: _buildTypeToggleButton(
              type: TransactionType.expense,
              icon: Icons.arrow_upward,
              label: 'مصروف',
              color: AppColors.expenseColor,
            ),
          ),
          const SizedBox(width: 8),
          // Income Button
          Expanded(
            child: _buildTypeToggleButton(
              type: TransactionType.income,
              icon: Icons.arrow_downward,
              label: 'دخل',
              color: AppColors.incomeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggleButton({
    required TransactionType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    return Material(
      color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? color
                    : Theme.of(context).iconTheme.color?.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected ? color : Theme.of(context).hintColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Category selection dialog with enhanced UI and search
  Future<Category?> _showCategorySelector() async {
    final allCategories = Provider.of<AppData>(context, listen: false)
        .categories
        .where((c) => c.type == _selectedType)
        .toList();

    final searchController = TextEditingController();
    final filteredCategories = ValueNotifier<List<Category>>(allCategories);
    final focusNode = FocusNode();

    // Filter categories based on search query
    void filterCategories(String query) {
      if (query.isEmpty) {
        filteredCategories.value = allCategories;
      } else {
        final queryLower = query.toLowerCase();
        filteredCategories.value = allCategories.where((category) {
          return category.name.toLowerCase().contains(queryLower);
        }).toList();
      }
    }

    // Show the modal bottom sheet
    final result = await showModalBottomSheet<Category>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Focus node for the search field
          WidgetsBinding.instance.addPostFrameCallback((_) {
            focusNode.requestFocus();
          });

          return Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 12, left: 16, right: 16, bottom: 24),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.7),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle for dragging with animation
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).dividerColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Header with title and close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(context),
                              style: IconButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            Text(
                              'اختر الفئة',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(width: 48), // For balance
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Search bar
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: Theme.of(context).hintColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  focusNode: focusNode,
                                  onChanged: (value) {
                                    filterCategories(value);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'ابحث عن فئة...',
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (searchController.text.isNotEmpty)
                                IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  onPressed: () {
                                    searchController.clear();
                                    filterCategories('');
                                    setState(() {});
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),

                        // Categories grid with animation
                        ValueListenableBuilder<List<Category>>(
                          valueListenable: filteredCategories,
                          builder: (context, categories, _) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: categories.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.search_off_rounded,
                                              size: 48,
                                              color: Theme.of(context)
                                                  .hintColor
                                                  .withOpacity(0.5),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'لا توجد فئات تطابق البحث',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 0.9,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                      itemCount: categories.length,
                                      itemBuilder: (context, index) {
                                        final category = categories[index];
                                        return _buildCategoryItem(category);
                                      },
                                    ),
                            );
                          },
                        ),

                        // Add new category button
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement add new category
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                            ),
                          ),
                          icon: Icon(
                            Icons.add_circle_outline_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          label: Text(
                            'إضافة فئة جديدة',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
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
        },
      ),
    );

    // Clean up resources
    searchController.dispose();
    focusNode.dispose();
    filteredCategories.dispose();

    return result;
  }

  Widget _buildCategoryItem(Category category) {
    final isSelected = _selectedCategory?.id == category.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(2),
      child: Material(
        color:
            isSelected ? category.color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.pop(context, category),
          borderRadius: BorderRadius.circular(16),
          splashColor: category.color.withOpacity(0.2),
          highlightColor: category.color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated container for the icon background
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color.withOpacity(0.1)
                        : category.color.withOpacity(0.08),
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: category.color.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                // Category name with animation
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isSelected
                            ? category.color
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Selection indicator
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 3,
                    width: 16,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualInput() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Transaction type toggle
          _buildTypeToggle(),
          const SizedBox(height: 16),
          // Amount Field
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                    ),
                border: InputBorder.none,
                suffixText: '﷼',
                suffixStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
              onChanged: (value) {
                setState(() {
                  _amount = double.tryParse(value) ?? 0.0;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'الرجاء إدخال المبلغ';
                if (double.tryParse(value) == null) return 'قيمة غير صالحة';
                return null;
              },
            ),
          ),
          const SizedBox(height: 8),

          // Category Selector
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
                      color:
                          Theme.of(context).iconTheme.color?.withOpacity(0.7),
                    ),
              title: Text(
                _selectedCategory?.name ?? 'اختر الفئة',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _selectedCategory != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).hintColor,
                    ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
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
          // Date Picker
          GlassCard(
            padding: const EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.calendar_today,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
              title: Text(
                DateFormat('yyyy/MM/dd').format(_selectedDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: Icon(Icons.calendar_month,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          // Notes Field
          GlassCard(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'ملاحظات (اختياري)',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).hintColor.withOpacity(0.7),
                    ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) => _notes = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOCRInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Expanded(
            child: _isScanning
                ? const Center(child: CircularProgressIndicator())
                : _ocrResult != null
                    ? GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt,
                                  size: 64,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      ?.withValues(alpha: 0.7)),
                              const SizedBox(height: 16),
                              Text(
                                'تم مسح الفاتورة بنجاح',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _ocrResult!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.7)),
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
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                ?.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'مسح الفاتورة',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              'قم بتصوير فاتورتك لاستخراج المعلومات تلقائياً',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                          ),
                        ],
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
                      Theme.of(context).primaryColor.withOpacity(0.7),
                      Theme.of(context).primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
      ),
    );
  }

  Widget _buildNLPInput() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 64,
                  color: Theme.of(context)
                      .iconTheme
                      .color
                      ?.withValues(alpha: 0.7)),
              const SizedBox(height: 24),
              Text(
                'أدخل وصف المصروف',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _nlpController,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor),
                  decoration: InputDecoration(
                    hintText: 'مثال: أنفقت 50 ريال على العشاء في مطعم بيتزا',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.7),
                        ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor.withOpacity(0.3),
                  ),
                  onSubmitted: _processNLP,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'أو',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  // Switch to OCR mode
                  setState(() => _currentMethod = InputMethod.ocr);
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('مسح الفاتورة'),
              ),
            ],
          ),
        ),
        if (_amount != null) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: ListTile(
              leading: Icon(Icons.check_circle,
                  color: Theme.of(context).primaryColor),
              title: Text(
                'تم التعرف على المعاملة',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text(
                '${_amount?.toStringAsFixed(2)} ر.ي - ${_selectedCategory?.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'تعديل معاملة' : 'إضافة معاملة',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                color: Theme.of(context).appBarTheme.iconTheme?.color,
              ),
        ),
        centerTitle: false,
        leading: BackButton(
          color: Theme.of(context).appBarTheme.iconTheme?.color,
        ),
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Method Selector
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMethodChip(
                        InputMethod.manual, Icons.edit_note, 'يدوي'),
                    _buildMethodChip(InputMethod.ocr, Icons.camera_alt, 'مسح'),
                    _buildMethodChip(InputMethod.nlp, Icons.chat_bubble, 'نصي'),
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

              // Save Button
              if (_currentMethod == InputMethod.manual || _amount != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _selectedCategory != null ? _saveTransaction : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedType == TransactionType.expense
                                ? AppColors.expenseColor
                                : AppColors.incomeColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isEditing ? 'حفظ التعديلات' : 'حفظ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
