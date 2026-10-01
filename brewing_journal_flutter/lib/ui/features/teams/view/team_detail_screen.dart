import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../router.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
import '../../recipe_list/cubit/recipe_list_cubit.dart';
import '../../recipe_list/cubit/recipe_list_state.dart';
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
          actions: [
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
              IconButton(
                key: const Key('team-invite'),
                tooltip: l10n.invite,
                icon: const Icon(Icons.person_add_outlined),
                onPressed: () => showInviteSheet(context, teamId),
              ),
          ],
        ),
        floatingActionButton: isEditor
            ? FloatingActionButton.extended(
                heroTag: 'team-new-recipe',
                key: const Key('team-new-recipe'),
                onPressed: () => _openNewRecipe(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.newRecipe),
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
                  child: FilledButton(
                    onPressed: cubit.load,
                    child: Text(errorMessage(state.error ?? Object(), l10n)),
                  ),
                ),
                RecipeListStatus.success => Center(
                  child: Text(l10n.noRecipesOnTeam),
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
                    onTap: () => _openRecipe(context, recipe.id!),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openNewRecipe(BuildContext context) async {
    await context.push(Routes.newTeamRecipe(teamId));
    if (!context.mounted) return;
    await context.read<RecipeListCubit>().load();
  }

  Future<void> _openRecipe(BuildContext context, UuidValue id) async {
    await context.push(Routes.recipe(id));
    if (!context.mounted) return;
    await context.read<RecipeListCubit>().load();
  }
}
