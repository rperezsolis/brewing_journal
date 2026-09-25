import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/features/auth/cubit/auth_cubit.dart';
import 'ui/features/auth/cubit/auth_state.dart';
import 'ui/features/auth/view/sign_in_screen.dart';
import 'ui/features/auth/view/splash_screen.dart';
import 'ui/features/home/view/home_screen.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const home = '/';
}

GoRouter createRouter(AuthCubit auth) {
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: GoRouterRefreshStream(auth.stream),
    redirect: (context, state) => authRedirect(auth.state.status, state.uri),
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );
}

/// Sends the user to `/splash` or `/sign-in` until they are signed in, and
/// carries the original location as `from` on every hop so it survives both.
String? authRedirect(AuthStatus status, Uri uri) {
  final path = uri.path;
  final onGate = path == Routes.splash || path == Routes.signIn;
  final target = onGate ? _safeFrom(uri) : uri.toString();

  switch (status) {
    case AuthStatus.unknown:
      return path == Routes.splash ? null : _withFrom(Routes.splash, target);
    case AuthStatus.unauthenticated:
      return path == Routes.signIn ? null : _withFrom(Routes.signIn, target);
    case AuthStatus.authenticated:
      return onGate ? (target ?? Routes.home) : null;
  }
}

/// Only in-app paths are accepted, so `from` can't point outside the app.
String? _safeFrom(Uri uri) {
  final from = uri.queryParameters['from'];
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  return from;
}

String _withFrom(String path, String? from) {
  if (from == null || from == Routes.home) return path;
  return Uri(path: path, queryParameters: {'from': from}).toString();
}

/// Adapts a [Stream] to the [Listenable] that `refreshListenable` expects.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BrewSync')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This page does not exist.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}
