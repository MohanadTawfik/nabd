import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/categories/screens/add_edit_category_screen.dart';
import 'package:provider/provider.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // لدينا قسمين: مصروفات ودخل
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الفئات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddEditCategoryScreen()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المصروفات'),
              Tab(text: 'الدخل'),
            ],
          ),
        ),
        body: Consumer<AppData>(
          builder: (context, appData, child) {
            return TabBarView(
              children: [
                _buildCategoryList(context, appData.expenseCategories),
                _buildCategoryList(context, appData.incomeCategories),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, List<Category> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: Icon(category.icon, color: category.color),
          title: Text(category.name),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddEditCategoryScreen(categoryToEdit: category)),
            );
          },
        );
      },
    );
  }
}
