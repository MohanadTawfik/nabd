import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/widgets/glass_card.dart';

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
    } else {
      _selectedPeriod = BudgetPeriod.monthly;
      _receiveNotifications = true;
      _notificationThreshold = 80.0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  void _loadCategories() {
    final appData = Provider.of<AppData>(context, listen: false);
    setState(() {
      _availableCategories.addAll(appData.expenseCategories);
      _filteredCategories = List.from(_availableCategories);

      // Select the category if in edit mode
      if (widget.budget != null) {
        _selectedCategory = _availableCategories.firstWhere(
          (cat) => cat.id == widget.budget!.category.id,
          orElse: () => _availableCategories.first,
        );
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
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
          endDate = now.add(const Duration(days: 30)); // Default 30 days for custom
          break;
      }

      final newBudget = Budget(
        id: widget.budget?.id,
        category: _selectedCategory!,
        totalAmount: amount,
        period: _selectedPeriod,
        startDate: widget.budget?.startDate ?? now,
        endDate: widget.budget?.endDate ?? endDate,
        receiveNotifications: _receiveNotifications,
        notificationThreshold: _notificationThreshold,
        spentAmount: widget.budget?.spentAmount ?? 0.0,
      );

      final appData = Provider.of<AppData>(context, listen: false);
      if (widget.budget != null) {
        appData.updateBudget(newBudget);
      } else {
        appData.addBudget(newBudget);
      }

      Navigator.pop(context);
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = _availableCategories
          .where((category) =>
              category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.budget == null ? 'إضافة ميزانية جديدة' : 'تعديل الميزانية',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Category Selection
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
                height: 150,
                child: _filteredCategories.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد فئات متاحة',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? Colors.white54
                                : AppColors.textSecondary,
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
                          final category = _filteredCategories[index];
                          final isSelected =
                              _selectedCategory?.id == category.id;

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

              const SizedBox(height: 24),

              // Amount Field
              TextFormField(
                controller: _amountController,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'المبلغ الإجمالي',
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(Icons.currency_lira),
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
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
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
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isDark
                              ? Colors.white
                              : AppColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Notification Settings
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'إشعارات الميزانية',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:
                            isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Switch(
                    value: _receiveNotifications,
                    onChanged: (value) {
                      setState(() {
                        _receiveNotifications = value;
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),

              if (_receiveNotifications) ...[
                const SizedBox(height: 16),
                Text(
                  'إشعار عند الوصول إلى %${_notificationThreshold.toInt()} من الميزانية',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                Slider(
                  value: _notificationThreshold,
                  min: 50,
                  max: 100,
                  divisions: 5,
                  label: '${_notificationThreshold.toInt()}%',
                  onChanged: (value) {
                    setState(() {
                      _notificationThreshold = value;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ],

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.budget == null ? 'إضافة الميزانية' : 'حفظ التغييرات',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (widget.budget != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // Delete budget
                      final appData =
                          Provider.of<AppData>(context, listen: false);
                      appData.deleteBudget(widget.budget!);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'حذف الميزانية',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
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
