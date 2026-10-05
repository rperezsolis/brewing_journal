import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/fake_auth_repository.dart';
import 'data/repositories/fake_ingredient_repository.dart';
import 'data/repositories/fake_recipe_media_repository.dart';
import 'data/repositories/fake_recipe_repository.dart';
import 'data/repositories/fake_team_repository.dart';
import 'data/repositories/ingredient_repository.dart';
import 'data/repositories/recipe_media_repository.dart';
import 'data/repositories/recipe_repository.dart';
import 'data/repositories/serverpod_auth_repository.dart';
import 'data/repositories/serverpod_ingredient_repository.dart';
import 'data/repositories/serverpod_recipe_media_repository.dart';
import 'data/repositories/serverpod_recipe_repository.dart';
import 'data/repositories/serverpod_team_repository.dart';
import 'data/repositories/team_repository.dart';
import 'data/services/alarm_player.dart';
import 'data/services/amplitude_analytics_service.dart';
import 'data/services/analytics_service.dart';
import 'data/services/share_service.dart';
import 'ui/features/auth/cubit/auth_cubit.dart';
import 'ui/features/auth/cubit/auth_state.dart';
import 'ui/features/recipe_list/cubit/recipe_list_cubit.dart';
import 'ui/features/teams/cubit/teams_cubit.dart';

/// App-level repositories, backed by the global Serverpod [client].
class AppRepositories {
  AppRepositories({AnalyticsService? analytics})
    : auth = ServerpodAuthRepository(client.auth),
      ingredients = ServerpodIngredientRepository(client.ingredient),
      recipes = ServerpodRecipeRepository(client.recipe),
      recipeMedia = ServerpodRecipeMediaRepository(client.recipeMedia),
      teams = ServerpodTeamRepository(client.team),
      alarm = AudioAlarmPlayer(),
      share = SharePlusShareService(),
      analytics = analytics ?? AmplitudeAnalyticsService();

  AppRepositories.custom({
    required this.auth,
    required this.ingredients,
    required this.recipes,
    required this.recipeMedia,
    required this.teams,
    required this.alarm,
    required this.share,
    required this.analytics,
  });

  /// In-memory repositories, for tests and previews.
  factory AppRepositories.fake({
    AuthRepository? auth,
    AlarmPlayer? alarm,
    ShareService? share,
    AnalyticsService? analytics,
  }) {
    final ingredients = FakeIngredientRepository();
    return AppRepositories.custom(
      auth: auth ?? FakeAuthRepository(),
      ingredients: ingredients,
      recipes: FakeRecipeRepository(ingredients),
      recipeMedia: FakeRecipeMediaRepository(),
      teams: FakeTeamRepository(),
      alarm: alarm ?? FakeAlarmPlayer(),
      share: share ?? FakeShareService(),
      analytics: analytics ?? const NoOpAnalyticsService(),
    );
  }

  final AuthRepository auth;
  final IngredientRepository ingredients;
  final RecipeRepository recipes;
  final RecipeMediaRepository recipeMedia;
  final TeamRepository teams;
  final AlarmPlayer alarm;
  final ShareService share;
  final AnalyticsService analytics;
}

/// Provides the app-level repositories and session-scoped Cubits to every
/// route. The [authCubit] is created outside so the router can share it.
///
/// The personal [RecipeListCubit] loads when the user signs in and resets
/// when they sign out, so one account never sees another account's recipes.
class AppScope extends StatefulWidget {
  const AppScope({
    super.key,
    required this.repositories,
    required this.authCubit,
    required this.child,
  });

  final AppRepositories repositories;
  final AuthCubit authCubit;
  final Widget child;

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final RecipeListCubit _recipeList;
  late final TeamsCubit _teams;
  late final StreamSubscription<AuthState> _authSubscription;
  AuthStatus? _lastStatus;
  var _trackedAppOpen = false;

  @override
  void initState() {
    super.initState();
    _recipeList = RecipeListCubit(widget.repositories.recipes);
    _teams = TeamsCubit(widget.repositories.teams);
    _authSubscription = widget.authCubit.stream.listen(_onAuthChanged);
    _onAuthChanged(widget.authCubit.state);
  }

  void _onAuthChanged(AuthState auth) {
    if (auth.status == _lastStatus) return;
    final previous = _lastStatus;
    _lastStatus = auth.status;
    switch (auth.status) {
      case AuthStatus.authenticated:
        unawaited(_recipeList.load());
        unawaited(_teams.load());
      case AuthStatus.unauthenticated:
        _recipeList.reset();
        _teams.reset();
      case AuthStatus.unknown:
        break;
    }
    if (auth.status != AuthStatus.unknown) {
      unawaited(_syncAnalytics(auth.status, previous));
    }
  }

  /// Binds the Amplitude user id to the Serverpod account, then records
  /// `App Opened` once per process after the session is known.
  Future<void> _syncAnalytics(AuthStatus status, AuthStatus? previous) async {
    final shouldTrack = !_trackedAppOpen;
    if (shouldTrack) _trackedAppOpen = true;

    final analytics = widget.repositories.analytics;
    if (status == AuthStatus.authenticated) {
      final userId = widget.repositories.auth.currentUserId?.uuid;
      if (userId != null) await analytics.setUserId(userId);
    } else if (previous == AuthStatus.authenticated) {
      await analytics.reset();
    }

    if (shouldTrack) {
      await analytics.trackAppOpened(
        signedIn: status == AuthStatus.authenticated,
      );
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _recipeList.close();
    _teams.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repositories = widget.repositories;
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: repositories.auth),
        RepositoryProvider<IngredientRepository>.value(
          value: repositories.ingredients,
        ),
        RepositoryProvider<RecipeRepository>.value(
          value: repositories.recipes,
        ),
        RepositoryProvider<RecipeMediaRepository>.value(
          value: repositories.recipeMedia,
        ),
        RepositoryProvider<TeamRepository>.value(value: repositories.teams),
        RepositoryProvider<AlarmPlayer>.value(value: repositories.alarm),
        RepositoryProvider<ShareService>.value(value: repositories.share),
        RepositoryProvider<AnalyticsService>.value(
          value: repositories.analytics,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: widget.authCubit),
          BlocProvider<RecipeListCubit>.value(value: _recipeList),
          BlocProvider<TeamsCubit>.value(value: _teams),
        ],
        child: widget.child,
      ),
    );
  }
}
