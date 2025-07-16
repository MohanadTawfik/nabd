import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:provider/provider.dart';

class FilterTransactionsScreen extends StatefulWidget {
  const FilterTransactionsScreen({super.key});

  @override
  State<FilterTransactionsScreen> createState() =>
      _FilterTransactionsScreenState();
}

class _FilterTransactionsScreenState extends State<FilterTransactionsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final List<Category> _selectedCategories = [];

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context, listen: false);
    final allCategories = [
      ...appData.expenseCategories,
      ...appData.incomeCategories
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث وتصفية'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // اختيار التاريخ
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('نطاق التاريخ'),
            subtitle: Text(_startDate == null
                ? 'لم يتم التحديد'
                : '${DateFormat.yMMMd('ar').format(_startDate!)} - ${DateFormat.yMMMd('ar').format(_endDate!)}'),
            onTap: () => _selectDateRange(context),
          ),
          const Divider(),
          // اختيار الفئات
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('الفئات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Wrap(
            spacing: 8.0,
            children: allCategories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(category.name),
                avatar: Icon(category.icon,
                    color: isSelected ? Colors.white : category.color,
                    size: 18),
                selected: isSelected,
                selectedColor: category.color,
                checkmarkColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            appData.filterTransactions(
              startDate: _startDate,
              endDate: _endDate,
              categories: _selectedCategories,
            );
            Navigator.pop(context);
          },
          child: const Text('تطبيق الفلتر'),
        ),
      ),
    );
  }
}
