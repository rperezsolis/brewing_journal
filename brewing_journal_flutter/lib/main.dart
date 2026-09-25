import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_scope.dart';
import 'client.dart';
import 'router.dart';
import 'ui/features/auth/cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

/// Builds a theme for the given [brightness].
ThemeData _buildTheme(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
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
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
