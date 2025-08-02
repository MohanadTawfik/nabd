import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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
    _name = _isEditing ? widget.categoryToEdit!.name : '';
    _type = _isEditing ? widget.categoryToEdit!.type : TransactionType.expense;
    _selectedIcon =
        _isEditing ? widget.categoryToEdit!.icon : Icons.category_outlined;
    _selectedColor = _isEditing ? widget.categoryToEdit!.color : Colors.blue;
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
        id: widget.categoryToEdit?.id ?? const Uuid().v4(),
        name: _name,
        type: _type,
        icon: _selectedIcon, // Directly use the IconData
        color: _selectedColor, // Directly use the Color
      );

      final categoriesProvider =
          Provider.of<CategoriesProvider>(context, listen: false);

      if (_isEditing) {
        await categoriesProvider.updateCategory(newCategory);
      } else {
        await categoriesProvider.addCategory(newCategory);
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
}
