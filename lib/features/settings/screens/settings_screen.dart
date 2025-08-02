import 'package:nabd/widgets/modern_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:nabd/features/goals/screens/goals_screen.dart';
import 'package:nabd/features/categories/screens/manage_categories_screen.dart';
import 'package:nabd/services/service_locator.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const ModernAppBar(
        greeting: 'الإعدادات',
        actions: [],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const ProfileHeader(
                name: 'مصروفي',
                email: ' ',
                // email: 'masrofi@masrofi.app',
              ),
              const SizedBox(height: 8),

              // Account Section
              SettingsSection(
                title: 'الحساب',
                items: [
                  SettingsItem(
                    icon: Icons.person_outline_rounded,
                    title: 'الملف الشخصي',
                    subtitle: 'تعديل بياناتك الشخصية',
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  SettingsItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'كلمة المرور',
                    subtitle: 'تغيير كلمة المرور',
                    onTap: () {
                      Navigator.pushNamed(context, '/change_password');
                    },
                  ),
                ],
              ),

              // Financial Settings Section
              SettingsSection(
                title: 'الإعدادات المالية',
                items: [
                  // SettingsItem(
                  //   icon: Icons.account_balance_wallet_outlined,
                  //   title: 'المحافظ',
                  //   subtitle: 'إدارة حساباتك البنكية',
                  //   onTap: () {},
                  // ),
                  SettingsItem(
                    icon: Icons.currency_exchange_rounded,
                    title: ' الاهداف',
                    subtitle: 'إدارة الاهداف ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoalsScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    icon: Icons.category_outlined,
                    title: 'الفئات',
                    subtitle: 'تخصيص فئات المصروفات والدخل',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageCategoriesScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    icon: Icons.currency_exchange_rounded,
                    title: 'العملة الافتراضية',
                    subtitle: 'ريال يمني',
                    onTap: () {},
                  ),
                ],
              ),

              // App Settings Section
              SettingsSection(
                title: 'إعدادات التطبيق',
                items: [
                  SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'الإشعارات',
                    subtitle: 'إدارة إشعارات التطبيق',
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icons.color_lens_outlined,
                    title: 'المظهر',
                    subtitle: isDark ? 'داكن' : 'فاتح',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        // TODO: Implement theme switching using Provider or another state management solution
                      },
                      activeColor: theme.colorScheme.primary,
                      activeTrackColor:
                          theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    onTap: () {
                      // TODO: Implement theme switching using Provider or another state management solution
                    },
                  ),
                  SettingsItem(
                    icon: Icons.language_rounded,
                    title: 'اللغة',
                    subtitle: 'العربية',
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icons.security_outlined,
                    title: 'الأمان والخصوصية',
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icons.help_outline_rounded,
                    title: 'المساعدة والدعم',
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icons.info_outline_rounded,
                    title: 'حول التطبيق',
                    onTap: () {},
                  ),
                ],
              ),

              // Sign Out Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Handle sign out
                    final authService = serviceLocator.authService;
                    await authService.logout();

                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
