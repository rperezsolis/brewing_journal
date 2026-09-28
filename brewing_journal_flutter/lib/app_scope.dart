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
import 'ui/features/auth/cubit/auth_cubit.dart';
import 'ui/features/auth/cubit/auth_state.dart';
import 'ui/features/recipe_list/cubit/recipe_list_cubit.dart';
import 'ui/features/teams/cubit/teams_cubit.dart';

/// App-level repositories, backed by the global Serverpod [client].
class AppRepositories {
  AppRepositories()
    : auth = ServerpodAuthRepository(client.auth),
      ingredients = ServerpodIngredientRepository(client.ingredient),
      recipes = ServerpodRecipeRepository(client.recipe),
      recipeMedia = ServerpodRecipeMediaRepository(client.recipeMedia),
      teams = ServerpodTeamRepository(client.team),
      alarm = AudioAlarmPlayer();

  AppRepositories.custom({
    required this.auth,
    required this.ingredients,
    required this.recipes,
    required this.recipeMedia,
    required this.teams,
    required this.alarm,
  });

  /// In-memory repositories, for tests and previews.
  factory AppRepositories.fake({AuthRepository? auth, AlarmPlayer? alarm}) {
    final ingredients = FakeIngredientRepository();
    return AppRepositories.custom(
      auth: auth ?? FakeAuthRepository(),
      ingredients: ingredients,
      recipes: FakeRecipeRepository(ingredients),
      recipeMedia: FakeRecipeMediaRepository(),
      teams: FakeTeamRepository(),
      alarm: alarm ?? FakeAlarmPlayer(),
    );
  }

  final AuthRepository auth;
  final IngredientRepository ingredients;
  final RecipeRepository recipes;
  final RecipeMediaRepository recipeMedia;
  final TeamRepository teams;
  final AlarmPlayer alarm;
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
