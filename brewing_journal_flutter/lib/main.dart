import 'dart:async';

import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'app_scope.dart';
import 'client.dart';
import 'data/services/amplitude_analytics_service.dart';
import 'data/services/analytics_service.dart';
import 'data/services/flutter_test_env_stub.dart'
    if (dart.library.io) 'data/services/flutter_test_env_io.dart';
import 'router.dart';
import 'ui/core/analytics/analytics_route_observer.dart';
import 'ui/core/l10n.dart';
import 'ui/core/locale_resolution.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/auth/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initializeClient();

  final AnalyticsService analytics = isFlutterTestEnvironment
      ? const NoOpAnalyticsService()
      : AmplitudeAnalyticsService();
  await analytics.start();
  final repositories = AppRepositories(analytics: analytics);
  final authCubit = AuthCubit(repositories.auth);
  unawaited(authCubit.start());
  final routeObserver = AnalyticsRouteObserver(analytics);

  runApp(
    AppScope(
      repositories: repositories,
      authCubit: authCubit,
      child: BrewSyncApp(
        router: createRouter(authCubit, observers: [routeObserver]),
        routeObserver: routeObserver,
      ),
    ),
  );
}

class BrewSyncApp extends StatelessWidget {
  const BrewSyncApp({super.key, required this.router, this.routeObserver});

  final GoRouter router;

  /// Reports screen views for this [router]. Null in tests that build the
  /// app without analytics.
  final AnalyticsRouteObserver? routeObserver;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: resolveBrewSyncLocales,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
    final observer = routeObserver;
    if (observer == null) return app;
    return RepositoryProvider<AnalyticsRouteObserver>.value(
      value: observer,
      child: app,
    );
  }
}
