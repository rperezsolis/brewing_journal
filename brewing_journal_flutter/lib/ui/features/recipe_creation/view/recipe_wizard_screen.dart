import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error_messages.dart';
import '../../recipe_list/cubit/recipe_list_cubit.dart';
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
  const RecipeWizardScreen({super.key, this.recipeId});

  final UuidValue? recipeId;

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
        id == null ? cubit.startNew() : unawaited(cubit.load(id));
        return cubit;
      },
      child: const RecipeWizardView(),
    );
  }
}

class RecipeWizardView extends StatelessWidget {
  const RecipeWizardView({super.key});

  static const stepLabels = {
    RecipeWizardStep.ingredient: 'Bean',
    RecipeWizardStep.extraction: 'Brew',
    RecipeWizardStep.flavor: 'Flavor',
    RecipeWizardStep.instructions: 'Steps',
    RecipeWizardStep.media: 'Photos',
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipeCreationCubit, RecipeCreationState>(
      listenWhen: (previous, current) =>
          current.error != null && previous.error != current.error,
      listener: (context, state) {
        final error = state.error!;
        _showError(context, error);
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
          return Scaffold(
            appBar: AppBar(
              title: Text(state.isEditing ? 'Edit recipe' : 'New recipe'),
              leading: IconButton(
                tooltip: 'Close',
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
                    const _BottomBar(),
                  ],
                ),
              ),
            },
          );
        },
      ),
    );
  }

  static void _showError(BuildContext context, Object error) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            errorMessage(error),
            style: TextStyle(color: colors.onErrorContainer),
          ),
          backgroundColor: colors.errorContainer,
        ),
      );
  }
}

/// Leaves the wizard. Refreshes the home list when a recipe exists, since
/// adding a photo saves a new recipe before Finish.
void _close(BuildContext context) {
  if (context.read<RecipeCreationCubit>().state.recipeId != null) {
    unawaited(context.read<RecipeListCubit>().load());
  }
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/');
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
          const Text("This recipe couldn't be loaded."),
          const SizedBox(height: 16),
          if (id != null)
            FilledButton(
              onPressed: () => context.read<RecipeCreationCubit>().load(id),
              child: const Text('Retry'),
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
                        RecipeWizardView.stepLabels[step]!,
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
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecipeCreationCubit>();
    return BlocBuilder<RecipeCreationCubit, RecipeCreationState>(
      buildWhen: (previous, current) =>
          previous.step != current.step ||
          previous.saveStatus != current.saveStatus ||
          previous.pendingUpload != current.pendingUpload,
      builder: (context, state) {
        final busy = state.isSaving || state.pendingUpload;
        return Material(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: state.step.index == 0 || busy ? null : cubit.back,
                  child: const Text('Back'),
                ),
                const Spacer(),
                if (state.isLastStep)
                  FilledButton.icon(
                    key: const Key('wizard-finish'),
                    onPressed: busy ? null : () => _finish(context),
                    icon: state.isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Finish'),
                  )
                else
                  FilledButton(
                    key: const Key('wizard-next'),
                    onPressed: busy ? null : cubit.next,
                    child: const Text('Next'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _finish(BuildContext context) async {
    final saved = await context.read<RecipeCreationCubit>().save();
    if (saved && context.mounted) _close(context);
  }
}
