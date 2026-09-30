import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/auth_harness.dart';

/// Meets the email form's length, case, digit, and symbol rules.
const _password = 'Brewjournal1!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final harness = AuthHarness();
  tearDownAll(harness.close);

  group('Feature 1 — Authentication', () {
    testWidgets('US-1.4 rejects a bad verification code', (tester) async {
      await harness.ensureSignedOut(tester);
      await harness.rejectVerificationCode(tester, harness.freshEmail());
    });

    testWidgets('US-1.1 signs up and opens the journal', (tester) async {
      await harness.ensureSignedOut(tester);
      await harness.signUp(tester, harness.freshEmail(), _password);
      expect(find.byType(RecipeListScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('sign-out')), findsOneWidget);
    });

    testWidgets('US-1.2 restores the session without the sign-in screen', (
      tester,
    ) async {
      await harness.openApp(tester);
      if (find.byType(RecipeListScreen).evaluate().isEmpty) {
        await harness.signUp(tester, harness.freshEmail(), _password);
      }
      await harness.openApp(tester, assertNoSignIn: true);
      expect(find.byType(RecipeListScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('sign-in')), findsNothing);
    });

    testWidgets('US-1.3 a failed sign-in stays signed out', (tester) async {
      await harness.openApp(tester);
      final email = harness.accountEmail;
      if (find.byType(RecipeListScreen).evaluate().isEmpty || email == null) {
        final created = harness.freshEmail();
        await harness.ensureSignedOut(tester);
        await harness.signUp(tester, created, _password);
      }
      final account = harness.accountEmail!;
      await harness.signOut(tester);
      await harness.expectRejectedLogin(
        tester,
        harness.freshEmail(),
        _password,
      );
      await harness.expectRejectedLogin(
        tester,
        account,
        'Wrongjournal1!',
      );
    });
  });
}
