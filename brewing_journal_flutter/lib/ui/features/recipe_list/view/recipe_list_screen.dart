import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../router.dart';
import '../../../core/analytics/screen_names.dart';
import '../../../core/analytics/tracked_button.dart';
import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
import '../../../core/widgets/favorite_icon_button.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/recipe_list_cubit.dart';
import '../cubit/recipe_list_state.dart';
import 'favorite_actions.dart';
import 'recipe_tile.dart';

/// Home: the signed-in user's recipes.
class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          BlocBuilder<RecipeListCubit, RecipeListState>(
            buildWhen: (previous, current) =>
                previous.favoritesOnly != current.favoritesOnly,
            builder: (context, state) {
              return FavoriteIconButton(
                key: const Key('recipe-list-favorites'),
                selected: state.favoritesOnly,
                tooltip: state.favoritesOnly
                    ? l10n.showAllRecipes
                    : l10n.showFavorites,
                onPressed: () => context
                    .read<RecipeListCubit>()
                    .setFavoritesOnly(!state.favoritesOnly),
              );
            },
          ),
          TrackedButton(
            buttonLabel: 'sign_out',
            buttonAction: 'sign_out',
            currentScreen: ScreenNames.recipeList,
            onPressed: () => context.read<AuthCubit>().signOut(),
            builder: (context, onPressed) => IconButton(
              key: const ValueKey('sign-out'),
              tooltip: l10n.signOut,
              icon: const Icon(Icons.logout),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
      floatingActionButton: TrackedButton(
        buttonLabel: 'new_recipe',
        buttonAction: 'open_recipe_wizard',
        currentScreen: ScreenNames.recipeList,
        onPressed: () => context.push(Routes.newRecipe),
        builder: (context, onPressed) => FloatingActionButton.extended(
          heroTag: 'recipe-list-new',
          key: const Key('recipe-list-new'),
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: Text(l10n.newRecipe),
        ),
      ),
      body: BlocBuilder<RecipeListCubit, RecipeListState>(
        builder: (context, state) {
          final cubit = context.read<RecipeListCubit>();
          if (state.recipes.isEmpty) {
            return switch (state.status) {
              RecipeListStatus.initial ||
              RecipeListStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              RecipeListStatus.failure => _Message(
                text: errorMessage(state.error ?? Object(), l10n),
                action: TrackedButton(
                  buttonLabel: 'retry',
                  buttonAction: 'reload_recipes',
                  currentScreen: ScreenNames.recipeList,
                  onPressed: cubit.load,
                  builder: (context, onPressed) => FilledButton(
                    onPressed: onPressed,
                    child: Text(l10n.retry),
                  ),
                ),
              ),
              RecipeListStatus.success => _Message(
                text: state.favoritesOnly
                    ? l10n.noFavoriteRecipes
                    : l10n.noRecipesYet,
                detail: state.favoritesOnly
                    ? l10n.noFavoriteRecipesDetail
                    : l10n.noRecipesYetDetail,
              ),
            };
          }
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 300) cubit.loadMore();
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: state.recipes.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.recipes.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final recipe = state.recipes[index];
                  return RecipeTile(
                    recipe: recipe,
                    favoriteBusy: state.favoriteBusyIds.contains(recipe.id),
                    onTap: () => context.push(Routes.recipe(recipe.id!)),
                    onFavorite: () {
                      unawaited(_toggleFavorite(context, recipe));
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _toggleFavorite(BuildContext context, Recipe recipe) {
  final cubit = context.read<RecipeListCubit>();
  return toggleRecipeFavorite(
    context: context,
    recipe: recipe,
    save: ({required replace}) =>
        cubit.saveFavorite(recipe.id!, replace: replace),
    remove: () => cubit.removeFavorite(recipe.id!),
    onError: (error) => showFavoriteError(context, error),
    readError: () => cubit.state.error,
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.detail, this.action});

  final String text;
  final String? detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_cafe_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(detail!, textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
