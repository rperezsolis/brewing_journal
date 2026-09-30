import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        onDestinationSelected: navigationShell.goBranch,
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
