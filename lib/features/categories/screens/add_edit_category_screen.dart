import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:nabd/features/budgets/budgets_provider.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/categories/categories_provider.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/utils/ui_utils.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/widgets/glass_background.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? categoryToEdit;
  const AddEditCategoryScreen({super.key, this.categoryToEdit});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditing;
  late String _name;
  late TransactionType _type;
  late IconData _selectedIcon;
  late Color _selectedColor;
  List<Budget> _budgets = [];
  bool _loadingBudgets = false;

  // Budget add/edit form
  double? _newBudgetAmount;
  BudgetPeriod _newBudgetPeriod = BudgetPeriod.monthly;
  bool _newBudgetReceiveNotifications = true;
  double _newBudgetNotificationThreshold = 80.0;
  Budget? _editingBudget;

  // Available icons for categories
  final List<IconData> _icons = [
    Icons.fastfood,
    Icons.shopping_bag,
    Icons.directions_bus,
    Icons.receipt_long,
    Icons.movie,
    Icons.school,
    Icons.home,
    Icons.health_and_safety,
    Icons.wallet,
    Icons.card_giftcard,
    Icons.work,
    Icons.savings,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.local_gas_station,
    Icons.phone_android,
    Icons.sports_esports,
    Icons.fitness_center,
    Icons.airplanemode_active,
    Icons.local_taxi,
    Icons.credit_card,
    Icons.account_balance,
  ];

  // Available colors for categories
  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.brown,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.categoryToEdit != null;
    _name = widget.categoryToEdit?.name ?? '';
    _type = widget.categoryToEdit?.type ?? TransactionType.expense;
    _selectedIcon = widget.categoryToEdit?.icon ?? Icons.category;
    _selectedColor = widget.categoryToEdit?.color ?? Colors.blue;

    // ميزانية الفئة
    if (_isEditing) {
      _loadBudgetsForCategory();
    }
  }

  Future<void> _loadBudgetsForCategory() async {
    setState(() => _loadingBudgets = true);
    try {
      final provider = context.read<BudgetsProvider>();
      await provider.loadBudgets();
      final all = provider.budgets
          .where((b) => b.categoryId == widget.categoryToEdit!.id)
          .toList();
      setState(() => _budgets = all);
    } finally {
      setState(() => _loadingBudgets = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // Show loading indicator
    UiUtils.showLoadingDialog(context);

    try {
      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 300));

      final newCategory = Category(
        id: _isEditing ? widget.categoryToEdit!.id : const Uuid().v4(),
        name: _name,
        type: _type,
        icon: _selectedIcon,
        color: _selectedColor,
      );

      final categoriesProvider =
          Provider.of<CategoriesProvider>(context, listen: false);
      final budgetsProvider =
          Provider.of<BudgetsProvider>(context, listen: false);

      // Save or update the category
      if (_isEditing) {
        await categoriesProvider.updateCategory(newCategory);
      } else {
        await categoriesProvider.addCategory(newCategory);
      }

      // حفظ الميزانيات الجديدة أو المعدلة
      if (_budgets.isNotEmpty) {
        for (final b in _budgets) {
          if (b.id.isEmpty) {
            await budgetsProvider
                .addBudget(b.copyWith(categoryId: newCategory.id));
          } else {
            await budgetsProvider
                .updateBudget(b.copyWith(categoryId: newCategory.id));
          }
        }
      }

      // Close loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (!mounted) return;

      final snackBar = SnackBar(
        content: Text(
          _isEditing ? 'تم تحديث الفئة بنجاح' : 'تمت إضافة الفئة بنجاح',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Close the screen after a short delay
      if (mounted) {
        Navigator.of(context).pop(true); // Pass true to indicate success
      }
    } catch (e) {
      // Close loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (!mounted) return;

      final snackBar = SnackBar(
        content: Text(
          'حدث خطأ: ${e.toString()}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required TransactionType type,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.hintColor.withOpacity(0.7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _type = type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.dividerColor.withOpacity(0.1),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'تعديل الفئة' : 'إضافة فئة جديدة',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background with glass effect
          const GlassBackground(
            child: SizedBox.expand(),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20.0),
                      children: [
                        const SizedBox(height: 16),

                        // Category Name Field
                        GlassCard(
                          padding: const EdgeInsets.all(1),
                          child: TextFormField(
                            initialValue: _name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'اسم الفئة',
                              labelStyle: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.hintColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              errorStyle: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red[300],
                              ),
                              prefixIcon: GestureDetector(
                                onTap: _showIconAndColorSelector,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _selectedColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _selectedColor.withOpacity(0.2),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _selectedIcon,
                                    color: _selectedColor,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            textAlign: TextAlign.right,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'الرجاء إدخال اسم الفئة'
                                    : null,
                            onSaved: (value) => _name = value!,
                          ),
                        ),

                        if (!_isEditing) ...[
                          const SizedBox(height: 20),
                          // Transaction Type Selector
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 4.0, bottom: 8.0),
                                child: Text(
                                  'نوع المعاملة',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              GlassCard(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildTypeOption(
                                        context,
                                        type: TransactionType.expense,
                                        icon: Icons.arrow_downward_rounded,
                                        label: 'مصروف',
                                        isSelected:
                                            _type == TransactionType.expense,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildTypeOption(
                                        context,
                                        type: TransactionType.income,
                                        icon: Icons.arrow_upward_rounded,
                                        label: 'دخل',
                                        isSelected:
                                            _type == TransactionType.income,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        // إدارة الميزانيات المتعددة للفئة
                        if (_type == TransactionType.expense) ...[
                          const SizedBox(height: 24),
                          GlassCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet_rounded,
                                        color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text('ميزانيات الفئة',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Divider(
                                    height: 24,
                                    thickness: 1,
                                    color: Colors.white12),
                                if (_loadingBudgets)
                                  const Center(
                                      child: CircularProgressIndicator()),
                                if (!_loadingBudgets) ...[
                                  // قائمة الميزانيات الحالية
                                  ..._budgets.map((b) => Card(
                                        color: b.displayColor.withOpacity(0.08),
                                        child: ListTile(
                                          leading: Icon(Icons.wallet,
                                              color: b.displayColor),
                                          title: Text(
                                              '${b.totalAmount.toStringAsFixed(0)} - ${_periodText(b.period)}'),
                                          subtitle: Text(
                                              'من ${b.startDate.toString().substring(0, 10)} إلى ${b.endDate.toString().substring(0, 10)}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.blue),
                                                onPressed: () =>
                                                    _showBudgetDialog(edit: b),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () async {
                                                  setState(
                                                      () => _budgets.remove(b));
                                                  if (b.id.isNotEmpty) {
                                                    await context
                                                        .read<BudgetsProvider>()
                                                        .deleteBudget(b.id);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                  // زر إضافة ميزانية جديدة
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.add),
                                      label: const Text('إضافة ميزانية جديدة'),
                                      onPressed: () => _showBudgetDialog(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Save Button (fixed at bottom - outside of the scrollable area)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _isEditing ? 'حفظ التعديلات' : 'حفظ',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showIconAndColorSelector() async {
    final theme = Theme.of(context);

    // Local state for the dialog
    IconData selectedIcon = _selectedIcon;
    Color selectedColor = _selectedColor;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'اختر أيقونة ولونًا',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selected Icon Preview
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: selectedColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        selectedIcon,
                        size: 40,
                        color: selectedColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Icons Grid
                  Text(
                    'الأيقونات',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: _icons.length,
                      itemBuilder: (context, index) {
                        final icon = _icons[index];
                        final isSelected = icon == selectedIcon;
                        return _buildIconItem(icon, isSelected, () {
                          setState(() {
                            selectedIcon = icon;
                          });
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Colors Grid
                  Text(
                    'الألوان',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colors.length,
                      itemBuilder: (context, index) {
                        final color = _colors[index];
                        final isSelected = color.value == selectedColor.value;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.onSurface
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      color: color.computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white,
                                      size: 20,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'icon': selectedIcon,
                              'color': selectedColor,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('تأكيد'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedIcon = result['icon'] as IconData;
        _selectedColor = result['color'] as Color;
      });
    }
  }

  Widget _buildIconItem(IconData icon, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : Colors.transparent,
              width: isSelected ? 1.5 : 0,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.8),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  // أضف دالة مساعدة للنص العربي لفترة الميزانية
  // نافذة إضافة/تعديل ميزانية
  Future<void> _showBudgetDialog({Budget? edit}) async {
    final theme = Theme.of(context);
    final isEdit = edit != null;
    final amountController =
        TextEditingController(text: isEdit ? edit.totalAmount.toString() : '');
    BudgetPeriod period = isEdit ? edit.period : BudgetPeriod.monthly;
    bool receiveNotifications = isEdit ? edit.receiveNotifications : true;
    double notificationThreshold = isEdit ? edit.notificationThreshold : 80.0;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEdit ? 'تعديل الميزانية' : 'إضافة ميزانية'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'مبلغ الميزانية'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<BudgetPeriod>(
                  value: period,
                  items: BudgetPeriod.values
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(_periodText(p)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) period = val;
                  },
                  decoration:
                      const InputDecoration(labelText: 'فترة الميزانية'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: receiveNotifications,
                  onChanged: (val) => receiveNotifications = val,
                  title: const Text('تفعيل تنبيهات تجاوز الميزانية'),
                  secondary: const Icon(Icons.notifications_active_rounded),
                ),
                if (receiveNotifications) ...[
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: notificationThreshold,
                          min: 10,
                          max: 100,
                          divisions: 9,
                          label: '${notificationThreshold.toInt()}%',
                          onChanged: (val) => notificationThreshold = val,
                        ),
                      ),
                      Text('${notificationThreshold.toInt()}%',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) return;
                setState(() {
                  if (isEdit) {
                    final idx = _budgets.indexOf(edit);
                    _budgets[idx] = edit.copyWith(
                      totalAmount: amount,
                      period: period,
                      receiveNotifications: receiveNotifications,
                      notificationThreshold: notificationThreshold,
                    );
                  } else {
                    // لا تسمح بتكرار نفس الفترة
                    if (_budgets.any((b) => b.period == period)) return;
                    _budgets.add(Budget(
                      id: '',
                      categoryId: widget.categoryToEdit?.id ?? '',
                      totalAmount: amount,
                      period: period,
                      receiveNotifications: receiveNotifications,
                      notificationThreshold: notificationThreshold,
                    ));
                  }
                });
                Navigator.pop(ctx);
              },
              child: Text(isEdit ? 'حفظ' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  String _periodText(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'أسبوعية';
      case BudgetPeriod.monthly:
        return 'شهرية';
      case BudgetPeriod.yearly:
        return 'سنوية';
      case BudgetPeriod.custom:
        return 'مخصصة';
    }
  }
}
