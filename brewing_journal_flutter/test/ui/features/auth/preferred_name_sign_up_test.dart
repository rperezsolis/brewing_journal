import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/features/auth/view/preferred_name_email_sign_in.dart';
import 'package:brewing_journal_flutter/ui/features/auth/view/sign_in_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SignInLocalizationProvider(
            basic: basicSignInTextsFor(l10n),
            email: emailSignInTextsFor(l10n),
            passwordRequirementTexts: passwordRequirementTextsFor(l10n),
            child: PreferredNameEmailSignIn(
              client: Client('http://127.0.0.1:8080/'),
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton continueButton(WidgetTester tester) {
    return tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continue'),
    );
  }

  Future<void> openRegistration(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(TextButton, 'Create Account'));
    await tester.pump();
  }

  testWidgets('sign-up requires a preferred name before continue', (
    tester,
  ) async {
    await pump(tester);
    await openRegistration(tester);

    expect(find.text('Preferred name'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(continueButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(1), 'ada@example.com');
    await tester.pump(const Duration(milliseconds: 700));
    expect(continueButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.pump();
    expect(continueButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Ada');
    await tester.pump();
    expect(continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('sign-in does not ask for a preferred name', (tester) async {
    await pump(tester);

    expect(find.text('Preferred name'), findsNothing);
    expect(find.text('Sign in with Email'), findsOneWidget);

    await openRegistration(tester);

    expect(find.text('Preferred name'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Preferred name'), findsNothing);
    expect(find.text('Sign in with Email'), findsOneWidget);
  });
}
