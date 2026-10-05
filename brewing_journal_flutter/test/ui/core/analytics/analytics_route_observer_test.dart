import 'package:brewing_journal_flutter/app_scope.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_auth_repository.dart';
import 'package:brewing_journal_flutter/data/services/analytics_service.dart';
import 'package:brewing_journal_flutter/main.dart';
import 'package:brewing_journal_flutter/router.dart';
import 'package:brewing_journal_flutter/ui/core/analytics/analytics_route_observer.dart';
import 'package:brewing_journal_flutter/ui/core/analytics/screen_names.dart';
import 'package:brewing_journal_flutter/ui/features/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsRouteObserver', () {
    late _RecordingAnalytics analytics;
    late AnalyticsRouteObserver observer;

    setUp(() {
      analytics = _RecordingAnalytics();
      observer = AnalyticsRouteObserver(analytics);
    });

    test('records a push, a nested page, and the page revealed by pop', () {
      observer.didPush(_page(ScreenNames.splash), null);
      observer.didPush(
        _page(ScreenNames.recipeList),
        _page(ScreenNames.splash),
      );
      observer.didPush(_page(ScreenNames.brewMode), _page(null));
      observer.didPop(_page(ScreenNames.brewMode), _page(null));

      expect(analytics.screens, [
        (ScreenNames.splash, NavigationSources.appStart),
        (ScreenNames.recipeList, ScreenNames.splash),
        (ScreenNames.brewMode, ScreenNames.recipeList),
        (ScreenNames.recipeList, ScreenNames.brewMode),
      ]);
    });

    test('ignores dialogs, unnamed pages, and a repeated screen', () {
      observer.didPush(_page(ScreenNames.recipeList), null);
      observer.didPush(_page(ScreenNames.recipeList), null);
      observer.didPush(_page(null), null);
      observer.didPush(_dialog(), _page(ScreenNames.recipeList));
      observer.didPop(_dialog(), _page(ScreenNames.recipeList));

      expect(analytics.screens, [
        (ScreenNames.recipeList, NavigationSources.appStart),
      ]);
    });

    test('replacing a route uses the old screen as the source', () {
      observer.didPush(_page(ScreenNames.splash), null);
      observer.didReplace(
        newRoute: _page(ScreenNames.signIn),
        oldRoute: _page(ScreenNames.splash),
      );

      expect(analytics.screens, [
        (ScreenNames.splash, NavigationSources.appStart),
        (ScreenNames.signIn, ScreenNames.splash),
      ]);
    });

    test('noteBranch records a return to a tab that is already built', () {
      observer.didPush(_page(ScreenNames.recipeList), null);
      observer.didPush(_page(ScreenNames.teams), _page(null));
      observer.noteBranch(ScreenNames.teams);
      observer.noteBranch(ScreenNames.recipeList);

      expect(analytics.screens, [
        (ScreenNames.recipeList, NavigationSources.appStart),
        (ScreenNames.teams, ScreenNames.recipeList),
        (ScreenNames.recipeList, ScreenNames.teams),
      ]);
    });
  });

  testWidgets('GoRouter screen views follow splash, tabs, and a pushed page', (
    tester,
  ) async {
    final analytics = _RecordingAnalytics();
    final auth = FakeAuthRepository(hasStoredSession: true);
    final cubit = AuthCubit(auth);
    final observer = AnalyticsRouteObserver(analytics);
    final router = createRouter(cubit, observers: [observer]);
    addTearDown(() async {
      router.dispose();
      await cubit.close();
      await auth.dispose();
    });

    await tester.pumpWidget(
      AppScope(
        repositories: AppRepositories.fake(auth: auth, analytics: analytics),
        authCubit: cubit,
        child: BrewSyncApp(router: router, routeObserver: observer),
      ),
    );

    expect(analytics.screenNames, [ScreenNames.splash]);

    await cubit.start();
    await tester.pumpAndSettle();

    expect(analytics.screenNames, [
      ScreenNames.splash,
      ScreenNames.recipeList,
    ]);

    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My recipes'));
    await tester.pumpAndSettle();

    expect(analytics.screenNames, [
      ScreenNames.splash,
      ScreenNames.recipeList,
      ScreenNames.teams,
      ScreenNames.recipeList,
    ]);

    await tester.tap(find.byKey(const Key('recipe-list-new')));
    await tester.pumpAndSettle();

    expect(analytics.buttons.single, (
      'new_recipe',
      'open_recipe_wizard',
      ScreenNames.recipeList,
    ));
    expect(analytics.screenNames.last, ScreenNames.recipeCreate);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(analytics.screenNames.last, ScreenNames.recipeList);
    expect(
      analytics.screens.last.$2,
      ScreenNames.recipeCreate,
    );
  });
}

MaterialPageRoute<void> _page(String? name) {
  return MaterialPageRoute<void>(
    settings: RouteSettings(name: name),
    builder: (_) => const SizedBox.shrink(),
  );
}

class _DialogRoute extends PopupRoute<void> {
  _DialogRoute() : super(settings: const RouteSettings(name: 'dialog'));

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const SizedBox.shrink();
  }
}

PopupRoute<void> _dialog() => _DialogRoute();

class _RecordingAnalytics implements AnalyticsService {
  final screens = <(String, String)>[];
  final buttons = <(String, String, String)>[];

  List<String> get screenNames => [for (final screen in screens) screen.$1];

  @override
  Future<void> start() async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> reset() async {}

  @override
  Future<void> trackAppOpened({required bool signedIn}) async {}

  @override
  Future<void> trackScreenView({
    required String screenName,
    required String navigationSource,
  }) async {
    screens.add((screenName, navigationSource));
  }

  @override
  Future<void> trackButtonTapped({
    required String buttonLabel,
    required String buttonAction,
    required String currentScreen,
  }) async {
    buttons.add((buttonLabel, buttonAction, currentScreen));
  }
}
