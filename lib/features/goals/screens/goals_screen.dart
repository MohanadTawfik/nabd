import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart'; // For ScrollDirection
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  Future<void> _navigateAndAddGoal() async {
    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const AddGoalScreen(),
        ),
      );

      if (result == true && mounted) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت إضافة الهدف بنجاح'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء إضافة الهدف'),
            duration: Duration(seconds: 2),
          ),
        );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الأهداف...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ: $error',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(List<Goal> goals, {bool isCompleted = false}) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.celebration_outlined : Icons.flag_outlined,
              size: 64,
              color: Theme.of(context).hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted ? 'لا توجد أهداف مكتملة بعد' : 'لا توجد أهداف نشطة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 8),
              Text(
                'انقر على زر + لإنشاء هدف جديد',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor.withOpacity(0.7),
                    ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GoalCardWidget(
            goal: goal,
            onTap: () => _navigateToGoalDetails(goal),
            onLongPress: () => _showGoalActions(goal),
          ),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('تعديل الهدف'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditGoal(goal);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  const Text('حذف الهدف', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(goal);
              },
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
      ),
    ).then((_) => _loadData());
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flag_outlined,
                  size: 80,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'لا توجد أهداف بعد',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'ابدأ بإنشاء هدفك الأول لتتبع تقدمك في التوفير',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _navigateAndAddGoal,
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text('إنشاء هدف جديد',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            title: Text('أهدافك',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            centerTitle: false,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
                onPressed: _navigateAndAddGoal,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Align(
                alignment: Alignment.centerRight,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: theme.hintColor,
                  indicatorColor: theme.primaryColor,
                  indicatorWeight: 3,
                  labelStyle: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: textTheme.titleMedium,
                  tabs: const [
                    Tab(text: 'النشطة'),
                    Tab(text: 'المكتملة'),
                  ],
                ),
              ),
            ),
          ),
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

            return RefreshIndicator(
              onRefresh: _loadData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGoalsList(activeGoals),
                  _buildGoalsList(completedGoals, isCompleted: true),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _showFloatingButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton.extended(
          onPressed: _navigateAndAddGoal,
          icon: const Icon(Icons.add_rounded),
          label: const Text('هدف جديد'),
          elevation: 4,
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  List<Widget> _buildGoalsSection({
    required BuildContext context,
    required String title,
    required List<Goal> goals,
    required Function(BuildContext, Goal) onDelete,
  }) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final goal = goals[index];

            // Create the goal widget
            final goalWidget = Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
              child: Dismissible(
                key: ValueKey(goal.name),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                confirmDismiss: (direction) async {
                  onDelete(context, goal);
                  return false; // We handle the deletion in the dialog
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GoalDetailsScreen(goal: goal),
                      ),
                    );
                  },
                  child: GoalCardWidget(goal: goal),
                ),
              ),
            );
            // No staggered animations, just return the widget
            return goalWidget;
          },
          childCount: goals.length,
        ),
      ),
    ];
  }
}
