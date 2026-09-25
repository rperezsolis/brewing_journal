import 'package:brewing_journal_flutter/data/repositories/fake_auth_repository.dart';
import 'package:brewing_journal_flutter/router.dart';
import 'package:brewing_journal_flutter/ui/features/auth/cubit/auth_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/auth/cubit/auth_state.dart';
import 'package:brewing_journal_flutter/ui/features/auth/view/splash_screen.dart';
import 'package:brewing_journal_flutter/ui/features/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? redirect(AuthStatus status, String location) =>
      authRedirect(status, Uri.parse(location));

  group('authRedirect while unknown', () {
    test('sends a deep link to splash, keeping it as from', () {
      expect(
        redirect(AuthStatus.unknown, '/invite/abc'),
        '/splash?from=%2Finvite%2Fabc',
      );
    });

    test('sends home to splash without from', () {
      expect(redirect(AuthStatus.unknown, '/'), '/splash');
    });

    test('stays on splash', () {
      expect(redirect(AuthStatus.unknown, '/splash?from=%2Fx'), isNull);
    });
  });

  group('authRedirect while unauthenticated', () {
    test('keeps from when leaving splash', () {
      expect(
        redirect(AuthStatus.unauthenticated, '/splash?from=%2Fsome%2Fpath'),
        '/sign-in?from=%2Fsome%2Fpath',
      );
    });

    test('sends a protected route to sign-in with from', () {
      expect(
        redirect(AuthStatus.unauthenticated, '/some/path?q=1'),
        '/sign-in?from=%2Fsome%2Fpath%3Fq%3D1',
      );
    });

    test('stays on sign-in', () {
      expect(redirect(AuthStatus.unauthenticated, '/sign-in'), isNull);
    });
  });

  group('authRedirect while authenticated', () {
    test('goes from sign-in to from', () {
      expect(
        redirect(AuthStatus.authenticated, '/sign-in?from=%2Fsome%2Fpath'),
        '/some/path',
      );
    });

    test('goes from splash to home when there is no from', () {
      expect(redirect(AuthStatus.authenticated, '/splash'), '/');
    });

    test('ignores a from that leaves the app', () {
      expect(
        redirect(AuthStatus.authenticated, '/sign-in?from=https://evil.com'),
        '/',
      );
      expect(
        redirect(AuthStatus.authenticated, '/sign-in?from=%2F%2Fevil.com'),
        '/',
      );
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
        BlocProvider.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: createRouter(cubit)),
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
      expect(find.byType(HomeScreen), findsOneWidget);
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
