import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../router.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/duration_format.dart';
import '../../../core/error_messages.dart';
import '../../../core/l10n.dart';
import '../../../core/widgets/favorite_icon_button.dart';
import '../../../core/widgets/flavor_radar_chart.dart';
import '../../recipe_detail/cubit/recipe_detail_cubit.dart';
import '../../recipe_detail/cubit/recipe_detail_state.dart';
import '../../recipe_list/cubit/recipe_list_cubit.dart';
import '../../recipe_list/view/favorite_actions.dart';
import '../../teams/cubit/teams_cubit.dart';
import '../cubit/brew_timer_cubit.dart';
import '../cubit/brew_timer_state.dart';

/// Read-only brew session for a saved recipe, with an optional timer.
class BrewModeScreen extends StatelessWidget {
  const BrewModeScreen({super.key, required this.recipeId});

  final UuidValue recipeId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              RecipeDetailCubit(context.read())..load(recipeId),
        ),
        BlocProvider(create: (context) => BrewTimerCubit(context.read())),
      ],
      child: const BrewModeView(),
    );
  }
}

class BrewModeView extends StatefulWidget {
  const BrewModeView({super.key});

  @override
  State<BrewModeView> createState() => _BrewModeViewState();
}

class _BrewModeViewState extends State<BrewModeView> {
  late final AppLifecycleListener _lifecycle;

