import 'package:flutter/material.dart';
import 'package:nabd/services/auth_service.dart';
import 'package:nabd/services/service_locator.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/utils/validators.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:nabd/features/auth/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور الجديدة';
    }
    if (value != _newPasswordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (success) {
        setState(() {
          _successMessage = 'تم تغيير كلمة المرور بنجاح';
          // Clear the form
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      } else {
        setState(() {
          _errorMessage = 'فشل تغيير كلمة المرور. يرجى التحقق من كلمة المرور الحالية.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تغيير كلمة المرور. يرجى المحاولة مرة أخرى.';
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
        title: const Text('تغيير كلمة المرور'),
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
                    // Icon
                    const Icon(
                      Icons.lock_reset,
                      size: 64,
                      color: AppColors.primaryColor,
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

                    // Current Password Field
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال كلمة المرور الحالية';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور الحالية',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // New Password Field
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      validator: Validators.password,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور الجديدة',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm New Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      validator: _validateConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور الجديدة',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Change Password Button
                    PrimaryButton(
                      text: 'تغيير كلمة المرور',
                      isLoading: _isLoading,
                      onPressed: _changePassword,
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