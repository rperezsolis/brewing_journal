import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../router.dart';
import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
import '../../recipe_list/cubit/recipe_list_cubit.dart';
import '../../teams/cubit/teams_cubit.dart';
import '../cubit/recipe_creation_cubit.dart';
import '../cubit/recipe_creation_state.dart';
import 'step_extraction.dart';
import 'step_flavor.dart';
import 'step_ingredient.dart';
import 'step_instructions.dart';
import 'step_media.dart';

/// The 5-step recipe wizard: a new recipe when [recipeId] is null, otherwise
/// an edit of that recipe.
class RecipeWizardScreen extends StatelessWidget {
  const RecipeWizardScreen({super.key, this.recipeId, this.teamId});

  final UuidValue? recipeId;
  final UuidValue? teamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = RecipeCreationCubit(
          recipes: context.read(),
          ingredients: context.read(),
          media: context.read(),
        );
        final id = recipeId;
        id == null ? cubit.startNew(teamId: teamId) : unawaited(cubit.load(id));
        return cubit;
      },
      child: RecipeWizardView(openedAsEdit: recipeId != null),
    );
  }
}

class RecipeWizardView extends StatelessWidget {
  const RecipeWizardView({super.key, this.openedAsEdit = false});

  /// True when the route was `/recipes/:id/edit`, so Finish replaces the
  /// recipe underneath instead of leaving it on the back stack.
  final bool openedAsEdit;

  static String stepLabel(AppLocalizations l10n, RecipeWizardStep step) =>
      switch (step) {
        RecipeWizardStep.ingredient => l10n.stepBean,
        RecipeWizardStep.extraction => l10n.stepBrew,
        RecipeWizardStep.flavor => l10n.stepFlavor,
        RecipeWizardStep.instructions => l10n.stepSteps,
        RecipeWizardStep.media => l10n.stepPhotos,
      };

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipeCreationCubit, RecipeCreationState>(
      listenWhen: (previous, current) =>
          (current.error != null && previous.error != current.error) ||
          (current.loadStatus == LoadStatus.ready &&
              !current.canEdit &&
              current.recipeId != null),
      listener: (context, state) {
        if (state.loadStatus == LoadStatus.ready &&
            !state.canEdit &&
            state.recipeId != null) {
          context.pushReplacement(
            Routes.recipe(state.recipeId!, teamId: state.teamId),
          );
          return;
        }
        final error = state.error;
        if (error == null) return;
        _showError(context, error, teamId: state.teamId);
        if (error is BrewingException &&
            error.code == BrewingErrorCode.forbidden &&
            state.teamId != null) {
          unawaited(context.read<RecipeCreationCubit>().refreshAccess());
        }
        if (error is BrewingException &&
            error.code == BrewingErrorCode.notFound &&
            state.loadStatus == LoadStatus.failure) {
          _close(context);
        }
      },
      child: BlocBuilder<RecipeCreationCubit, RecipeCreationState>(
        buildWhen: (previous, current) =>
            previous.loadStatus != current.loadStatus ||
            previous.step != current.step ||
            previous.isEditing != current.isEditing,
        builder: (context, state) {
          final l10n = context.l10n;
          return Scaffold(
            appBar: AppBar(
              title: Text(state.isEditing ? l10n.editRecipe : l10n.newRecipe),
              leading: IconButton(
                tooltip: l10n.close,
                icon: const Icon(Icons.close),
                onPressed: () => _close(context),
              ),
            ),
            body: switch (state.loadStatus) {
              LoadStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              LoadStatus.failure => _LoadFailure(recipeId: state.recipeId),
              LoadStatus.ready => SafeArea(
                child: Column(
                  children: [
                    const _StepIndicator(),
                    const Divider(height: 1),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: KeyedSubtree(
                            key: ValueKey(state.step),
                            child: switch (state.step) {
                              RecipeWizardStep.ingredient =>
                                const StepIngredient(),
                              RecipeWizardStep.extraction =>
                                const StepExtraction(),
                              RecipeWizardStep.flavor => const StepFlavor(),
                              RecipeWizardStep.instructions =>
                                const StepInstructions(),
                              RecipeWizardStep.media => const StepMedia(),
                            },
                          ),
                        ),
                      ),
                    ),
                    _BottomBar(openedAsEdit: openedAsEdit),
                  ],
                ),
              ),
            },
          );
        },
      ),
    );
  }

  static void _showError(
    BuildContext context,
    Object error, {
    UuidValue? teamId,
  }) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            errorMessage(
              error,
              context.l10n,
              overrides: {
                if (teamId != null)
                  BrewingErrorCode.forbidden: context.l10n.viewersCantChange,
              },
            ),
            style: TextStyle(color: colors.onErrorContainer),
          ),
          backgroundColor: colors.errorContainer,
        ),
      );
  }
}

