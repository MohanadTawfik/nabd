import 'package:flutter/material.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart'; // لاستخدام TransactionType

/// ويدجت يعرض ورقة سفلية (Modal Bottom Sheet) لترتيب الفئات.
///
/// يمكن للمستخدم اختيار حقل الترتيب (مثل الاسم أو النوع)
/// واتجاه الترتيب (تصاعدي أو تنازلي).
class CategoryFilterSheet extends StatefulWidget {
  final String currentSortBy;
  final bool currentSortAscending;

  const CategoryFilterSheet({
    Key? key,
    required this.currentSortBy,
    required this.currentSortAscending,
  }) : super(key: key);

  /// دالة ثابتة لعرض الورقة السفلية وانتظار نتيجة اختيار المستخدم.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String currentSortBy,
    required bool currentSortAscending,
  }) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // لجعل الحواف دائرية
      builder: (context) => CategoryFilterSheet(
        currentSortBy: currentSortBy,
        currentSortAscending: currentSortAscending,
      ),
    );
  }

  @override
  State<CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  late String _sortBy;
  late bool _sortAscending;

  // القيم الافتراضية للترتيب
  final String _defaultSortBy = 'name';
  final bool _defaultSortAscending = true;

  @override
  void initState() {
    super.initState();
    // تهيئة الحالة بالاختيارات الحالية التي تم تمريرها
    _sortBy = widget.currentSortBy;
    _sortAscending = widget.currentSortAscending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // حساب عدد الفلاتر النشطة (غير الافتراضية)
    final activeFiltersCount = (_sortBy != _defaultSortBy ? 1 : 0) +
        (_sortAscending != _defaultSortAscending ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20) +
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط العنوان وزر الإغلاق
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('ترتيب الفئات',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (activeFiltersCount > 0)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
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
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'إغلاق',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // رقائق الاختيار لحقل الترتيب
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSortChip('الاسم', 'name'),
              _buildSortChip('النوع (دخل/مصروف)', 'type'),
            ],
          ),
          const SizedBox(height: 24),
          // اختيار اتجاه الترتيب
          Row(
            children: [
              Icon(Icons.swap_vert,
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text('الاتجاه:', style: theme.textTheme.titleMedium),
              const Spacer(),
              _buildDirectionChip('أبجدي (أ-ي)', true),
              const SizedBox(width: 10),
              _buildDirectionChip('عكسي (ي-أ)', false),
            ],
          ),
          const SizedBox(height: 32),
          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // إرجاع الخيارات المحددة عند الضغط على "تطبيق"
                    Navigator.pop(context, {
                      'sortBy': _sortBy,
                      'sortAscending': _sortAscending,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  child: const Text('تطبيق',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // إعادة تعيين الخيارات إلى الافتراضيات
                    setState(() {
                      _sortBy = _defaultSortBy;
                      _sortAscending = _defaultSortAscending;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor:
                        theme.colorScheme.onSurface.withOpacity(0.8),
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child:
                      const Text('إعادة تعيين', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ويدجت مساعد لبناء رقاقة اختيار حقل الترتيب.
  Widget _buildSortChip(String label, String value) {
    final theme = Theme.of(context);
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _sortBy = value),
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
      side:
          isSelected ? BorderSide.none : BorderSide(color: theme.dividerColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  /// ويدجت مساعد لبناء رقاقة اختيار اتجاه الترتيب.
  Widget _buildDirectionChip(String label, bool isAscending) {
    final theme = Theme.of(context);
    final isSelected = _sortAscending == isAscending;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _sortAscending = isAscending),
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
      side:
          isSelected ? BorderSide.none : BorderSide(color: theme.dividerColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
