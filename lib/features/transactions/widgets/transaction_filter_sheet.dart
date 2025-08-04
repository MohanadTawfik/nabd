import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/categories/categories_provider.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/primary_button.dart';
import 'package:provider/provider.dart';

/// ويدجت يعرض ورقة سفلية شاملة لتصفية وترتيب المعاملات.
class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({Key? key}) : super(key: key);

  /// يعرض الورقة السفلية وينتظر نتيجة اختيار المستخدم.
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TransactionFilterSheet(),
    );
  }

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  // الحالة المحلية لجميع خيارات التصفية والترتيب
  TransactionType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  RangeValues _amountRange = const RangeValues(0, 50000);
  List<Category> _selectedCategories = [];
  String _sortBy = 'date';
  bool _sortAscending = false;

  // القيم الافتراضية لإعادة التعيين
  final _defaultFilters = {
    'type': null,
    'startDate': null,
    'endDate': null,
    'amountRange': const RangeValues(0, 50000),
    'categories': <Category>[],
    'sortBy': 'date',
    'sortAscending': false,
  };

  /// تطبيق الفلاتر وإغلاق الورقة مع إرجاع البيانات
  void _applyFilters() {
    final filters = {
      'type': _selectedType,
      'startDate': _startDate,
      'endDate': _endDate,
      'amountRange': _amountRange,
      'categories': _selectedCategories,
      'sortBy': _sortBy,
      'sortAscending': _sortAscending,
    };
    Navigator.pop(context, filters);
  }

  /// إعادة تعيين جميع الفلاتر إلى حالتها الافتراضية
  void _resetFilters() {
    setState(() {
      _selectedType = _defaultFilters['type'] as TransactionType?;
      _startDate = _defaultFilters['startDate'] as DateTime?;
      _endDate = _defaultFilters['endDate'] as DateTime?;
      _amountRange = _defaultFilters['amountRange'] as RangeValues;
      _selectedCategories =
          List<Category>.from(_defaultFilters['categories'] as List);
      _sortBy = _defaultFilters['sortBy'] as String;
      _sortAscending = _defaultFilters['sortAscending'] as bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeFiltersCount = _calculateActiveFilters();

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Scaffold(
          backgroundColor: theme.cardColor,
          body: Column(
            children: [
              _buildHeader(theme, activeFiltersCount),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildSectionTitle('نوع المعاملة', theme),
                    _buildTypeFilter(),
                    const SizedBox(height: 16),
                    _buildSectionTitle('الفترة الزمنية', theme),
                    _buildDateFilter(theme),
                    const SizedBox(height: 16),
                    _buildSectionTitle('نطاق المبلغ', theme),
                    _buildAmountFilter(theme),
                    const SizedBox(height: 16),
                    _buildSectionTitle('الفئات', theme),
                    _buildCategoriesFilter(context),
                    const SizedBox(height: 16),
                    _buildSectionTitle('ترتيب حسب', theme),
                    _buildSortFilter(theme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildFooter(theme),
        ),
      ),
    );
  }

  /// حساب عدد الفلاتر النشطة
  int _calculateActiveFilters() {
    int count = 0;
    if (_selectedType != _defaultFilters['type']) count++;
    if (_startDate != _defaultFilters['startDate'] ||
        _endDate != _defaultFilters['endDate']) count++;
    if (_amountRange != _defaultFilters['amountRange']) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_sortBy != _defaultFilters['sortBy'] ||
        _sortAscending != _defaultFilters['sortAscending']) count++;
    return count;
  }

  /// بناء رأس الورقة
  Widget _buildHeader(ThemeData theme, int activeFiltersCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('تصفية وترتيب',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (activeFiltersCount > 0)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$activeFiltersCount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          TextButton.icon(
            onPressed: _resetFilters,
            icon: Icon(Icons.refresh,
                size: 18, color: theme.colorScheme.secondary),
            label: Text('إعادة تعيين',
                style: TextStyle(color: theme.colorScheme.secondary)),
          ),
        ],
      ),
    );
  }

  /// بناء تذييل الورقة (زر التطبيق)
  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16)
          .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5)),
        ],
      ),
      child: PrimaryButton(
        onPressed: _applyFilters,
        text: 'تطبيق الفلاتر',
        icon: Icons.check_circle_outline,
      ),
    );
  }

  /// بناء عنوان القسم
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: theme.textTheme.titleMedium),
    );
  }

  /// بناء قسم فلتر النوع
  Widget _buildTypeFilter() {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip('الكل', _selectedType == null,
            () => setState(() => _selectedType = null)),
        _buildFilterChip('مصروفات', _selectedType == TransactionType.expense,
            () => setState(() => _selectedType = TransactionType.expense)),
        _buildFilterChip('إيرادات', _selectedType == TransactionType.income,
            () => setState(() => _selectedType = TransactionType.income)),
      ],
    );
  }

  /// بناء قسم فلتر التاريخ
  Widget _buildDateFilter(ThemeData theme) {
    return Row(
      children: [
        Expanded(
            child: _buildDatePickerField('من تاريخ', _startDate,
                (date) => setState(() => _startDate = date), theme)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildDatePickerField('إلى تاريخ', _endDate,
                (date) => setState(() => _endDate = date), theme)),
      ],
    );
  }

  /// بناء حقل اختيار التاريخ
  Widget _buildDatePickerField(String hint, DateTime? value,
      Function(DateTime) onSelect, ThemeData theme) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onSelect(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value == null ? hint : DateFormat('yyyy/MM/dd').format(value),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: value == null
                    ? theme.hintColor
                    : theme.colorScheme.onSurface,
              ),
            ),
            Icon(Icons.calendar_today,
                size: 16, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  /// بناء قسم فلتر المبلغ
  Widget _buildAmountFilter(ThemeData theme) {
    return Column(
      children: [
        RangeSlider(
          values: _amountRange,
          min: 0,
          max: 50000,
          divisions: 100,
          labels: RangeLabels(
            '${_amountRange.start.round()} ﷼',
            '${_amountRange.end.round()} ﷼',
          ),
          onChanged: (values) => setState(() => _amountRange = values),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_amountRange.start.round()} ﷼',
                style: theme.textTheme.bodySmall),
            Text('${_amountRange.end.round()} ﷼',
                style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  /// بناء قسم فلتر الفئات
  Widget _buildCategoriesFilter(BuildContext context) {
    final categories =
        Provider.of<CategoriesProvider>(context, listen: false).categories;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return _buildFilterChip(
          category.name,
          isSelected,
          () {
            setState(() {
              if (isSelected) {
                _selectedCategories.remove(category);
              } else {
                _selectedCategories.add(category);
              }
            });
          },
          avatar: Icon(category.icon,
              size: 16,
              color: isSelected
                  ? category.color
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          selectedColor: category.color.withOpacity(0.2),
          selectedTextColor: category.color,
        );
      }).toList(),
    );
  }

  /// بناء قسم الترتيب
  Widget _buildSortFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('التاريخ', _sortBy == 'date',
                () => setState(() => _sortBy = 'date')),
            _buildFilterChip('المبلغ', _sortBy == 'amount',
                () => setState(() => _sortBy = 'amount')),
            _buildFilterChip('الفئة', _sortBy == 'category',
                () => setState(() => _sortBy = 'category')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildFilterChip('تصاعدي', _sortAscending,
                () => setState(() => _sortAscending = true)),
            const SizedBox(width: 8),
            _buildFilterChip('تنازلي', !_sortAscending,
                () => setState(() => _sortAscending = false)),
          ],
        ),
      ],
    );
  }

  /// ويدجت مساعد لبناء رقاقة فلترة قابلة لإعادة الاستخدام
  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onSelected, {
    Widget? avatar,
    Color? selectedColor,
    Color? selectedTextColor,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      avatar: avatar,
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isSelected
            ? (selectedTextColor ?? theme.colorScheme.primary)
            : theme.colorScheme.onSurface.withOpacity(0.8),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side:
          isSelected ? BorderSide.none : BorderSide(color: theme.dividerColor),
      selectedColor:
          selectedColor ?? theme.colorScheme.primary.withOpacity(0.15),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
