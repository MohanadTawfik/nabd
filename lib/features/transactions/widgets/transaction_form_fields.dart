import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:nabd/data/app_data.dart';
import 'package:intl/intl.dart';

class TransactionFormFields extends StatefulWidget {
  final TransactionType selectedType;
  final Category? selectedCategory;
  final double? amount;
  final DateTime? selectedDate;
  final String? notes;
  final Function(TransactionType) onTypeChanged;
  final Function(Category?) onCategoryChanged;
  final Function(double) onAmountChanged;
  final Function(DateTime) onDateChanged;
  final Function(String) onNotesChanged;

  const TransactionFormFields({
    Key? key,
    required this.selectedType,
    required this.selectedCategory,
    required this.amount,
    required this.selectedDate,
    required this.notes,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onAmountChanged,
    required this.onDateChanged,
    required this.onNotesChanged,
  }) : super(key: key);

  @override
  State<TransactionFormFields> createState() => _TransactionFormFieldsState();
}

class _TransactionFormFieldsState extends State<TransactionFormFields> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
        text: widget.amount != null ? widget.amount.toString() : '');
    _notesController = TextEditingController(text: widget.notes ?? '');
  }

  @override
  void didUpdateWidget(TransactionFormFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amount != null &&
        widget.amount != double.tryParse(_amountController.text)) {
      _amountController.text = widget.amount.toString();
    }
    if (widget.notes != null && widget.notes != _notesController.text) {
      _notesController.text = widget.notes!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final categories = widget.selectedType == TransactionType.expense
        ? appData.expenseCategories
        : appData.incomeCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Large, centered amount input with currency
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      final value = double.tryParse(val.replaceAll(',', '')) ?? 0.0;
                      widget.onAmountChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '﷼',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        // 2. Modern glassmorphic type selector
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.55),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeChip(context, 'مصروف', TransactionType.expense),
              const SizedBox(width: 10),
              _buildTypeChip(context, 'دخل', TransactionType.income),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // 3. Category grid with icons
        Text(
          'الفئة',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final cat = categories[i];
            final isSelected = widget.selectedCategory?.id == cat.id;
            return GestureDetector(
              onTap: () => widget.onCategoryChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cat.color.withOpacity(0.85)
                      : Theme.of(context).colorScheme.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(18),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.5,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cat.color.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat.icon, color: isSelected ? Colors.white : cat.color, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        const SizedBox(height: 24),
        // 4. Date picker
        Text(
          'التاريخ',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: widget.selectedDate ?? now,
              firstDate: DateTime(now.year - 2),
              lastDate: DateTime(now.year + 2),
              locale: const Locale('ar'),
            );
            if (picked != null) {
              widget.onDateChanged(picked);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 22),
                const SizedBox(width: 10),
                Text(
                  widget.selectedDate != null
                      ? DateFormat.yMMMMd('ar').format(widget.selectedDate!)
                      : 'اختر التاريخ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // 5. Modern notes field
        Text(
          'ملاحظات',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 2,
          minLines: 1,
          decoration: InputDecoration(
            hintText: 'أضف ملاحظات إضافية (اختياري)',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
          onChanged: widget.onNotesChanged,
        ),
      ],
    );
  }

  Widget _buildTypeChip(
      BuildContext context, String label, TransactionType type) {
    final isSelected = widget.selectedType == type;
    final color = type == TransactionType.expense
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.secondary;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => widget.onTypeChanged(type),
      selectedColor: color,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
