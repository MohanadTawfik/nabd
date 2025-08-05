import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/goals/goals_provider.dart';
import 'package:nabd/features/goals/screens/add_goal_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nabd/utils/extensions.dart';
import 'package:nabd/utils/currency_extension.dart';
import 'package:nabd/widgets/confirmation_dialog.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Goal _currentGoal;
  bool _isLoading = false;
  final NumberFormat _format = NumberFormat("#,##0", "ar");

  @override
  void initState() {
    super.initState();
    _currentGoal = widget.goal;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Initialize the progress animation
    final progress = _calculateProgress();
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    // Start the animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  // Helper methods for building UI components
  Widget _buildHeader(ThemeData theme, double progress, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.scaffoldBackgroundColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          // Progress circle
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12,
                  backgroundColor: theme.dividerColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.dividerColor.withOpacity(0.1),
                  ),
                ),
                // Progress circle
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _progressAnimation.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.green : theme.primaryColor,
                      ),
                    );
                  },
                ),
                // Progress text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مكتمل',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Goal name
          Text(
            _currentGoal.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Goal description if available
          if (_currentGoal.description?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _currentGoal.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      ThemeData theme, double remainingAmount, bool isCompleted) {
    final savedAmount = _currentGoal.savedAmount;
    final totalAmount = _currentGoal.totalAmount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Saved amount
          _buildStatRow(
            context,
            'المدخر',
            savedAmount.toCurrencyString(),
            Icons.savings_rounded,
            theme.primaryColor,
          ),
          const Divider(height: 24),
          // Remaining amount
          _buildStatRow(
            context,
            'المتبقي',
            remainingAmount.toCurrencyString(),
            Icons.timelapse_rounded,
            theme.colorScheme.secondary,
          ),
          const Divider(height: 24),
          // Total amount
          _buildStatRow(
            context,
            'الهدف الكلي',
            totalAmount.toCurrencyString(),
            Icons.flag_rounded,
            isCompleted ? Colors.green : theme.hintColor,
            isBold: true,
          ),
          // Progress bar
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progressAnimation.value,
              minHeight: 12,
              backgroundColor: theme.dividerColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        // Label and value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddAmountBottomSheet() {
    final amountController = TextEditingController();
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إضافة مبلغ إلى الهدف',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0',
              border: InputBorder.none,
              hintStyle: theme.textTheme.headlineSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(right: 8.0, top: 12),
                child: Text('ر.س', style: TextStyle(fontSize: 20)),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          // Quick amount buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [100, 200, 500, 1000].map((amount) {
              return TextButton(
                onPressed: () {
                  amountController.text = amount.toString();
                },
                child: Text('+$amount'),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              Navigator.pop(context, amount);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تأكيد الإضافة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    HapticFeedback.lightImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الهدف'),
        content: const Text(
            'هل أنت متأكد أنك تريد حذف هذا الهدف؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, false);
            },
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final goalsProvider = context.read<GoalsProvider>();
        await goalsProvider.deleteGoal(_currentGoal.id);
        if (mounted) {
          HapticFeedback.mediumImpact();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم حذف الهدف بنجاح'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _calculateProgress() {
    return (_currentGoal.savedAmount / _currentGoal.totalAmount)
        .clamp(0.0, 1.0);
  }

  bool get _isCompleted => _calculateProgress() >= 1.0;

  Future<void> _refreshGoal() async {
    final goalsProvider = context.read<GoalsProvider>();
    await goalsProvider.loadGoals();
    if (mounted) {
      final updatedGoal = goalsProvider.goals.firstWhere(
        (g) => g.id == _currentGoal.id,
        orElse: () => _currentGoal,
      );
      setState(() {
        _currentGoal = updatedGoal;
        // Update the animation with new progress
        final newProgress = _calculateProgress();
        _progressAnimation = Tween<double>(
          begin: _progressAnimation.value,
          end: newProgress,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutCubic,
        ));
      });
      _animationController.forward(from: 0);
    }
  }

  Future<void> _addToGoal() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddAmountBottomSheet(),
    );

    if (result != null && result > 0) {
      // Medium haptic feedback for successful action
      HapticFeedback.mediumImpact();
      setState(() => _isLoading = true);
      try {
        final goalsProvider = context.read<GoalsProvider>();
        await goalsProvider.updateGoal(
          _currentGoal.copyWith(
            savedAmount: _currentGoal.savedAmount + result,
            updatedAt: DateTime.now(),
          ),
        );
        await _refreshGoal();
        if (mounted) {
          // Success haptic feedback
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تمت إضافة المبلغ بنجاح'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Error haptic feedback
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _calculateProgress();
    final isCompleted = _isCompleted;
    final remainingAmount = _currentGoal.totalAmount - _currentGoal.savedAmount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: RefreshIndicator(
          onRefresh: _refreshGoal,
          backgroundColor: theme.colorScheme.surface,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: false,
                title: Text(
                  _currentGoal.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.share_rounded),
                    tooltip: 'مشاركة الهدف',
                    onPressed: _shareGoal,
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_rounded),
                    tooltip: 'تعديل الهدف',
                    onPressed: () => _navigateToEditGoal(_currentGoal),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded),
                    tooltip: 'حذف الهدف',
                    onPressed: _showDeleteConfirmation,
                  ),
                  SizedBox(width: 8),
                ],
              ),

              // Progress Section
            SliverToBoxAdapter(
                child: _buildProgressSection(theme, progress, isCompleted),
            ),

              // Stats Section
            SliverToBoxAdapter(
                child: _buildStatsCards(theme, remainingAmount, isCompleted),
            ),

              // Actions Section
            SliverToBoxAdapter(
                child: _buildActionsSection(theme, isCompleted),
            ),

              // Goal Details Section
              SliverToBoxAdapter(
                child: _buildDetailsSection(theme),
              ),

              // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
        ),
      ),
    );
