import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  onTap: () {},
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
                SettingsItem(
                  icon: Icons.color_lens_outlined,
                  title: 'المظهر',
                  trailing: const Text('داكن',
                      style: TextStyle(color: Colors.white70)),
                  onTap: () {},
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