void _refreshRecipeLists(BuildContext context) {
  unawaited(context.read<RecipeListCubit>().load());
  if (context.read<RecipeCreationCubit>().state.teamId != null) {
    context.read<TeamsCubit>().recipesChanged();
  }
}

/// Leaves the wizard. Refreshes the home list when a recipe exists, since
/// adding a photo saves a new recipe before Finish.
void _close(BuildContext context, {bool refreshList = true}) {
  if (refreshList &&
      context.read<RecipeCreationCubit>().state.recipeId != null) {
    _refreshRecipeLists(context);
  }
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.home);
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.recipeId});

  final UuidValue? recipeId;

  @override
  Widget build(BuildContext context) {
    final id = recipeId;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.recipeCouldNotBeLoaded),
          const SizedBox(height: 16),
          if (id != null)
            FilledButton(
              onPressed: () => context.read<RecipeCreationCubit>().load(id),
              child: Text(context.l10n.retry),
            ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final current = context.select(
      (RecipeCreationCubit cubit) => cubit.state.step,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          for (final step in RecipeWizardStep.values)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => context.read<RecipeCreationCubit>().goTo(step),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: step.index <= current.index
                            ? colors.primary
                            : colors.surfaceContainerHighest,
                        foregroundColor: step.index <= current.index
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                        child: step.index < current.index
                            ? const Icon(Icons.check, size: 16)
                            : Text('${step.index + 1}'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        RecipeWizardView.stepLabel(context.l10n, step),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: step == current
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.openedAsEdit});

  final bool openedAsEdit;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecipeCreationCubit>();
    return BlocBuilder<RecipeCreationCubit, RecipeCreationState>(
      buildWhen: (previous, current) =>
          previous.step != current.step ||
          previous.saveStatus != current.saveStatus ||
          previous.pendingUpload != current.pendingUpload,
      builder: (context, state) {
        final l10n = context.l10n;
        final busy = state.isSaving || state.pendingUpload;
        return Material(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: state.step.index == 0 || busy ? null : cubit.back,
                  child: Text(l10n.back),
                ),
                const Spacer(),
                if (state.isLastStep)
                  FilledButton.icon(
                    key: const Key('wizard-finish'),
                    onPressed: busy
                        ? null
                        : () => _finish(context, openedAsEdit),
                    icon: state.isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(l10n.finish),
                  )
                else
                  FilledButton(
                    key: const Key('wizard-next'),
                    onPressed: busy ? null : cubit.next,
                    child: Text(l10n.next),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _finish(BuildContext context, bool openedAsEdit) async {
    final cubit = context.read<RecipeCreationCubit>();
    final saved = await cubit.save();
    if (!saved || !context.mounted) return;
    _refreshRecipeLists(context);
    final id = cubit.state.recipeId;
    if (id == null) {
      _close(context, refreshList: false);
      return;
    }
    final router = GoRouter.of(context);
    final route = Routes.recipe(id, teamId: cubit.state.teamId);
    if (openedAsEdit) {
      router.pop();
      router.pushReplacement(route);
    } else {
      router.pushReplacement(route);
    }
  }
}
