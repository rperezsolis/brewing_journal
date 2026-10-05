import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_route_observer.dart';
import '../../../core/analytics/screen_names.dart';
import '../../../core/l10n.dart';

/// Tab shell for My recipes and Teams. Recipe and invite routes sit on the
/// root navigator so they cover this bar.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index);
          // The branch navigator is already built on the way back to a tab,
          // so the route observer sees no push. Record the visible tab here.
          final screen = switch (index) {
            0 => ScreenNames.recipeList,
            1 => ScreenNames.teams,
            _ => null,
          };
          if (screen == null) return;
          final AnalyticsRouteObserver observer;
          try {
            observer = context.read<AnalyticsRouteObserver>();
          } on ProviderNotFoundException {
            return;
          }
          observer.noteBranch(screen);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.coffee_outlined),
            selectedIcon: const Icon(Icons.coffee),
            label: context.l10n.myRecipes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: context.l10n.teams,
          ),
        ],
      ),
    );
  }
}
