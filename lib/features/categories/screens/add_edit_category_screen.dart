import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
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
  // 1. متغيرات حالة جديدة للأيقونة واللون
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
    _selectedIcon = _isEditing ? widget.categoryToEdit!.icon : _icons.first;
    _selectedColor = _isEditing ? widget.categoryToEdit!.color : _colors.first;
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );

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

      final appData = Provider.of<AppData>(context, listen: false);

      if (_isEditing) {
        appData.updateCategory(newCategory);
      } else {
        appData.addCategory(newCategory);
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
        body: GlassBackground(
          child: SafeArea(
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
                        prefixIcon: Icon(
                          Icons.category_rounded,
                          color: theme.hintColor.withOpacity(0.7),
                        ),
                      ),
                      textAlign: TextAlign.right,
                      validator: (value) => (value == null || value.isEmpty)
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
                          padding:
                              const EdgeInsets.only(right: 4.0, bottom: 8.0),
                          child: Text(
                            'نوع المعاملة',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
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
                                  isSelected: _type == TransactionType.expense,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTypeOption(
                                  context,
                                  type: TransactionType.income,
                                  icon: Icons.arrow_upward_rounded,
                                  label: 'دخل',
                                  isSelected: _type == TransactionType.income,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Icon Selection Section
                  _buildIconSelector(),

                  const SizedBox(height: 24),

                  // Color Selection Section
                  _buildColorSelector(),

                  const SizedBox(height: 32),

                  // Save Button
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _saveCategory,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary
                                    .withBlue(200)
                                    .withGreen(200),
                              ],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _isEditing ? 'تحديث الفئة' : 'إضافة الفئة',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildIconSelector() {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر أيقونة',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _icons.map((icon) {
              final isSelected = _selectedIcon == icon;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              _selectedColor.withOpacity(0.2),
                              _selectedColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              theme.colorScheme.surface.withOpacity(0.3),
                              theme.colorScheme.surface.withOpacity(0.1),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? _selectedColor.withOpacity(0.3)
                          : theme.dividerColor.withOpacity(0.1),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _selectedColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? _selectedColor
                        : theme.iconTheme.color?.withOpacity(0.8),
                    size: 24,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر لوناً',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.onSurface.withOpacity(0.3)
                          : Colors.transparent,
                      width: isSelected ? 2.5 : 0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 3),
                        spreadRadius: isSelected ? 2 : 0,
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
            }).toList(),
          ),
        ],
      ),
    );
  }
}
