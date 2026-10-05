import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../data/services/analytics_service.dart';
import 'screen_names.dart';

/// Fallback `navigation_source` values used when the previous route has no name.
abstract final class NavigationSources {
  static const appStart = 'app_start';
  static const push = 'push';
  static const replace = 'replace';
}

/// Reports `screen_view` for named pages on a GoRouter navigator.
///
/// Pass one instance to `GoRouter.observers`. GoRouter forwards shell-branch
/// navigations to that list, so tab roots are included. Dialogs and the
/// unnamed shell page are ignored.
///
/// Switching back to a tab that is already built does not push a route.
/// [noteBranch] records that change. Call it after `goBranch`.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final AnalyticsService _analytics;

  /// Tab roots. Moving between these replaces the visible screen instead of
  /// pushing, so a later pop still returns to the tab the user is on.
  static const _branchScreens = <String>{
    ScreenNames.recipeList,
    ScreenNames.teams,
  };

  final List<String> _stack = [];
  String? _visible;

  /// The screen currently treated as visible.
  String? get currentScreen => _visible;

  /// Records a shell-branch change that did not push a new route.
  void noteBranch(String screenName) {
    if (screenName.isEmpty || screenName == _visible) return;
    _showNamed(
      screenName,
      navigationSource: _visible ?? NavigationSources.push,
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _show(
      route,
      navigationSource:
          _screenName(previousRoute) ?? _visible ?? NavigationSources.appStart,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _hide(route, revealed: previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _hide(route, revealed: previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final source =
        _screenName(oldRoute) ?? _visible ?? NavigationSources.replace;
    if (oldRoute != null) _drop(oldRoute);
    if (newRoute == null) return;
    _show(newRoute, navigationSource: source);
  }

  void _show(Route<dynamic> route, {required String navigationSource}) {
    final name = _screenName(route);
    if (name == null) return;
    _showNamed(name, navigationSource: navigationSource);
  }

  void _showNamed(String name, {required String navigationSource}) {
    if (name == _visible) return;
    if (_stack.isNotEmpty && _isBranch(_stack.last) && _isBranch(name)) {
      _stack[_stack.length - 1] = name;
    } else {
      _stack.add(name);
    }
    _visible = name;
    _emit(name, navigationSource);
  }

  void _hide(Route<dynamic> route, {required Route<dynamic>? revealed}) {
    if (route is PopupRoute<dynamic>) return;
    final popped = _screenName(route);
    if (popped == null) return;
    final before = _visible;
    _drop(route);
    final revealedName = _screenName(revealed) ?? _visible;
    if (revealedName == null || revealedName == before) return;
    if (_visible != revealedName) {
      _stack.add(revealedName);
      _visible = revealedName;
    }
    _emit(revealedName, popped);
  }

  void _drop(Route<dynamic> route) {
    final name = _screenName(route);
    if (name == null) return;
    final index = _stack.lastIndexOf(name);
    if (index == -1) return;
    _stack.removeAt(index);
    if (_visible == name) {
      _visible = _stack.isEmpty ? null : _stack.last;
    }
  }

  void _emit(String screenName, String navigationSource) {
    _report(
      () => _analytics.trackScreenView(
        screenName: screenName,
        navigationSource: navigationSource,
      ),
    );
  }

  bool _isBranch(String name) => _branchScreens.contains(name);

  String? _screenName(Route<dynamic>? route) {
    if (route == null || route is PopupRoute<dynamic>) return null;
    if (route is! PageRoute<dynamic>) return null;
    final name = route.settings.name;
    if (name == null || name.isEmpty) return null;
    return name;
  }
}

void _report(Future<void> Function() send) {
  unawaited(() async {
    try {
      await send();
    } catch (_) {
      // Analytics must not break navigation.
    }
  }());
}
