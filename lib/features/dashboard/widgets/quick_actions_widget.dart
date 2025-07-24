import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/scanner/screens/smart_scanner_screen.dart';
import 'package:nabd/widgets/glass_card.dart';

/// Row of quick action buttons: Expense, Scan Receipt, Income.
class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _QuickActionButton(
          label: 'مصروف',
          icon: Icons.arrow_downward,
          color: AppColors.expenseColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(initialType: TransactionType.expense)),
            );
          },
        ),
        _QuickActionButton(
          label: 'مسح إيصال',
          icon: Icons.camera_alt,
          color: AppColors.accentColor,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SmartScannerScreen()),
            );
          },
        ),
        _QuickActionButton(
          label: 'دخل',
          icon: Icons.arrow_upward,
          color: AppColors.incomeColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(initialType: TransactionType.income)),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          borderRadius: 32,
          padding: AppPaddings.allSmall,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(32),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
        AppPaddings.smallHeight,
        Text(label,
            style:
                AppTextStyles.subtitle2.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}
