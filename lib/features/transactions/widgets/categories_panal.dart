import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/widgets/glass_card.dart';

class CategoriesPanal extends StatelessWidget {
  const CategoriesPanal({
    super.key,
    required this.widget,
    required this.context,
    required this.category,
  });

  final CategorySelectorBottomSheet widget;
  final BuildContext context;
  final Category category;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selectedCategory?.id == category.id;
    final theme = Theme.of(context);
    //final isDark = theme.brightness == Brightness.dark; // Not used here

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(2),
      child: Material(
        color:
            isSelected ? category.color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.pop(context, category),
          borderRadius: BorderRadius.circular(16),
          splashColor: category.color.withOpacity(0.3),
          highlightColor: category.color.withOpacity(0.15),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color.withOpacity(0.15)
                        : category.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: category.color.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color, // لون الأيقونة مباشرة بلون الفئة
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: isSelected
                        ? category.color // النص بلون الفئة إذا كانت مختارة
                        : theme.colorScheme.onSurface
                            .withOpacity(0.8), // لون نص واضح للغير مختار
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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
}

class CategorySelectorBottomSheet extends StatefulWidget {
  final List<Category> allCategories;
  final Category? selectedCategory;
  final TransactionType selectedType;
  final Function(TransactionType) onTypeChanged;

  CategorySelectorBottomSheet({
    required this.allCategories,
    this.selectedCategory,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  State<CategorySelectorBottomSheet> createState() =>
      CategorySelectorBottomSheetState();
}

class CategorySelectorBottomSheetState
    extends State<CategorySelectorBottomSheet> {
  late final TextEditingController _searchController;
  late final ValueNotifier<List<Category>> _filteredCategories;
  late final FocusNode _focusNode;
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedType = widget.selectedType;
    _focusNode = FocusNode();

    // Initialize filtered categories with the selected type
    _filteredCategories = ValueNotifier<List<Category>>(
      widget.allCategories.where((c) => c.type == _selectedType).toList(),
    );

    // Listen to search controller changes
    _searchController.addListener(() {
      _filterCategories();
    });

    // Request focus after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(CategorySelectorBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the selected type if it changed from the parent
    if (widget.selectedType != _selectedType) {
      _selectedType = widget.selectedType;
      _filterCategories();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredCategories.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();

    // Filter categories based on type and search query
    final filtered = widget.allCategories.where((category) {
      final matchesType = category.type == _selectedType;
      final matchesSearch =
          query.isEmpty || category.name.toLowerCase().contains(query);
      return matchesType && matchesSearch;
    }).toList();

    // Update the ValueNotifier with the filtered list
    if (!_listsEqual(_filteredCategories.value, filtered)) {
      _filteredCategories.value = filtered;
    }
  }

  // Helper method to compare lists for equality
  bool _listsEqual(List<Category> a, List<Category> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _handleTypeChange(TransactionType type) {
    if (_selectedType != type) {
      setState(() {
        _selectedType = type;
      });

      // Update the filtered categories
      _filterCategories();

      // Notify parent after local state is updated
      if (widget.onTypeChanged != null) {
        widget.onTypeChanged(type);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            padding:
                const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark.withOpacity(0.9)
                  : AppColors.cardLight.withOpacity(0.9),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Type toggle
                Container(
                  margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTypeToggleButton(
                            type: TransactionType.expense,
                            label: 'مصروف',
                            icon: Icons.arrow_upward,
                            isSelected:
                                _selectedType == TransactionType.expense,
                            onTap: () =>
                                _handleTypeChange(TransactionType.expense),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTypeToggleButton(
                            type: TransactionType.income,
                            label: 'دخل',
                            icon: Icons.arrow_downward,
                            isSelected: _selectedType == TransactionType.income,
                            onTap: () =>
                                _handleTypeChange(TransactionType.income),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Header with title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: theme.colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    Text(
                      'اختر الفئة',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 8),

                // Search bar
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: theme.hintColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: (value) {
                            _filterCategories();
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'ابحث عن فئة...',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor.withOpacity(0.7),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: theme.hintColor,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterCategories();
                            setState(() {});
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<Category>>(
                    valueListenable: _filteredCategories,
                    builder: (context, categories, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: categories.isEmpty
                            ? Center(
                                key: const ValueKey('no_categories_found'),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 48,
                                        color: theme.hintColor.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'لا توجد فئات تطابق البحث',
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: theme.hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                key: const ValueKey('categories_grid'),
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
                                  return CategoriesPanal(
                                      widget: widget,
                                      context: context,
                                      category: category);
                                },
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement add new category
                    Navigator.pop(context); // إغلاق bottom sheet مؤقتاً
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'ميزة إضافة فئة جديدة قيد التطوير!',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.warningColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    'إضافة فئة جديدة',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggleButton({
    required TransactionType type,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = type == TransactionType.expense
        ? AppColors.expenseColor
        : AppColors.incomeColor;
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? color : theme.hintColor.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? color : theme.hintColor.withOpacity(0.8),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
