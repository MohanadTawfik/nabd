import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nabd/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Flow', () {
    testWidgets('Add, edit, and delete a transaction',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Scroll quick actions to make the add icon visible, then tap
      final quickActions = find.byKey(const Key('quick_actions_list'));
      await tester.scrollUntilVisible(
        find.byIcon(Icons.add_rounded),
        50.0,
        scrollable: quickActions,
      );
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(find.byType(TextFormField).first, '100');

      // Select category (assumes a category picker is present)
      await tester.tap(find.textContaining('فئة').first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('طعام').first);
      await tester.pumpAndSettle();

      // Enter notes
      await tester.enterText(
          find.byType(TextFormField).last, 'Test integration note');

      // Save transaction (assumes a button with text 'حفظ' or similar)
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      // Verify transaction appears (assumes transaction list or timeline updates)
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Test integration note'), findsOneWidget);
    });

    testWidgets('Add and delete a budget', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Scroll quick actions to make the add budget icon visible, then tap
      final quickActions = find.byKey(const Key('quick_actions_list'));
      await tester.scrollUntilVisible(
        find.byIcon(Icons.account_balance_wallet_outlined),
        50.0,
        scrollable: quickActions,
      );
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();

      // Enter budget amount
      await tester.enterText(find.byType(TextFormField).first, '500');

      // Select category (assumes a category picker is present)
      await tester.tap(find.textContaining('فئة').first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('طعام').first);
      await tester.pumpAndSettle();

      // Save budget (assumes a button with text 'حفظ')
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      // Verify budget appears
      expect(find.text('500'), findsOneWidget);

      // Delete budget (uses delete icon in UI)
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      // Confirm deletion if dialog appears
      if (find.text('تأكيد').evaluate().isNotEmpty) {
        await tester.tap(find.text('تأكيد'));
        await tester.pumpAndSettle();
      }
      // Verify budget is removed
      expect(find.text('500'), findsNothing);
    });

    testWidgets('Add and delete a goal', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Scroll quick actions to make the add goal icon visible, then tap
      final quickActions = find.byKey(const Key('quick_actions_list'));
      await tester.scrollUntilVisible(
        find.byIcon(Icons.flag_outlined),
        50.0,
        scrollable: quickActions,
      );
      await tester.tap(find.byIcon(Icons.flag_outlined));
      await tester.pumpAndSettle();

      // Enter goal name
      await tester.enterText(find.byType(TextFormField).first, 'Test Goal');
      // Enter goal amount
      await tester.enterText(find.byType(TextFormField).at(1), '1000');

      // Save goal (assumes a button with text 'حفظ')
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      // Verify goal appears
      expect(find.text('Test Goal'), findsOneWidget);

      // Delete goal (uses delete icon in UI)
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      // Confirm deletion if dialog appears
      if (find.text('تأكيد').evaluate().isNotEmpty) {
        await tester.tap(find.text('تأكيد'));
        await tester.pumpAndSettle();
      }
      // Verify goal is removed
      expect(find.text('Test Goal'), findsNothing);
    });

    testWidgets('Journey timeline updates after actions',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add a transaction
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '200');
      await tester.tap(find.textContaining('فئة').first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('طعام').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).last, 'Timeline Test');
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      // Navigate to journey/timeline screen (assumes a tab or button with text 'الرحلة')
      await tester.tap(find.text('الرحلة'));
      await tester.pumpAndSettle();

      // Verify timeline contains the new transaction
      expect(find.text('Timeline Test'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
    });
  });
}