//TODO KKKKK
  }

  // Modern progress section with glass cards
  Widget _buildProgressSection(
      ThemeData theme, double progress, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        borderRadius: 24,
        blurStrength: 10,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Progress Circle
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      backgroundColor:
                          theme.colorScheme.outline.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.outline.withOpacity(0.05),
                      ),
                    ),
                    // Progress circle with animation
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.surface,
                              theme.colorScheme.surfaceVariant
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _progressAnimation.value,
                            strokeWidth: 14,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                    // Center content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.celebration_rounded
                              : Icons.flag_rounded,
                          size: 32,
                          color: isCompleted
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isCompleted
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.primary,
                              shadows: [
                                Shadow(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.2),
                                  blurRadius: 4,
                                )
                              ]),
                        ),
                        Text(
                          isCompleted ? 'مكتمل!' : 'في التقدم',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Goal name and description
              Text(
                _currentGoal.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (_currentGoal.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  _currentGoal.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Stats cards with responsive design - vertical layout for small screens
  Widget _buildStatsCards(
      ThemeData theme, double remainingAmount, bool isCompleted) {
    final savedAmount = _currentGoal.savedAmount;
    final totalAmount = _currentGoal.totalAmount;

    final stats = [
      {
        'title': 'المدخر',
        'amount': savedAmount,
        'icon': Icons.savings_rounded,
        'color': theme.colorScheme.primary,
      },
      {
        'title': 'المتبقي',
        'amount': remainingAmount.clamp(0.0, totalAmount),
        'icon': Icons.schedule_rounded,
        'color': theme.colorScheme.secondary,
      },
      {
        'title': 'الهدف',
        'amount': totalAmount,
        'icon': Icons.flag_rounded,
        'color': theme.colorScheme.tertiary,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if screen is too small for 3 cards in a row
        final isSmallScreen = constraints.maxWidth < 450;

        if (isSmallScreen) {
          // Use vertical layout for small screens
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: stats
                  .map(
                    (stat) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _buildHorizontalStatCard(
                        theme: theme,
                        title: stat['title'] as String,
                        amount: stat['amount'] as double,
                        icon: stat['icon'] as IconData,
                        color: stat['color'] as Color,
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        } else {
          // Use normal row layout for larger screens
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: stats
                  .map(
                    (stat) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: _buildVerticalStatCard(
                          theme: theme,
                          title: stat['title'] as String,
                          amount: stat['amount'] as double,
                          icon: stat['icon'] as IconData,
                          color: stat['color'] as Color,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        }
      },
    );
  }

  // Horizontal stat card for small screens
  Widget _buildHorizontalStatCard({
    required ThemeData theme,
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      borderRadius: 16,
      blurStrength: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    amount.toCurrencyString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vertical stat card for larger screens
  Widget _buildVerticalStatCard({
    required ThemeData theme,
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      borderRadius: 16,
      blurStrength: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              amount.toCurrencyString(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Actions section
  Widget _buildActionsSection(ThemeData theme, bool isCompleted) {
    if (isCompleted) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: GlassCard(
          borderRadius: 16,
          blurStrength: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 48,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'تهانينا! لقد حققت هدفك',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'أحسنت! لقد وصلت إلى هدفك المالي بنجاح',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              theme: theme,
              icon: Icons.add_rounded,
              title: 'إضافة مدخرات',
              onTap: _addToGoal,
              isPrimary: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              theme: theme,
              icon: Icons.history_rounded,
              title: 'السجل',
              onTap: () => _showHistoryBottomSheet(theme),
              isPrimary: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GlassCard(
      borderRadius: 16,
      blurStrength: 8,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.primary.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isPrimary
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                  color: isPrimary
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Goal details section
  Widget _buildDetailsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        borderRadius: 16,
        blurStrength: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'تفاصيل الهدف',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_currentGoal.targetDate != null) ...[
                _buildDetailRow(
                  theme: theme,
                  icon: Icons.schedule_rounded,
                  title: 'التاريخ المستهدف',
                  value:
                      '${_currentGoal.targetDate!.day}/${_currentGoal.targetDate!.month}/${_currentGoal.targetDate!.year}',
                ),
                const SizedBox(height: 12),
              ],
              _buildDetailRow(
                theme: theme,
                icon: Icons.calendar_today_rounded,
                title: 'تاريخ الإنشاء',
                value:
                    '${_currentGoal.createdAt.day}/${_currentGoal.createdAt.month}/${_currentGoal.createdAt.year}',
              ),
              if (_currentGoal.updatedAt != _currentGoal.createdAt) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  theme: theme,
                  icon: Icons.update_rounded,
                  title: 'آخر تحديث',
                  value:
                      '${_currentGoal.updatedAt?.day}/${_currentGoal.updatedAt?.month}/${_currentGoal.updatedAt?.year}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Modern FAB
  Widget _buildModernFAB(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _isLoading ? 0.7 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _addToGoal,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(Icons.add_rounded, size: 24),
        label: Text(
          _isLoading ? 'جاري الحفظ...' : 'إضافة مدخرات',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToEditGoal(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGoalScreen(goalToEdit: goal),
        fullscreenDialog: true,
      ),
    ).then((_) => _refreshGoal());
  }

  // History bottom sheet
  void _showHistoryBottomSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سجل الهدف',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: _buildGoalHistory(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalHistory(ThemeData theme) {
    final history = _generateGoalHistory();

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد سجل متاح',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر هنا جميع التحديثات والإضافات للهدف',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return _buildHistoryItem(theme, item, index == history.length - 1);
      },
    );
  }

  Widget _buildHistoryItem(
      ThemeData theme, Map<String, dynamic> item, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 16,
                        color: item['color'] as Color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['title'] as String,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        item['time'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (item['amount'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (item['amount'] as double).toCurrencyString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: item['color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateGoalHistory() {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> history = [];

    // إنشاء الهدف
    history.add({
      'title': 'تم إنشاء الهدف',
      'description': 'تم إنشاء هدف جديد: ${_currentGoal.name}',
      'time':
          '${_currentGoal.createdAt.day}/${_currentGoal.createdAt.month}/${_currentGoal.createdAt.year}',
      'icon': Icons.flag_rounded,
      'color': theme.colorScheme.primary,
      'amount': _currentGoal.totalAmount,
    });

    // إضافة المدخرات (إذا كان هناك مبلغ مدخر)
    if (_currentGoal.savedAmount > 0) {
      history.insert(0, {
        'title': 'تم إضافة مدخرات',
        'description': 'تم إضافة مبلغ إلى الهدف',
        'time': _currentGoal.updatedAt != null
            ? '${_currentGoal.updatedAt!.day}/${_currentGoal.updatedAt!.month}/${_currentGoal.updatedAt!.year}'
            : 'اليوم',
        'icon': Icons.savings_rounded,
        'color': theme.colorScheme.secondary,
        'amount': _currentGoal.savedAmount,
      });
    }

    // إكمال الهدف
    if (_isCompleted) {
      history.insert(0, {
        'title': 'تم تحقيق الهدف! 🎉',
        'description': 'تهانينا! لقد حققت هدفك بنجاح',
        'time': 'مؤخراً',
        'icon': Icons.celebration_rounded,
        'color': theme.colorScheme.tertiary,
        'amount': null,
      });
    }

    return history;
  }

  // Share goal functionality
  Future<void> _shareGoal() async {
    HapticFeedback.lightImpact();

    try {
      final progress = _calculateProgress();
      final progressPercentage = (progress * 100).toStringAsFixed(1);

      String shareText = 'هدفي المالي: ${_currentGoal.name}';
      shareText += 'الهدف: ${_currentGoal.totalAmount.toCurrencyString()}';
      shareText += 'المدخر: ${_currentGoal.savedAmount.toCurrencyString()}';
      shareText += 'نسبة التقدم: $progressPercentage%';

      if (_isCompleted) {
        shareText += 'تم تحقيق الهدف!';
      } else {
        final remaining = _currentGoal.totalAmount - _currentGoal.savedAmount;
        shareText += 'المتبقي: ${remaining.toCurrencyString()}';
      }

      if (_currentGoal.targetDate != null) {
        shareText +=
            'التاريخ المستهدف: ${_currentGoal.targetDate!.day}/${_currentGoal.targetDate!.month}/${_currentGoal.targetDate!.year}';
      }

      shareText += 'تطبيق نبض - لإدارة الأهداف المالية';

      await Share.share(
        shareText,
        subject: 'هدفي المالي - ${_currentGoal.name}',
      );

      HapticFeedback.selectionClick();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يمكن مشاركة الهدف: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
