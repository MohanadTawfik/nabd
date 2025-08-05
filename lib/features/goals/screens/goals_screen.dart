import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart'; // For ScrollDirection
import 'package:intl/intl.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/goals/screens/goal_details_screen.dart';
import 'package:nabd/features/goals/widgets/goal_card_widget.dart';
import 'package:nabd/widgets/confirmation_dialog.dart';
import 'package:nabd/widgets/empty_state.dart';
import 'package:provider/provider.dart';
import 'add_goal_screen.dart';
import 'package:nabd/features/goals/goals_provider.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'dart:math' as math;

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = true;
  bool _isLoading = true;
  String? _errorMessage;

  // Sort options
  String _sortBy = 'progress'; // 'progress', 'amount', 'name', 'date'
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Update UI when tab changes
    });
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final provider = Provider.of<GoalsProvider>(context, listen: false);
      await provider.loadGoals();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل تحميل الأهداف. الرجاء المحاولة مرة أخرى';
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more goals if needed
    }

    // Show/hide FAB based on scroll direction
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (_showFloatingButton) {
        setState(() => _showFloatingButton = false);
      }
    } else if (direction == ScrollDirection.forward) {
      if (!_showFloatingButton) {
        setState(() => _showFloatingButton = true);
      }
    }
  }

  // Sort goals based on selected criteria
  List<Goal> _sortGoals(List<Goal> goals) {
    goals.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'amount':
          comparison = a.totalAmount.compareTo(b.totalAmount);
          break;
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'date':
          comparison =
              a.targetDate?.compareTo(b.targetDate ?? DateTime.now()) ?? 0;
          break;
        case 'progress':
          final progressA = a.savedAmount / a.totalAmount;
          final progressB = b.savedAmount / b.totalAmount;
          comparison = progressA.compareTo(progressB);
          break; // Added break statement
        default:
          comparison = 0; // 默认情况处理
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    return goals;
  }

  Future<void> _navigateAndAddGoal() async {
    HapticFeedback.lightImpact();
    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const AddGoalScreen(),
          fullscreenDialog: true,
        ),
      );

      if (result == true && mounted) {
        await _loadData();
        if (mounted) {
          _showSnackBar('تمت إضافة الهدف بنجاح');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('حدث خطأ أثناء إضافة الهدف');
      }
    }
  }

  // Show delete confirmation dialog with haptic feedback
  void _showDeleteConfirmation(Goal goal) {
    HapticFeedback.mediumImpact();
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'حذف الهدف',
        content: 'هل أنت متأكد من رغبتك في حذف هدف "${goal.name}"؟',
        onConfirm: () async {
          await goalsProvider.deleteGoal(goal.id);
          HapticFeedback.mediumImpact();
          if (mounted) {
            Navigator.of(dialogContext).pop();
            _showSnackBar('تم حذف الهدف بنجاح');
          }
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.only(
          bottom: 20,
          left: 16,
          right: 16,
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Shimmer.fromColors(
              baseColor: theme.colorScheme.primary.withOpacity(0.4),
              highlightColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flag_outlined,
                  size: 60,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: theme.colorScheme.onSurface.withOpacity(0.4),
            highlightColor: theme.colorScheme.onSurface.withOpacity(0.2),
            child: Container(
              width: 180,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
              size: 64, 
            color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: Icon(Icons.refresh_rounded),
            label: Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(List<Goal> goals, {bool isCompleted = false}) {
    final theme = Theme.of(context);

    if (goals.isEmpty) {
      return EmptyState(
        icon: isCompleted ? Icons.celebration_outlined : Icons.flag_outlined,
        title: isCompleted ? 'لا توجد أهداف مكتملة بعد' : 'لا توجد أهداف نشطة',
        message: isCompleted
            ? 'أكمل أهدافك المالية لتظهر هنا'
            : 'أضف هدفًا ماليًا جديدًا لتتبع تقدمك في التوفير',
        actionText: !isCompleted ? 'إضافة هدف جديد' : null,
        onActionPressed: !isCompleted ? _navigateAndAddGoal : null,
      );
    }

    // Sort goals before displaying
    final sortedGoals = _sortGoals(List<Goal>.from(goals));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedGoals.length,
      itemBuilder: (context, index) {
        final goal = sortedGoals[index];
        // Add staggered animation for each goal card
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GoalCardWidget(
                    goal: goal,
                    onTap: () => _navigateToGoalDetails(goal),
                    onLongPress: () => _showGoalActions(goal),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToGoalDetails(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GoalDetailsScreen(goal: goal),
      ),
    ).then((_) => _loadData());
  }

  void _showGoalActions(Goal goal) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassBackground(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: EdgeInsets.only(bottom: 20),
              ),
              Text(
                goal.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'اختر إجراء',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 24),
              // Options
              _buildActionTile(
                context: context,
                icon: Icons.add_circle_outline,
                title: 'إضافة مدخرات',
                color: AppColors.successColor,
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to add savings (can be implemented in goal details)
                  _navigateToGoalDetails(goal);
                },
              ),
              _buildActionTile(
                context: context,
                icon: Icons.edit_outlined,
                title: 'تعديل الهدف',
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditGoal(goal);
                },
              ),
              _buildActionTile(
                context: context,
                icon: Icons.delete_outline,
                title: 'حذف الهدف',
                color: theme.colorScheme.error,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(goal);
                },
              ),
              SizedBox(height: 16),
              // Cancel button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surface.withOpacity(0.3),
                  ),
                  child: Text(
                    'إلغاء',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditGoal(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddGoalScreen(),
        fullscreenDialog: true,
      ),
    ).then((_) => _loadData());
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return EmptyState(
      icon: Icons.flag_outlined,
      title: 'لا توجد أهداف بعد',
      message: 'ابدأ بإنشاء هدفك المالي الأول لتتبع تقدمك في التوفير',
      actionText: 'إنشاء هدف جديد',
      onActionPressed: _navigateAndAddGoal,
    );
  }

  // Widget to display summary statistics about goals
  Widget _buildGoalsSummary(List<Goal> goals) {
    final theme = Theme.of(context);
    final format =
        NumberFormat.currency(locale: 'ar', symbol: '﷼', decimalDigits: 0);

    // Calculate statistics
    final totalGoals = goals.length;
    final totalAmount = goals.fold(0.0, (sum, goal) => sum + goal.totalAmount);
    final savedAmount = goals.fold(0.0, (sum, goal) => sum + goal.savedAmount);
    final remainingAmount = totalAmount - savedAmount;
    final overallProgress = totalAmount > 0 ? (savedAmount / totalAmount) : 0.0;

    return GlassCard(
      margin: EdgeInsets.all(16),
      borderRadius: 24,
      blurStrength: 10,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.insights,
                    color: AppColors.successColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'ملخص الأهداف',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقدم الكلي',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '${(overallProgress * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(overallProgress),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Animated progress bar
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: overallProgress),
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Stack(
                      children: [
                        // Background
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        // Progress
                        FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getProgressColor(value),
                                  _getProgressColor(value).withOpacity(0.7),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context: context,
                  title: 'إجمالي الادخار',
                  value: format.format(savedAmount),
                  icon: Icons.savings_outlined,
                  color: AppColors.incomeColor,
                ),
                _buildStatItem(
                  context: context,
                  title: 'المتبقي',
                  value: format.format(remainingAmount),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.accentColor,
                ),
                _buildStatItem(
                  context: context,
                  title: 'عدد الأهداف',
                  value: totalGoals.toString(),
                  icon: Icons.flag_outlined,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to determine progress color
  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  // Widget to display individual statistic
  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // Header widget with filter options
  Widget _buildHeader(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      title: Text(
        'أهداف التوفير',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        // Sort button
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sort_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          onPressed: _showSortOptions,
          tooltip: 'ترتيب الأهداف',
        ),
        // Add goal button
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          onPressed: _navigateAndAddGoal,
          tooltip: 'إضافة هدف جديد',
        ),
        SizedBox(width: 8),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3.0,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        unselectedLabelStyle: theme.textTheme.titleMedium?.copyWith(
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag_rounded, size: 18),
                const SizedBox(width: 6),
                Text('النشطة'),
                if (_getActiveGoalsCount() > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getActiveGoalsCount().toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration_rounded, size: 18),
                const SizedBox(width: 6),
                Text('المكتملة'),
                if (_getCompletedGoalsCount() > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getCompletedGoalsCount().toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show sort options dialog
  void _showSortOptions() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassBackground(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: EdgeInsets.only(bottom: 20),
                ),
              ),
              Text(
                'ترتيب الأهداف',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'اختر طريقة عرض الأهداف',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 24),
              // Sort options
              _buildSortOption(
                icon: Icons.trending_up,
                title: 'نسبة الإنجاز',
                isSelected: _sortBy == 'progress',
                onTap: () {
                  setState(() {
                    _sortBy = 'progress';
                    if (_sortBy == 'progress') {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortAscending = false;
                    }
                  });
                  Navigator.pop(context);
                },
                isAscending: _sortBy == 'progress' ? _sortAscending : null,
              ),
              _buildSortOption(
                icon: Icons.attach_money,
                title: 'قيمة الهدف',
                isSelected: _sortBy == 'amount',
                onTap: () {
                  setState(() {
                    _sortBy = 'amount';
                    if (_sortBy == 'amount') {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortAscending = false;
                    }
                  });
                  Navigator.pop(context);
                },
                isAscending: _sortBy == 'amount' ? _sortAscending : null,
              ),
              _buildSortOption(
                icon: Icons.sort_by_alpha,
                title: 'الاسم',
                isSelected: _sortBy == 'name',
                onTap: () {
                  setState(() {
                    _sortBy = 'name';
                    if (_sortBy == 'name') {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortAscending = true;
                    }
                  });
                  Navigator.pop(context);
                },
                isAscending: _sortBy == 'name' ? _sortAscending : null,
              ),
              _buildSortOption(
                icon: Icons.date_range,
                title: 'تاريخ الاستحقاق',
                isSelected: _sortBy == 'date',
                onTap: () {
                  setState(() {
                    _sortBy = 'date';
                    if (_sortBy == 'date') {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortAscending = true;
                    }
                  });
                  Navigator.pop(context);
                },
                isAscending: _sortBy == 'date' ? _sortAscending : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for sort option
  Widget _buildSortOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool? isAscending,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.onSurface.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.onSurface.withOpacity(0.1),
              ),
              child: Icon(icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  size: 20),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            Spacer(),
            if (isSelected && isAscending != null)
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 20,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build custom tab with icon and count
  Widget _buildTab({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String text,
    required bool isSelected,
    required int count,
  }) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.9 + (value * 0.1),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            Text(text),
            if (count > 0) ...[
              const SizedBox(width: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        isSelected ? Colors.white : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Get count of active goals
  int _getActiveGoalsCount() {
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    return goalsProvider.goals
        .where((g) => (g.savedAmount / g.totalAmount) < 1.0)
        .length;
  }

  // Get count of completed goals
  int _getCompletedGoalsCount() {
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    return goalsProvider.goals
        .where((g) => (g.savedAmount / g.totalAmount) >= 1.0)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildHeader(theme),
            ],
            body: Consumer<GoalsProvider>(
              builder: (context, goalsProvider, _) {
                if (_isLoading) return _buildLoadingState();
                if (_errorMessage != null) {
                  return _buildErrorState(_errorMessage!);
                }
                if (goalsProvider.error != null) {
                  return _buildErrorState(goalsProvider.error!);
                }

                final goals = goalsProvider.goals;
                final completedGoals = goals
                    .where((g) => (g.savedAmount / g.totalAmount) >= 1.0)
                    .toList();
                final activeGoals = goals
                    .where((g) => (g.savedAmount / g.totalAmount) < 1.0)
                    .toList();

                if (goals.isEmpty) {
                  return _buildEmptyState(context, theme);
                }

                return Column(
                  children: [
                    _buildGoalsSummary(goals),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.surface,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildGoalsList(activeGoals),
                            _buildGoalsList(completedGoals, isCompleted: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: _showFloatingButton ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 300),
        child: AnimatedOpacity(
          opacity: _showFloatingButton ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            onPressed: _navigateAndAddGoal,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
      ),
    );
  }
}
