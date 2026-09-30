import 'package:brewing_journal_flutter/main.dart' as app;
import 'package:brewing_journal_flutter/ui/features/auth/view/sign_in_screen.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_list_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app leaves the splash screen', (tester) async {
    await app.main();
    await tester.pump();

    // The splash indicator animates forever, so pump frames until auth
    // resolves instead of waiting for every animation to settle.
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      final signedOut = find.byType(SignInScreen).evaluate().isNotEmpty;
      final signedIn = find.byType(RecipeListScreen).evaluate().isNotEmpty;
      if (signedOut || signedIn) {
        break;
      }
    }

    expect(
      find.byType(SignInScreen).evaluate().isNotEmpty ||
          find.byType(RecipeListScreen).evaluate().isNotEmpty,
      isTrue,
    );
  });
}
