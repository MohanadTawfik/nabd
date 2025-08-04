import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/categories/screens/add_edit_category_screen.dart';
// Import with prefix to resolve TransactionType name conflict
import 'package:nabd/features/categories/categories_provider.dart'
    as categories;
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/empty_state.dart';
import 'package:nabd/widgets/modern_app_bar.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/categories/widgets/category_filter_sheet.dart';

// The main screen widget, redesigned to match the image
class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  // int _selectedIndex = 1; // Default to 'Category' tab
  bool _isExpenseSelected = true; // Default to 'Incomes'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Category> _filterCategories(List<Category> categories) {
    if (_searchQuery.isEmpty) return categories;

    final query = _searchQuery.toLowerCase();
    return categories.where((category) {
      return category.name.toLowerCase().contains(query);
    }).toList();
  }

  List<Category> _sortCategories(List<Category> categories) {
    switch (_sortBy) {
      case 'name':
        categories.sort((a, b) => _sortAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 'type':
        categories.sort((a, b) => _sortAscending
            ? a.type.index.compareTo(b.type.index)
            : b.type.index.compareTo(a.type.index));
        break;
    }
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoriesProvider = Provider.of<categories.CategoriesProvider>(context);
    
    // Show loading indicator if data is still loading
    if (!categoriesProvider.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Show error message if there was an error loading categories
    if (categoriesProvider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text('Error loading categories: ${categoriesProvider.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: categoriesProvider.loadCategories,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

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
                  icon: Icon(Icons.filter_list_rounded,
                      color: theme.colorScheme.onSurface),
                  tooltip: 'تصفية وترتيب',
                  onPressed: () async {
                    final result = await CategoryFilterSheet.show(
                      context,
                      currentSortBy: _sortBy,
                      currentSortAscending: _sortAscending,
                    );
                    if (result != null) {
                      setState(() {
                        _sortBy = result['sortBy'] as String;
                        _sortAscending = result['sortAscending'] as bool;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
                  tooltip: 'إضافة فئة',
                  onPressed: () => _navigateToAddCategory(context),
                ),
              ],
            ),

            // Search Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: TextField(
                controller: _searchController,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.textDark : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن فئة...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.subtextDark
                        : AppColors.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? AppColors.iconDark : AppColors.iconLight,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Type Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              child: Consumer<categories.CategoriesProvider>(
                builder: (context, categoriesProvider, child) {
                  List<Category> categoriesList = categoriesProvider.categories
                      .where((cat) => _isExpenseSelected
                          ? cat.type == TransactionType.expense
                          : cat.type == TransactionType.income)
                      .toList();
                  categoriesList = _filterCategories(categoriesList);
                  categoriesList = _sortCategories(categoriesList);

                  if (categoriesList.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: categoriesList.length,
                    itemBuilder: (context, index) {
                      final category = categoriesList[index];
                      // Transaction count is not available here; set to 0 or implement if needed
                      final transactionCount = 0;
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
              Provider.of<categories.CategoriesProvider>(context, listen: false)
                  .deleteCategory(category.id);
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
    return const EmptyState(
      icon: Icons.category_outlined,
      title: 'لا توجد فئات متاحة',
      message: 'انقر على زر + لإضافة فئة جديدة',
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
}
