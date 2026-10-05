import 'package:brewing_journal_flutter/app_scope.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/locale_resolution.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_auth_repository.dart';
import 'package:brewing_journal_flutter/router.dart';
import 'package:brewing_journal_flutter/ui/features/auth/cubit/auth_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/auth/cubit/auth_state.dart';
import 'package:brewing_journal_flutter/ui/features/auth/view/splash_screen.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? redirect(AuthStatus status, String location) =>
      authRedirect(status, Uri.parse(location));

  setUp(resetAuthRedirect);

  group('authRedirect while unknown', () {
    test('sends a deep link to splash and restores it after sign-in', () {
      expect(redirect(AuthStatus.unknown, '/invite/abc'), '/splash');
      expect(redirect(AuthStatus.unauthenticated, '/splash'), '/sign-in');
      expect(redirect(AuthStatus.authenticated, '/sign-in'), '/invite/abc');
      expect(redirect(AuthStatus.authenticated, '/sign-in'), '/invite/abc');
      expect(redirect(AuthStatus.authenticated, '/invite/abc'), isNull);
    });

    test('sends home to splash without storing a return path', () {
      expect(redirect(AuthStatus.unknown, '/'), '/splash');
      expect(redirect(AuthStatus.authenticated, '/splash'), '/');
    });

    test('stays on splash', () {
      expect(redirect(AuthStatus.unknown, '/splash'), isNull);
    });
  });

  group('authRedirect while unauthenticated', () {
    test('sends a protected route to sign-in without a from query', () {
      expect(
        redirect(AuthStatus.unauthenticated, '/some/path?q=1'),
        '/sign-in',
      );
      expect(redirect(AuthStatus.authenticated, '/sign-in'), '/some/path?q=1');
    });

    test('stays on sign-in', () {
      expect(redirect(AuthStatus.unauthenticated, '/sign-in'), isNull);
    });
  });

  group('authRedirect while authenticated', () {
    test('goes from sign-in to home when nothing was stored', () {
      expect(redirect(AuthStatus.authenticated, '/sign-in'), '/');
    });

    test('ignores an external return path', () {
      expect(
        redirect(AuthStatus.unauthenticated, 'https://evil.com'),
        '/sign-in',
      );
      expect(redirect(AuthStatus.authenticated, '/sign-in'), '/');

      resetAuthRedirect();
      expect(redirect(AuthStatus.unauthenticated, '//evil.com'), '/sign-in');
      expect(redirect(AuthStatus.authenticated, '/sign-in'), '/');
    });

    test('leaves other routes alone', () {
      expect(redirect(AuthStatus.authenticated, '/some/path'), isNull);
    });
  });

  group('createRouter', () {
    late FakeAuthRepository repository;
    late AuthCubit cubit;

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        AppScope(
          repositories: AppRepositories.fake(auth: repository),
          authCubit: cubit,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeListResolutionCallback: resolveBrewSyncLocales,
            routerConfig: createRouter(cubit),
          ),
        ),
      );
    }

    setUp(() {
      repository = FakeAuthRepository(hasStoredSession: true);
      cubit = AuthCubit(repository);
    });

    tearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    testWidgets('shows splash, then home once the session is restored', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.byType(SplashScreen), findsOneWidget);

      await cubit.start();
      await tester.pumpAndSettle();
      expect(find.byType(RecipeListScreen), findsOneWidget);
    });

    testWidgets('tapping Sign out on home signs the user out', (tester) async {
      await pumpApp(tester);
      await cubit.start();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Sign out'));
      await tester.pump();
      expect(cubit.state.status, AuthStatus.unauthenticated);
    });
  });
}
