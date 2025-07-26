import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/categories/screens/add_edit_category_screen.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/widgets/glass_background.dart';

// The main screen widget, redesigned to match the image
class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  // int _selectedIndex = 1; // Default to 'Category' tab
  bool _isExpenseSelected = true; // Default to 'Incomes'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'إدارة الفئات',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => _navigateToAddCategory(context),
                ),
              ],
            ),

            // Type Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GlassCard(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTypeToggle(
                      context,
                      isSelected: _isExpenseSelected,
                      label: 'المصروفات',
                      onTap: () => setState(() => _isExpenseSelected = true),
                    ),
                    _buildTypeToggle(
                      context,
                      isSelected: !_isExpenseSelected,
                      label: 'الدخل',
                      onTap: () => setState(() => _isExpenseSelected = false),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Consumer<AppData>(
                builder: (context, appData, child) {
                  final categories = _isExpenseSelected
                      ? appData.expenseCategories
                      : appData.incomeCategories;

                  if (categories.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return Consumer<AppData>(
                    builder: (context, appData, _) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          // Count transactions for this category
                          final transactionCount = appData.transactions
                              .where((t) => t.category.id == category.id)
                              .length;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildCategoryCard(
                              context,
                              category,
                              transactionCount,
                              () => _navigateToEditCategory(context, category),
                              () => _showDeleteDialog(context, category),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to add new category screen
  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditCategoryScreen(),
      ),
    );
  }

  // Navigate to edit category screen
  void _navigateToEditCategory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCategoryScreen(categoryToEdit: category),
      ),
    );
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteDialog(
      BuildContext context, Category category) async {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'حذف الفئة',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف فئة "${category.name}"؟',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AppData>(context, listen: false)
                  .deleteCategory(category);
              Navigator.pop(context);
            },
            child: Text(
              'حذف',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build type toggle button
  Widget _buildTypeToggle(
    BuildContext context, {
    required bool isSelected,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isSelected ? theme.colorScheme.primary : theme.hintColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Build empty state widget
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.category_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد فئات متاحة',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'انقر على زر + لإضافة فئة جديدة',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Build category card
  Widget _buildCategoryCard(
    BuildContext context,
    Category category,
    int transactionCount,
    VoidCallback onTap,
    VoidCallback onDelete,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: category.color.withOpacity(0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: transactionCount > 0
                          ? category.color.withOpacity(0.1)
                          : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      transactionCount == 0
                          ? 'لا توجد معاملات'
                          : transactionCount == 1
                              ? 'معاملة واحدة'
                              : transactionCount == 2
                                  ? 'معاملتان'
                                  : '$transactionCount معاملات',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: transactionCount > 0
                            ? category.color
                            : theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error.withOpacity(0.8),
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const AddEditCategoryScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 40,
            color: Color(0xFF718096),
          ),
        ),
      ),
    );
  }
}
