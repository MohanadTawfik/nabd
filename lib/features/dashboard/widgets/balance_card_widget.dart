import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/add_transaction/widgets/add_transaction_panel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class BalanceCardWidget extends StatelessWidget {
  const BalanceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام Consumer للاستماع للتغيرات في AppData
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final format = NumberFormat.currency(locale: 'ar', symbol: '');

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
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
                    'الرصيد الحالي',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddTransactionPanel(),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${format.format(appData.currentBalance)} ريال',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 36, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}
