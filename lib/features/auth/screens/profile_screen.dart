import 'package:flutter/material.dart';
import 'package:nabd/models/user_model.dart';
import 'package:nabd/services/service_locator.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/utils/validators.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:nabd/features/auth/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  late User _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _user = authProvider.currentUser!;
    _nameController.text = _user.name;
    _emailController.text = _user.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final updatedUser = _user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile(
        updatedUser.name, updatedUser.photoUrl);

      if (success) {
        setState(() {
          _successMessage = 'تم تحديث الملف الشخصي بنجاح';
        });
      } else {
        setState(() {
          _errorMessage = 'فشل تحديث الملف الشخصي. يرجى المحاولة مرة أخرى.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'حدث خطأ أثناء تحديث الملف الشخصي. يرجى المحاولة مرة أخرى.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                      child: Text(
                        _user.name.isNotEmpty
                            ? _user.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Success Message
                    if (_successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: Colors.green.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Error Message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      validator: Validators.name,
                      decoration: InputDecoration(
                        labelText: 'الاسم',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Update Button
                    PrimaryButton(
                      text: 'تحديث الملف الشخصي',
                      isLoading: _isLoading,
                      onPressed: _updateProfile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
