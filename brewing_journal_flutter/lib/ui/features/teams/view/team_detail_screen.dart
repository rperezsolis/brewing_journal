import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../router.dart';
import '../../../core/analytics/screen_names.dart';
import '../../../core/analytics/tracked_button.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
import '../../recipe_list/cubit/recipe_list_cubit.dart';
import '../../recipe_list/cubit/recipe_list_state.dart';
import '../../../core/widgets/favorite_icon_button.dart';
import '../../recipe_list/view/favorite_actions.dart';
import '../../recipe_list/view/recipe_tile.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import 'invite_sheet.dart';

class TeamDetailScreen extends StatelessWidget {
  const TeamDetailScreen({super.key, required this.teamId});

  final UuidValue teamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipeListCubit(context.read(), teamId: teamId),
      child: _TeamDetailView(teamId: teamId),
    );
  }
}

class _TeamDetailView extends StatefulWidget {
  const _TeamDetailView({required this.teamId});

  final UuidValue teamId;

  @override
  State<_TeamDetailView> createState() => _TeamDetailViewState();
}

class _TeamDetailViewState extends State<_TeamDetailView> {
  /// The Teams tab is kept alive by [StatefulShellRoute.indexedStack], so
  /// this cubit is not recreated when the user leaves and comes back.
  /// [Visibility.of] is false while that tab is hidden.
  bool _visible = false;

  UuidValue get teamId => widget.teamId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = Visibility.of(context);
    if (visible && !_visible) {
      _visible = true;
      unawaited(context.read<RecipeListCubit>().load());
    } else if (!visible) {
      _visible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = context.select(
      (TeamsCubit cubit) => cubit.state.teamById(teamId),
    );
    final userId = context.read<AuthRepository>().currentUserId;
    final isOwner = summary?.team.ownerId == userId;
    final l10n = context.l10n;
    final isEditor = summary?.role == TeamRole.editor;
    final favoritesEnabled = summary != null && isEditor;
    final name = summary?.team.name ?? l10n.teamFallback;

    return BlocListener<TeamsCubit, TeamsState>(
      listenWhen: (previous, current) =>
          previous.recipeRevision != current.recipeRevision,
      listener: (context, state) {
        unawaited(context.read<RecipeListCubit>().load());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
          leading: _backButton(context),
          actions: [
            BlocBuilder<RecipeListCubit, RecipeListState>(
              buildWhen: (previous, current) =>
                  previous.favoritesOnly != current.favoritesOnly,
              builder: (context, state) {
                return TrackedButton(
                  buttonLabel: 'favorites_filter',
                  buttonAction: state.favoritesOnly
                      ? 'show_all_recipes'
                      : 'show_favorites',
                  currentScreen: ScreenNames.teamDetail,
                  onPressed: () => context
                      .read<RecipeListCubit>()
                      .setFavoritesOnly(!state.favoritesOnly),
                  builder: (context, onPressed) => FavoriteIconButton(
                    key: const Key('team-list-favorites'),
                    selected: state.favoritesOnly,
                    tooltip: state.favoritesOnly
                        ? l10n.showAllTeamRecipes
                        : l10n.showTeamFavorites,
                    onPressed: onPressed,
                  ),
                );
              },
            ),
            if (summary != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Chip(
                    label: Text(summary.role.label(l10n)),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            if (isOwner)
              TrackedButton(
                buttonLabel: 'invite',
                buttonAction: 'open_invite_sheet',
                currentScreen: ScreenNames.teamDetail,
                onPressed: () => showInviteSheet(context, teamId),
                builder: (context, onPressed) => IconButton(
                  key: const Key('team-invite'),
                  tooltip: l10n.invite,
                  icon: const Icon(Icons.person_add_outlined),
                  onPressed: onPressed,
                ),
              ),
          ],
        ),
        floatingActionButton: isEditor
            ? TrackedButton(
                buttonLabel: 'new_recipe',
                buttonAction: 'open_recipe_wizard',
                currentScreen: ScreenNames.teamDetail,
                onPressed: () => _openNewRecipe(context),
                builder: (context, onPressed) => FloatingActionButton.extended(
                  heroTag: 'team-new-recipe',
                  key: const Key('team-new-recipe'),
                  onPressed: onPressed,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.newRecipe),
                ),
              )
            : null,
        body: BlocBuilder<RecipeListCubit, RecipeListState>(
          builder: (context, state) {
            final cubit = context.read<RecipeListCubit>();
            if (state.recipes.isEmpty) {
              return switch (state.status) {
                RecipeListStatus.initial ||
                RecipeListStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                RecipeListStatus.failure => Center(
                  child: TrackedButton(
                    buttonLabel: 'retry',
                    buttonAction: 'reload_recipes',
                    currentScreen: ScreenNames.teamDetail,
                    onPressed: cubit.load,
                    builder: (context, onPressed) => FilledButton(
                      onPressed: onPressed,
                      child: Text(errorMessage(state.error ?? Object(), l10n)),
                    ),
                  ),
                ),
                RecipeListStatus.success => Center(
                  child: state.favoritesOnly
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.noTeamFavoriteRecipes),
                            const SizedBox(height: 8),
                            Text(
                              l10n.noTeamFavoriteRecipesDetail,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : Text(l10n.noRecipesOnTeam),
                ),
              };
            }
            return RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: state.recipes.length,
                itemBuilder: (context, index) {
                  final recipe = state.recipes[index];
                  return RecipeTile(
                    recipe: recipe,
                    favoriteBusy: state.favoriteBusyIds.contains(recipe.id),
                    favoriteEnabled: favoritesEnabled,
                    currentScreen: ScreenNames.teamDetail,
                    onTap: () => _openRecipe(context, recipe.id!),
                    onFavorite: () {
                      unawaited(_toggleFavorite(context, recipe));
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, Recipe recipe) {
    final cubit = context.read<RecipeListCubit>();
    return toggleRecipeFavorite(
      context: context,
      recipe: recipe,
      save: ({required replace}) =>
          cubit.saveFavorite(recipe.id!, replace: replace),
      remove: () => cubit.removeFavorite(recipe.id!),
      onError: (error) => showFavoriteError(context, error, team: true),
      readError: () => cubit.state.error,
      currentScreen: ScreenNames.teamDetail,
      team: true,
    );
  }

  Widget? _backButton(BuildContext context) {
    if (!Navigator.canPop(context)) return null;
    return TrackedButton(
      buttonLabel: 'back',
      buttonAction: 'navigate_back',
      currentScreen: ScreenNames.teamDetail,
      onPressed: () => Navigator.maybePop(context),
      builder: (context, onPressed) => BackButton(onPressed: onPressed),
    );
  }

  Future<void> _openNewRecipe(BuildContext context) async {
    await context.push(Routes.newTeamRecipe(teamId));
    if (!context.mounted) return;
    await context.read<RecipeListCubit>().load();
  }

  Future<void> _openRecipe(BuildContext context, UuidValue id) async {
    await context.push(Routes.recipe(id, teamId: teamId));
    if (!context.mounted) return;
    await context.read<RecipeListCubit>().load();
  }
}
