import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'app_scope.dart';
import 'client.dart';
import 'router.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/auth/cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initializeClient();

  final repositories = AppRepositories();
  final authCubit = AuthCubit(repositories.auth);
  unawaited(authCubit.start());

  runApp(
    AppScope(
      repositories: repositories,
      authCubit: authCubit,
      child: BrewSyncApp(router: createRouter(authCubit)),
    ),
  );
}

class BrewSyncApp extends StatelessWidget {
  const BrewSyncApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BrewSync',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
