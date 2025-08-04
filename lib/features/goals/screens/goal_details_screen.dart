import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/goals/goals_provider.dart';

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

  Widget _buildHistorySection(ThemeData theme) {
    // In a real app, this would show the transaction history
    // For now, we'll show a placeholder
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل التقدم',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Show all history
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Placeholder for history items
          _buildHistoryItem(
            context,
            'تمت إضافة مبلغ',
            '200 ر.س',
            'منذ ساعة',
            Icons.add_circle_outline,
            Colors.green,
          ),
          const Divider(height: 24),
          _buildHistoryItem(
            context,
            'تم إنشاء الهدف',
            '0 ر.س',
            'منذ 3 أيام',
            Icons.flag_outlined,
            theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String title,
    String amount,
    String timeAgo,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                timeAgo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildAddToGoalFab(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _isLoading ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _addToGoal,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add_rounded, size: 24),
        label: Text(_isLoading ? 'جاري الحفظ...' : 'إضافة مدخرات'),
        elevation: 4,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
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

  void _showGoalOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('تعديل الهدف'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit goal screen
              },
            ),
            if (!_isCompleted)
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: const Text('تم تحقيق الهدف'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsCompleted();
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'حذف الهدف',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsCompleted() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم تحقيق الهدف'),
        content:
            const Text('هل أنت متأكد أنك تريد وضع علامة على هذا الهدف كمكتمل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، تم تحقيقه'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final goalsProvider = context.read<GoalsProvider>();
        await goalsProvider.updateGoal(
          _currentGoal.copyWith(
            savedAmount: _currentGoal.totalAmount,
            updatedAt: DateTime.now(),
          ),
        );
        await _refreshGoal();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث حالة الهدف بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الهدف'),
        content: const Text(
            'هل أنت متأكد أنك تريد حذف هذا الهدف؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الهدف بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
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
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddAmountBottomSheet(),
    );

    if (result != null && result > 0) {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت إضافة المبلغ بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _currentGoal.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showGoalOptions(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGoal,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header with progress
            SliverToBoxAdapter(
              child: _buildHeader(theme, progress, isCompleted),
            ),

            // Stats and details
            SliverToBoxAdapter(
              child: _buildStatsSection(theme, remainingAmount, isCompleted),
            ),

            // Timeline/History
            SliverToBoxAdapter(
              child: _buildHistorySection(theme),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),

      // Add to Goal FAB
      floatingActionButton: !isCompleted ? _buildAddToGoalFab(theme) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Build the progress circle
  Widget _buildProgressCircle(
      BuildContext context, Goal goal, double progress, bool isCompleted) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: goal.color.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
        ),

        // Progress circle (static)
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 14,
            strokeCap: StrokeCap.round,
            backgroundColor: goal.color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? Colors.green : goal.color,
            ),
          ),
        ),

        // Center content
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              goal.icon,
              size: 48,
              color: isCompleted ? Colors.green : goal.color,
            ),
            const SizedBox(height: 8),

            // Progress percentage
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),

            // Status text
            Text(
              isCompleted ? 'مكتمل!' : 'في تقدم',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  // Build the stats row with saved, remaining, and total amounts
  Widget _buildStatsRow(BuildContext context, Goal goal, NumberFormat format,
      ThemeData theme, bool isCompleted) {
    final double saved = goal.savedAmount;
    final double total = goal.totalAmount;
    final double remaining = (total - saved).clamp(0.0, total);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          context,
          title: 'المدخر',
          amount: saved,
          color: theme.colorScheme.primary,
          format: format,
          icon: Icons.savings_outlined,
        ),
        _buildStatCard(
          context,
          title: 'المتبقي',
          amount: remaining,
          color: theme.colorScheme.tertiary,
          format: format,
          icon: Icons.hourglass_bottom_rounded,
        ),
        _buildStatCard(
          context,
          title: 'الهدف',
          amount: total,
          color: theme.colorScheme.secondary,
          format: format,
          icon: Icons.flag_outlined,
        ),
      ],
    );
  }

  // Build a single stat card
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required double amount,
    required Color color,
    required NumberFormat format,
    required IconData icon,
  }) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              format.format(amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Build action buttons row
  Widget _buildActionButtons(
    BuildContext context,
    GoalsProvider goalsProvider,
    Goal goal,
    bool isCompleted,
    ThemeData theme,
  ) {
    return const SizedBox.shrink();
  }

  // Build the achieve goal button
  Widget _buildAchieveGoalButton(
    BuildContext context,
    GoalsProvider goalsProvider,
    Goal goal,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, left: 20, right: 20),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showAchieveGoalConfirmation(context, goalsProvider, goal);
          },
          icon: const Icon(Icons.celebration_rounded, size: 20),
          label: const Text('احتفل بتحقيق الهدف!'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // Show confirmation dialog for achieving goal
  void _showAchieveGoalConfirmation(
      BuildContext context, GoalsProvider goalsProvider, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تهانينا! 🎉'),
        content: const Text('هل أنت متأكد أنك تريد الاحتفال بتحقيق هذا الهدف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              await goalsProvider.deleteGoal(goal.id);
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              Navigator.pop(context); // Go back to goals list

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تهانينا! لقد حققت هدفك بنجاح 🎉'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: const Text('نعم، حققت الهدف!'),
          ),
        ],
      ),
    );
  }

  // Show bottom sheet for adding to goal
  void _showAddToGoalBottomSheet(
      BuildContext context, Goal goal, GoalsProvider goalsProvider) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'أضف إلى المدخرات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Amount Input
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'المبلغ',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    suffixText: 'ريال',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال المبلغ';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'الرجاء إدخال مبلغ صحيح';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Save Button
                FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        final amount =
                            double.tryParse(amountController.text) ?? 0;
                        if (amount > 0) {
                          // TODO: Implement add savings to goal using provider/database
                          // goalsProvider.addSavingsToGoal(goal, amount);
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'تمت إضافة $amount ريال إلى مدخراتك بنجاح'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('حفظ')),
              ],
            ),
          ),
        );
      },
    );
  }
}
