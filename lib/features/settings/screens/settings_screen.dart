import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/categories/screens/manage_categories_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // 1. نستخدم Provider.of للوصول إلى AppData
    final appData = Provider.of<AppData>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ProfileHeader(
              name: 'مهند',
              email: 'mohanad@nabd.app',
            ),
            const SizedBox(height: 24),
            SettingsSection(
              title: 'الحساب',
              items: [
                SettingsItem(
                  icon: Icons.person_outline,
                  title: 'المعلومات الشخصية',
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.lock_outline,
                  title: 'تغيير كلمة المرور',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsSection(
              title: 'الإعدادات المالية',
              items: [
                SettingsItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'إدارة المحافظ',
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.category_outlined,
                  title: 'إدارة الفئات',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageCategoriesScreen()),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.currency_exchange,
                  title: 'العملة الأساسية',
                  trailing: const Text('ريال يمني',
                      style: TextStyle(color: Colors.white70)),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsSection(
              title: 'التطبيق',
              items: [
                SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'الإشعارات',
                  onTap: () {},
                ),
                // 2. تحديث عنصر المظهر ليكون تفاعلياً
                SettingsItem(
                  icon: Icons.color_lens_outlined,
                  title: 'المظهر الداكن',
                  // 3. إضافة Switch للتحكم في المظهر
                  trailing: Switch(
                    value: appData.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      // 4. استدعاء الدالة لتغيير المظهر عند الضغط
                      appData.changeTheme(
                          value ? ThemeMode.dark : ThemeMode.light);
                    },
                    activeColor: const Color(0xff8952ff),
                  ),
                  onTap: () {}, // لا نحتاج للضغط على الصف نفسه
                ),
                SettingsItem(
                  icon: Icons.security_outlined,
                  title: 'الأمان والخصوصية',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