  Map<BrewingErrorCode, String> _notFoundOverride(BuildContext context) => {
    BrewingErrorCode.notFound: context.l10n.recipeNotFoundOrUnshared,
  };

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _onHide);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _onHide() {
    final timer = context.read<BrewTimerCubit>();
    switch (timer.state.phase) {
      case BrewTimerPhase.running:
        timer.pause();
      case BrewTimerPhase.finished:
        timer.stop();
      case BrewTimerPhase.idle:
      case BrewTimerPhase.paused:
        break;
    }
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  /// Personal list is session-scoped; team-detail lists listen to
  /// [TeamsCubit.recipesChanged] because brew mode sits on the root
  /// navigator and cannot see those cubits.
  void _refreshRecipeLists() {
    unawaited(context.read<RecipeListCubit>().load());
    context.read<TeamsCubit>().recipesChanged();
  }

  Future<void> _edit(UuidValue id) async {
    await context.push(Routes.editRecipe(id));
    if (!mounted) return;
    await context.read<RecipeDetailCubit>().reload();
  }

  Future<void> _delete(RecipeDetail detail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.deleteRecipeTitle),
          content: Text(l10n.deleteRecipeBody(detail.recipe.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              key: const Key('brew-delete-confirm'),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final deleted = await context.read<RecipeDetailCubit>().delete();
    if (!mounted) return;
    if (deleted) {
      _refreshRecipeLists();
      _leave();
      return;
    }
    final error = context.read<RecipeDetailCubit>().state.error;
    if (error != null) {
      _showError(error);
    }
  }

  Map<BrewingErrorCode, String> _overrides({UuidValue? teamId}) => {
    ..._notFoundOverride(context),
    if (teamId != null)
      BrewingErrorCode.forbidden: context.l10n.viewersCantChange,
  };

  void _showError(Object error, {UuidValue? teamId}) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            errorMessage(
              error,
              context.l10n,
              overrides: _overrides(teamId: teamId),
            ),
            style: TextStyle(color: colors.onErrorContainer),
          ),
          backgroundColor: colors.errorContainer,
        ),
      );
  }

  Future<void> _addToTeam(RecipeDetail detail) async {
    final teams = context
        .read<TeamsCubit>()
        .state
        .teams
        .where((t) => t.role == TeamRole.editor)
        .toList();
    if (teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.createOrJoinTeam)),
      );
      return;
    }
    final teamId = await showDialog<UuidValue>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.addToTeam),
        children: [
          for (final summary in teams)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(summary.team.id),
              child: Text(summary.team.name),
            ),
        ],
      ),
    );
    if (teamId == null || !mounted) return;
    final ok = await context.read<RecipeDetailCubit>().assignToTeam(teamId);
    if (!mounted) return;
    if (ok) {
      _refreshRecipeLists();
    } else {
      final error = context.read<RecipeDetailCubit>().state.error;
      if (error != null) {
        _showError(error, teamId: detail.recipe.teamId);
        if (error is BrewingException &&
            error.code == BrewingErrorCode.forbidden) {
          await context.read<RecipeDetailCubit>().reload();
        }
      }
    }
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    final detailCubit = context.read<RecipeDetailCubit>();
    final listCubit = context.read<RecipeListCubit>();
    final id = recipe.id;
    if (id == null) return;
    await toggleRecipeFavorite(
      context: context,
      recipe: recipe,
      save: ({required replace}) => detailCubit.saveFavorite(replace: replace),
      remove: detailCubit.removeFavorite,
      onChanged: ({required isFavorite, replacedRecipeId}) {
        listCubit.noteFavorite(
          recipeId: id,
          isFavorite: isFavorite,
          replacedRecipeId: replacedRecipeId,
        );
      },
      onError: _showError,
      readError: () => detailCubit.state.error,
    );
  }

  Future<void> _removeFromTeam(RecipeDetail detail) async {
    final ok = await context.read<RecipeDetailCubit>().removeFromTeam();
    if (!mounted) return;
    if (ok) {
      _refreshRecipeLists();
    } else {
      final error = context.read<RecipeDetailCubit>().state.error;
      if (error != null) {
        _showError(error, teamId: detail.recipe.teamId);
        if (error is BrewingException &&
            error.code == BrewingErrorCode.forbidden) {
          await context.read<RecipeDetailCubit>().reload();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipeDetailCubit, RecipeDetailState>(
      listenWhen: (previous, current) =>
          current.status == RecipeDetailStatus.success &&
          current.detail != previous.detail,
      listener: (context, state) {
        context.read<BrewTimerCubit>().configure(
          state.detail!.recipe.extractionDuration,
        );
      },
      child: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
        builder: (context, state) {
          final l10n = context.l10n;
          final detail = state.detail;
          return Scaffold(
            appBar: AppBar(
              title: Text(detail?.recipe.title ?? l10n.brewFallback),
              actions: [
                if (detail != null) ...[
                  FavoriteIconButton(
                    key: const Key('brew-favorite'),
                    selected: detail.recipe.isFavorite,
                    onPressed: state.favoriteBusy
                        ? null
                        : () => _toggleFavorite(detail.recipe),
                  ),
                  if (state.assigning)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  IconButton(
                    key: const Key('brew-share'),
                    tooltip: l10n.share,
                    icon: const Icon(Icons.ios_share),
                    onPressed: detail.recipe.id == null
                        ? null
                        : () => context.push(
                            Routes.shareRecipe(detail.recipe.id!),
                            extra: detail,
                          ),
                  ),
                  if (detail.access.canDelete && detail.recipe.teamId == null)
                    IconButton(
                      key: const Key('brew-add-to-team'),
                      tooltip: l10n.addToTeam,
                      icon: const Icon(Icons.group_add_outlined),
                      onPressed: state.assigning
                          ? null
                          : () => _addToTeam(detail),
                    ),
                  if (detail.recipe.teamId != null &&
                      (detail.access.canDelete ||
                          detail.access.role == TeamRole.editor))
                    IconButton(
                      key: const Key('brew-remove-from-team'),
                      tooltip: l10n.removeFromTeam,
                      icon: const Icon(Icons.group_remove_outlined),
                      onPressed: state.assigning
                          ? null
                          : () => _removeFromTeam(detail),
                    ),
                  if (detail.access.canEdit)
                    IconButton(
                      key: const Key('brew-edit'),
                      tooltip: l10n.edit,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(detail.recipe.id!),
                    ),
                  if (detail.access.canDelete)
                    IconButton(
                      key: const Key('brew-delete'),
                      tooltip: l10n.delete,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: state.deleting ? null : () => _delete(detail),
                    ),
                ],
              ],
            ),
            body: switch (state.status) {
              RecipeDetailStatus.initial || RecipeDetailStatus.loading
                  when detail == null =>
                const Center(child: CircularProgressIndicator()),
              RecipeDetailStatus.failure when detail == null => _ErrorBody(
                error: state.error ?? Object(),
                overrides: _notFoundOverride(context),
                onBack: _leave,
                onRetry: state.recipeId == null
                    ? null
                    : () => context.read<RecipeDetailCubit>().load(
                        state.recipeId!,
                      ),
              ),
              _ => _BrewBody(detail: detail!, refreshing: state.status),
            },
          );
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.error,
    required this.overrides,
    required this.onBack,
    required this.onRetry,
  });

  final Object error;
  final Map<BrewingErrorCode, String> overrides;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    final isNotFound =
        error is BrewingException && error.code == BrewingErrorCode.notFound;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage(error, context.l10n, overrides: overrides),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (isNotFound || onRetry == null)
              FilledButton(onPressed: onBack, child: Text(context.l10n.back))
            else
              FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _BrewBody extends StatelessWidget {
  const _BrewBody({required this.detail, required this.refreshing});

  final RecipeDetail detail;
  final RecipeDetailStatus refreshing;

  @override
  Widget build(BuildContext context) {
    final recipe = detail.recipe;
    final instructions = [...detail.instructions]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final photos = [...detail.photos]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return RefreshIndicator(
      onRefresh: () => context.read<RecipeDetailCubit>().reload(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ParameterBlock(detail: detail),
                  if (instructions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InstructionsBlock(instructions: instructions),
                  ],
                  if (photos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _PhotoCarousel(photos: photos),
                  ],
                  const SizedBox(height: 16),
                  if (recipe.extractionDuration == null)
                    const _NoTimerMessage()
                  else
                    const _TimerPanel(),
                  if (refreshing == RecipeDetailStatus.loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParameterBlock extends StatelessWidget {
  const _ParameterBlock({required this.detail});

  final RecipeDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final recipe = detail.recipe;
    final ingredient = detail.ingredient;
    final method =
        recipe.extractionMethod == ExtractionMethod.other &&
            (recipe.extractionMethodNote?.isNotEmpty ?? false)
        ? recipe.extractionMethodNote!
        : recipe.extractionMethod.label(l10n);
    final details = ingredientDetails(ingredient, l10n);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ingredient.name, style: theme.textTheme.titleMedium),
            Text(
              [
                ingredient.kind.label(l10n),
                if (details.isNotEmpty) details,
              ].join(' · '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FactChip(icon: Icons.science_outlined, label: method),
                _FactChip(
                  icon: Icons.scale_outlined,
                  label: '${_formatNumber(recipe.doseGrams)} g',
                ),
                _FactChip(
                  icon: Icons.thermostat,
                  label: '${_formatNumber(recipe.waterTempC)} °C',
                ),
                _FactChip(
                  icon: Icons.grain,
                  label: recipe.grindSize,
                ),
                _FactChip(
                  icon: Icons.settings_outlined,
                  label: recipe.grinderModel,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: FlavorRadarChart(
                acidity: recipe.acidity,
                sweetness: recipe.sweetness,
                body: recipe.body,
                bitterness: recipe.bitterness,
                size: 160,
              ),
            ),
            if (detail.flavorTags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in detail.flavorTags)
                    Chip(label: Text(tag.tag)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _InstructionsBlock extends StatelessWidget {
  const _InstructionsBlock({required this.instructions});

  final List<RecipeInstruction> instructions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: const Key('brew-instructions'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.prepAndExtraSteps,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final step in instructions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 14,
                  child: Text('${step.sortOrder + 1}'),
                ),
                title: Text(step.text),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({required this.photos});

  final List<RecipePhoto> photos;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  var _page = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      key: const Key('brew-photos'),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 240,
            child: PageView.builder(
              itemCount: widget.photos.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) {
                final url = widget.photos[index].publicUrl;
                final placeholder = ColoredBox(
                  color: colors.surfaceContainerHighest,
                  child: Icon(
                    Icons.local_cafe_outlined,
                    size: 48,
                    color: colors.onSurfaceVariant,
                  ),
                );
                if (url == null) return placeholder;
                return Image.network(
                  url.toString(),
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder: (_, _, _) => placeholder,
                );
              },
            ),
          ),
        ),
        if (widget.photos.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.photos.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: i == _page
                        ? colors.primary
                        : colors.outlineVariant,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NoTimerMessage extends StatelessWidget {
  const _NoTimerMessage();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          context.l10n.noExtractionTime,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TimerPanel extends StatelessWidget {
  const _TimerPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cubit = context.read<BrewTimerCubit>();
    return BlocBuilder<BrewTimerCubit, BrewTimerState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final finished = state.phase == BrewTimerPhase.finished;
        return Card(
          key: const Key('brew-timer'),
          color: finished ? colors.tertiaryContainer : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.extractionTimer, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  formatStopwatch(state.display),
                  key: const Key('brew-timer-readout'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: finished ? colors.onTertiaryContainer : null,
                    fontWeight: finished ? FontWeight.bold : null,
                  ),
                ),
                if (state.target != null)
                  Text(
                    l10n.targetDuration(formatDuration(state.target!)),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: finished
                          ? colors.onTertiaryContainer
                          : colors.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 12),
                if (state.phase == BrewTimerPhase.idle)
                  SegmentedButton<BrewTimerMode>(
                    segments: [
                      ButtonSegment(
                        value: BrewTimerMode.countDown,
                        label: Text(l10n.countDown),
                        icon: const Icon(Icons.timer_outlined),
                      ),
                      ButtonSegment(
                        value: BrewTimerMode.countUp,
                        label: Text(l10n.countUp),
                        icon: const Icon(Icons.timelapse),
                      ),
                    ],
                    selected: {state.mode},
                    onSelectionChanged: (selected) =>
                        cubit.setMode(selected.first),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (finished)
                      FilledButton.icon(
                        key: const Key('brew-stop-alarm'),
                        onPressed: cubit.stop,
                        icon: const Icon(Icons.notifications_off_outlined),
                        label: Text(l10n.stopAlarm),
                      )
                    else ...[
                      if (state.phase == BrewTimerPhase.idle)
                        FilledButton.icon(
                          key: const Key('brew-start'),
                          onPressed: cubit.start,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(l10n.start),
                        ),
                      if (state.phase == BrewTimerPhase.running)
                        FilledButton.icon(
                          key: const Key('brew-pause'),
                          onPressed: cubit.pause,
                          icon: const Icon(Icons.pause),
                          label: Text(l10n.pause),
                        ),
                      if (state.phase == BrewTimerPhase.paused)
                        FilledButton.icon(
                          key: const Key('brew-resume'),
                          onPressed: cubit.resume,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(l10n.resume),
                        ),
                      if (state.phase != BrewTimerPhase.idle)
                        OutlinedButton.icon(
                          key: const Key('brew-stop'),
                          onPressed: cubit.stop,
                          icon: const Icon(Icons.stop),
                          label: Text(l10n.stop),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _formatNumber(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toString();
