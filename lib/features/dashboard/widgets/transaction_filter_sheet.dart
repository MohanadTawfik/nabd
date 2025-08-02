import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/widgets/primary_button.dart';

/// A bottom sheet that allows filtering and sorting transactions.
class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({Key? key}) : super(key: key);

  /// Shows the transaction filter sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TransactionFilterSheet(),
    );
  }

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Filter state
  TransactionType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  RangeValues _amountRange = const RangeValues(0, 10000);
  List<Category> _selectedCategories = [];
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();

    // Initialize with default filter values
    _selectedType = null;
    _startDate = null;
    _endDate = null;
    _amountRange = const RangeValues(0, 10000);
    _selectedCategories = [];
    _sortBy = 'date';
    _sortAscending = false;
  }

  @override
  void dispose() {
    // First stop any ongoing animations
    _animationController.stop();
    // Set animation value to 1.0 to prevent any further animations
    _animationController.value = 1.0;
    // Then dispose the controller
    _animationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    // TODO: Implement filter logic using Provider or local state
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _startDate = null;
      _endDate = null;
      _amountRange = const RangeValues(0, 10000);
      _selectedCategories = [];
      _sortBy = 'date';
      _sortAscending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TODO: Replace with Provider-based categories if needed
    final categories = <Category>[];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FractionallySizedBox(
          heightFactor: 0.85 * _animation.value,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تصفية وترتيب',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('إعادة ضبط'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Filter options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Transaction Type Filter
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نوع المعاملة',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTypeFilterChip(
                              'الكل',
                              null,
                              theme,
                            ),
                            const SizedBox(width: 8),
                            _buildTypeFilterChip(
                              'مصروفات',
                              TransactionType.expense,
                              theme,
                            ),
                            const SizedBox(width: 8),
                            _buildTypeFilterChip(
                              'إيرادات',
                              TransactionType.income,
                              theme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Range Filter
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الفترة الزمنية',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _startDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _startDate == null
                                            ? 'من تاريخ'
                                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _endDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _endDate == null
                                            ? 'إلى تاريخ'
                                            : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount Range Filter
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نطاق المبلغ',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RangeSlider(
                          values: _amountRange,
                          min: 0,
                          max: 10000,
                          divisions: 100,
                          labels: RangeLabels(
                            '${_amountRange.start.round()} ريال',
                            '${_amountRange.end.round()} ريال',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _amountRange = values;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_amountRange.start.round()} ريال',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              '${_amountRange.end.round()} ريال',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categories Filter
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الفئات',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categories
                              .map((category) => _buildCategoryChip(category))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sort Options
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ترتيب حسب',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSortOptionChip(
                              'التاريخ',
                              'date',
                              theme,
                            ),
                            const SizedBox(width: 8),
                            _buildSortOptionChip(
                              'المبلغ',
                              'amount',
                              theme,
                            ),
                            const SizedBox(width: 8),
                            _buildSortOptionChip(
                              'الفئة',
                              'category',
                              theme,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSortDirectionChip(
                              'تصاعدي',
                              true,
                              theme,
                            ),
                            const SizedBox(width: 8),
                            _buildSortDirectionChip(
                              'تنازلي',
                              false,
                              theme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Apply button
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                onPressed: _applyFilters,
                text: 'تطبيق',
                icon: Icons.filter_list,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilterChip(
    String label,
    TransactionType? type,
    ThemeData theme,
  ) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildCategoryChip(Category category) {
    final theme = Theme.of(context);
    final isSelected = _selectedCategories.contains(category);
    return FilterChip(
      label: Text(category.name),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.remove(category);
          }
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: category.color.withOpacity(0.2),
      checkmarkColor: category.color,
      avatar: Icon(
        category.icon,
        size: 16,
        color: isSelected ? category.color : theme.colorScheme.onSurface,
      ),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isSelected ? category.color : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSortOptionChip(
    String label,
    String value,
    ThemeData theme,
  ) {
    final isSelected = _sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSortDirectionChip(
    String label,
    bool isAscending,
    ThemeData theme,
  ) {
    final isSelected = _sortAscending == isAscending;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortAscending = isAscending;
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );
  }
}
