import 'package:flutter/material.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:provider/provider.dart';
import 'package:nabd/data/app_data.dart';
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
    final appData = Provider.of<AppData>(context, listen: false);
    setState(() {
      _availableCategories.addAll(appData.expenseCategories);
      _filteredCategories = List.from(_availableCategories);

      // Select the category if in edit mode
      if (widget.budget != null) {
        _isGeneralBudget = widget.budget!.category == null;
        if (!_isGeneralBudget) {
          _selectedCategory = _availableCategories.firstWhere(
            (cat) => cat.id == widget.budget!.category?.id,
            orElse: () => _availableCategories.first,
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

  Budget _createBudget() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final now = DateTime.now();

    // Calculate end date based on selected period
    DateTime endDate;
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
        endDate =
            now.add(const Duration(days: 30)); // Default 30 days for custom
        break;
    }

    return Budget(
      id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: _isGeneralBudget ? null : _selectedCategory,
      totalAmount: amount,
      startDate: widget.budget?.startDate ?? now,
      endDate: widget.budget?.endDate ?? endDate,
      period: _selectedPeriod,
      receiveNotifications: _receiveNotifications,
      notificationThreshold: _notificationThreshold,
      spentAmount: widget.budget?.spentAmount ?? 0.0,
    );
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate category selection for category-specific budgets
    if (!_isGeneralBudget && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار فئة للميزانية'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newBudget = _createBudget();
    final appData = Provider.of<AppData>(context, listen: false);

    // Check for existing budget for this category (only for new budgets or when category changes)
    if (widget.budget == null ||
        (widget.budget!.category?.id != newBudget.category?.id)) {
      final existingBudget = appData.budgets.firstWhere(
        (b) => b.category?.id == newBudget.category?.id,
        orElse: () => Budget(
          id: '',
          category: null,
          totalAmount: 0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
      );

      if (existingBudget.id.isNotEmpty) {
        // A budget already exists for this category
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'يوجد ميزانية مسبقة لـ ${newBudget.category?.name ?? 'هذه الفئة'}. الرجاء تعديل الميزانية الحالية.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    // Save the budget
    if (widget.budget != null) {
      appData.updateBudget(newBudget);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الميزانية بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      appData.addBudget(newBudget);
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
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    final isSelected = _selectedCategory?.id == category.id;

                    return GestureDetector(
                      onTap: () {
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
                              TextFormField(
                                controller: _amountController,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'المبلغ الإجمالي',
                                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                  ),
                                  prefixIcon: const Icon(Icons.currency_yen),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال المبلغ';
                                  }
                                  final amount = double.tryParse(value);
                                  if (amount == null || amount <= 0) {
                                    return 'الرجاء إدخال مبلغ صحيح';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

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
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: BudgetPeriod.values.map((period) {
                                  final isSelected = _selectedPeriod == period;
                                  final label = _getPeriodLabel(period);

                                  return ChoiceChip(
                                    label: Text(label),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedPeriod = period;
                                      });
                                    },
                                    backgroundColor: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.grey[200],
                                    selectedColor: theme.colorScheme.primary
                                        .withOpacity(0.2),
                                    labelStyle:
                                        AppTextStyles.bodyMedium.copyWith(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : isDark
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                      ),
                                    ),
                                  );
                                }).toList(),
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
