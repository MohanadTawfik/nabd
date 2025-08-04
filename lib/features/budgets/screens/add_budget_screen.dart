import 'package:flutter/material.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:nabd/features/budgets/budgets_provider.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/widgets/glass_background.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;

  const AddBudgetScreen({
    super.key,
    this.budget,
  });

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _searchController = TextEditingController();

  late BudgetPeriod _selectedPeriod;
  late bool _receiveNotifications;
  late double _notificationThreshold;

  Category? _selectedCategory;
  bool _isGeneralBudget = false;
  List<Category> _filteredCategories = [];
  final List<Category> _availableCategories = [];

  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();

    // Initialize with existing budget data if in edit mode
    if (widget.budget != null) {
      _amountController.text = widget.budget!.totalAmount.toStringAsFixed(0);
      _selectedPeriod = widget.budget!.period;
      _receiveNotifications = widget.budget!.receiveNotifications;
      _notificationThreshold = widget.budget!.notificationThreshold;
      _isGeneralBudget = widget.budget!.category == null;
      _selectedCategory = widget.budget!.category;
    } else {
      _selectedPeriod = BudgetPeriod.monthly;
      _receiveNotifications = true;
      _notificationThreshold = 80.0;
    }

    // Load categories after the first frame is built
    Future.microtask(() {
      if (mounted) {
        _loadCategories();
      }
    });
  }

  void _loadCategories() {
    final budgetsProvider =
        Provider.of<BudgetsProvider>(context, listen: false);
    setState(() {
      _availableCategories.clear();
      _availableCategories.addAll(budgetsProvider.budgets
          .map((b) => b.category)
          .whereType<Category>()
          .where((cat) => cat.type == TransactionType.expense)
          .toSet()
          .toList());
      _filteredCategories = List.from(_availableCategories);
      if (widget.budget != null) {
        _isGeneralBudget = widget.budget!.category == null;
        if (!_isGeneralBudget) {
          _selectedCategory = _availableCategories.firstWhere(
            (cat) => cat.id == widget.budget!.category?.id,
            orElse: () => Category(
              id: 'other',
              name: 'أخرى',
              icon: Icons.category,
              color: Colors.grey,
              type: TransactionType.expense,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Budget _createBudget({Category? forCategory, double? amount}) {
    final now = DateTime.now();
    DateTime startDate = _customStartDate ?? widget.budget?.startDate ?? now;
    DateTime endDate = _customEndDate ?? widget.budget?.endDate ?? now;
    if (_selectedPeriod != BudgetPeriod.custom) {
      startDate = now;
      switch (_selectedPeriod) {
        case BudgetPeriod.weekly:
          endDate = now.add(const Duration(days: 7));
          break;
        case BudgetPeriod.monthly:
          endDate = DateTime(now.year, now.month + 1, now.day);
          break;
        case BudgetPeriod.yearly:
          endDate = DateTime(now.year + 1, now.month, now.day);
          break;
        case BudgetPeriod.custom:
          break;
      }
    }
    return Budget(
      id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: forCategory ?? (_isGeneralBudget ? null : _selectedCategory),
      totalAmount: amount ?? double.tryParse(_amountController.text) ?? 0.0,
      startDate: startDate,
      endDate: endDate,
      period: _selectedPeriod,
      receiveNotifications: _receiveNotifications,
      notificationThreshold: _notificationThreshold,
      spentAmount: widget.budget?.spentAmount ?? 0.0,
    );
  }

  bool _isOverlapping(Budget newBudget, List<Budget> budgets) {
    return budgets.any((b) =>
        b.id != newBudget.id &&
        b.category?.id == newBudget.category?.id &&
        b.period == newBudget.period &&
        ((b.startDate.isBefore(newBudget.endDate) &&
                b.endDate.isAfter(newBudget.startDate)) ||
            b.startDate == newBudget.startDate ||
            b.endDate == newBudget.endDate));
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_isGeneralBudget && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار فئة للميزانية'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final budgetsProvider =
        Provider.of<BudgetsProvider>(context, listen: false);
    final allBudgets = budgetsProvider.budgets;
    if (_isGeneralBudget) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      if (_availableCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد فئات مصروفات متاحة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final perCategory = amount / _availableCategories.length;
      for (final cat in _availableCategories) {
        final newBudget = _createBudget(forCategory: cat, amount: perCategory);
        if (_isOverlapping(newBudget, allBudgets)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('يوجد ميزانية لنفس الفئة والفترة متداخلة (${cat.name})'),
              backgroundColor: Colors.orange,
            ),
          );
          continue;
        }
        await budgetsProvider.addBudget(newBudget);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة الميزانيات بنجاح لجميع الفئات'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      return;
    }
    // منع تغيير الفئة عند التعديل
    if (widget.budget != null && widget.budget!.category != null) {
      final newBudget = _createBudget(forCategory: widget.budget!.category);
      if (_isOverlapping(newBudget, allBudgets)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يوجد ميزانية لنفس الفئة والفترة متداخلة'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      await budgetsProvider.updateBudget(newBudget);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الميزانية بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      return;
    }
    // إضافة أو تحديث ميزانية مخصصة
    final newBudget = _createBudget();
    if (_isOverlapping(newBudget, allBudgets)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يوجد ميزانية لنفس الفئة والفترة متداخلة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (widget.budget != null) {
      await budgetsProvider.updateBudget(newBudget);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الميزانية بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await budgetsProvider.addBudget(newBudget);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة الميزانية بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
    Navigator.pop(context);
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = _availableCategories
          .where((category) =>
              category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildBudgetTypeToggle() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الميزانية',
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBudgetTypeCard(
                title: 'عامة',
                subtitle: 'لجميع المصروفات',
                icon: Icons.account_balance_wallet_outlined,
                isSelected: _isGeneralBudget,
                onTap: () {
                  setState(() {
                    _isGeneralBudget = true;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBudgetTypeCard(
                title: 'مخصصة',
                subtitle: 'لفئة محددة',
                icon: Icons.category_outlined,
                isSelected: !_isGeneralBudget,
                onTap: () {
                  setState(() {
                    _isGeneralBudget = false;
                    if (_selectedCategory == null &&
                        _availableCategories.isNotEmpty) {
                      _selectedCategory = _availableCategories.first;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : isDark
                      ? Colors.white70
                      : Colors.grey[700],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isDark
                        ? Colors.white
                        : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isDark
                        ? Colors.white70
                        : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.budget != null && widget.budget!.category != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر الفئة',
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        if (isEdit)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(widget.budget!.category!.icon,
                    color: widget.budget!.category!.color, size: 24),
                const SizedBox(width: 8),
                Text(widget.budget!.category!.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
        else ...[
          // Search Field
          TextFormField(
            controller: _searchController,
            onChanged: _filterCategories,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'ابحث عن فئة...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor:
                  isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),

          // Categories Grid
          SizedBox(
            height: 200,
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد فئات متاحة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      // final budgetedCategoryIds = appData.budgets
                      //     .where((b) => b.category != null)
                      //     .map((b) => b.category!.id)
                      //     .toSet();
                      final category = _filteredCategories[index];
                      // final isAlreadyBudgeted =
                      //     budgetedCategoryIds.contains(category.id);
                      final isSelected = _selectedCategory?.id == category.id;

                      return GestureDetector(
                        onTap:
                            //  isAlreadyBudgeted ? null :
                            () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category.color.withOpacity(0.2)
                                : isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: category.color,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category.icon,
                                color: category.color,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomDatePickers() {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _customStartDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _customStartDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _customStartDate != null
                    ? 'من: ${_customStartDate!.toLocal().toString().split(' ')[0]}'
                    : 'اختر تاريخ البداية',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _customEndDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _customEndDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _customEndDate != null
                    ? 'إلى: ${_customEndDate!.toLocal().toString().split(' ')[0]}'
                    : 'اختر تاريخ النهاية',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.budget == null ? 'إضافة ميزانية' : 'تعديل الميزانية',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GlassBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Budget Type Toggle
                              _buildBudgetTypeToggle(),
                              const SizedBox(height: 16),

                              // Category Selection (only shown for category-specific budgets)
                              if (!_isGeneralBudget) _buildCategoryField(),
                              const SizedBox(height: 24),

                              // Amount Field
                              GlassCard(
                                padding: const EdgeInsets.all(1),
                                child: TextFormField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'مبلغ الميزانية',
                                    labelStyle:
                                        theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    errorStyle:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.red[300],
                                    ),
                                    prefixIcon:
                                        const Icon(Icons.attach_money_rounded),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty)
                                      return 'أدخل مبلغ الميزانية';
                                    if (double.tryParse(val) == null)
                                      return 'أدخل رقمًا صحيحًا';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Budget Period
                              Text(
                                'الفترة الزمنية',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GlassCard(
                                padding: const EdgeInsets.all(1),
                                child: DropdownButtonFormField<BudgetPeriod>(
                                  value: _selectedPeriod,
                                  decoration: InputDecoration(
                                    labelText: 'فترة الميزانية',
                                    labelStyle:
                                        theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    prefixIcon: const Icon(
                                        Icons.calendar_month_rounded),
                                  ),
                                  items: BudgetPeriod.values.map((period) {
                                    return DropdownMenuItem(
                                      value: period,
                                      child: Text(_getPeriodLabel(period)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val != null) _selectedPeriod = val;
                                    });
                                  },
                                ),
                              ),
                              if (_selectedPeriod == BudgetPeriod.custom)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: _buildCustomDatePickers(),
                                ),
                            ],
                          )),
                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _saveBudget,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                widget.budget == null
                                    ? 'إضافة الميزانية'
                                    : 'حفظ التغييرات',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
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
          ),
        ),
      ),
    );
  }

  String _getPeriodLabel(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'أسبوعي';
      case BudgetPeriod.monthly:
        return 'شهري';
      case BudgetPeriod.yearly:
        return 'سنوي';
      case BudgetPeriod.custom:
        return 'مخصص';
    }
  }
}
