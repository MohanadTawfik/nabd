import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:nabd/features/goals/goals_provider.dart';

class AddGoalScreen extends StatefulWidget {
  final Goal? goalToEdit;

  const AddGoalScreen({
    super.key,
    this.goalToEdit,
  });

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _iconAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _iconScaleAnimation;

  bool _isSaving = false;
  bool _isEditing = false;
  IconData _selectedIcon = Icons.star_rounded;
  Color _selectedColor = AppColors.primaryColor;
  DateTime? _targetDate;

  // Enhanced icon categories with more modern icons
  final Map<String, List<Map<String, dynamic>>> _iconCategories = {
    'المركبات': [
      {'icon': Icons.directions_car_rounded, 'color': AppColors.primaryColor},
      {'icon': Icons.motorcycle_rounded, 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.electric_car_rounded, 'color': const Color(0xFF10B981)},
      {'icon': Icons.local_shipping_rounded, 'color': const Color(0xFF3B82F6)},
    ],
    'السفر': [
      {'icon': Icons.flight_takeoff_rounded, 'color': const Color(0xFF06B6D4)},
      {'icon': Icons.hotel_rounded, 'color': const Color(0xFFEC4899)},
      {'icon': Icons.luggage_rounded, 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.map_rounded, 'color': const Color(0xFF10B981)},
    ],
    'التقنية': [
      {'icon': Icons.laptop_mac_rounded, 'color': const Color(0xFF6B7280)},
      {'icon': Icons.smartphone_rounded, 'color': const Color(0xFF1F2937)},
      {'icon': Icons.camera_alt_rounded, 'color': const Color(0xFFEF4444)},
      {'icon': Icons.headphones_rounded, 'color': const Color(0xFF8B5CF6)},
    ],
    'المنزل': [
      {'icon': Icons.home_rounded, 'color': const Color(0xFF10B981)},
      {'icon': Icons.chair_rounded, 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.kitchen_rounded, 'color': const Color(0xFFEC4899)},
      {'icon': Icons.bed_rounded, 'color': const Color(0xFF06B6D4)},
    ],
    'التعليم': [
      {'icon': Icons.school_rounded, 'color': const Color(0xFFEAB308)},
      {'icon': Icons.menu_book_rounded, 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.science_rounded, 'color': const Color(0xFF10B981)},
      {'icon': Icons.computer_rounded, 'color': const Color(0xFF3B82F6)},
    ],
    'الصحة': [
      {'icon': Icons.fitness_center_rounded, 'color': const Color(0xFFEF4444)},
      {'icon': Icons.local_hospital_rounded, 'color': const Color(0xFF10B981)},
      {'icon': Icons.spa_rounded, 'color': const Color(0xFFEC4899)},
      {'icon': Icons.psychology_rounded, 'color': const Color(0xFF8B5CF6)},
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGoalData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  void _loadGoalData() {
    if (widget.goalToEdit != null) {
      final goal = widget.goalToEdit!;
      _isEditing = true;
      _nameController.text = goal.name;
      _amountController.text = goal.totalAmount.toStringAsFixed(0);
      _selectedIcon = goal.icon;
      _selectedColor = goal.color;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _iconAnimationController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isSaving = true;
    });

    try {
      final goal = Goal(
        id: _isEditing
            ? widget.goalToEdit!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        totalAmount: double.parse(_amountController.text),
        color: _selectedColor,
      );

      final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
      if (_isEditing) {
        await goalsProvider.updateGoal(goal);
      } else {
        await goalsProvider.addGoal(goal);
      }

      if (mounted) {
        HapticFeedback.heavyImpact();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ الهدف: \${e.toString()}'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _selectTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryColor,
                  surface: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.cardDark
                      : AppColors.cardLight,
                ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _targetDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: _buildBody(),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        _isEditing ? 'تعديل الهدف' : 'إضافة هدف جديد',
        style: AppTextStyles.displayMedium.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textDark
              : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildIconSelector(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildOptionalInfoSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _iconScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _iconScaleAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _selectedIcon,
                    size: 40,
                    color: _selectedColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _isEditing ? 'تعديل هدفك المالي' : 'اختر هدفك المالي',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textDark
                  : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'حدد هدفك وابدأ رحلة الادخار نحو تحقيق أحلامك',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.subtextDark
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر رمزاً لهدفك',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textDark
                  : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._iconCategories.entries.map((entry) => _buildIconCategory(
                entry.key,
                entry.value,
              )),
        ],
      ),
    );
  }

  Widget _buildIconCategory(
      String categoryName, List<Map<String, dynamic>> icons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            categoryName,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.subtextDark
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            final iconData = icons[index];
            final icon = iconData['icon'] as IconData;
            final color = iconData['color'] as Color;
            final isSelected = _selectedIcon == icon;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedIcon = icon;
                  _selectedColor = color;
                });
                _iconAnimationController.forward().then((_) {
                  _iconAnimationController.reverse();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.2)
                      : Theme.of(context).brightness == Brightness.dark
                          ? AppColors.cardDark.withOpacity(0.5)
                          : AppColors.cardLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? color
                      : Theme.of(context).brightness == Brightness.dark
                          ? AppColors.iconDark
                          : AppColors.iconLight,
                  size: 28,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الهدف',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textDark
                  : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: 'اسم الهدف',
            hint: 'مثال: سيارة جديدة، رحلة إلى اليابان',
            icon: Icons.flag_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال اسم الهدف';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _amountController,
            label: 'المبلغ المطلوب (ريال)',
            hint: '50000',
            icon: Icons.attach_money_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال المبلغ المطلوب';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'يرجى إدخال مبلغ صحيح';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalInfoSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات إضافية (اختيارية)',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textDark
                  : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionController,
            label: 'وصف الهدف',
            hint: 'اكتب وصفاً مختصراً لهدفك...',
            icon: Icons.description_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          _buildDateSelector(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textDark
                : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textDark
                : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.subtextDark
                  : AppColors.textSecondary,
            ),
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.iconDark
                  : AppColors.iconLight,
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.cardDark.withOpacity(0.5)
                : AppColors.cardLight.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ المستهدف',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textDark
                : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectTargetDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark.withOpacity(0.5)
                  : AppColors.cardLight.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.iconDark
                      : AppColors.iconLight,
                ),
                const SizedBox(width: 12),
                Text(
                  _targetDate != null
                      ? '\${_targetDate!.day}/\${_targetDate!.month}/\${_targetDate!.year}'
                      : 'اختر التاريخ المستهدف',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: _targetDate != null
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textDark
                            : AppColors.textPrimary)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.subtextDark
                            : AppColors.textSecondary),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.iconDark
                      : AppColors.iconLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveGoal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEditing ? 'تحديث الهدف' : 'إطلاق الحلم!',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
