import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../router.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/duration_format.dart';
import '../../../core/error_messages.dart';
import '../../../core/widgets/flavor_radar_chart.dart';
import '../../recipe_detail/cubit/recipe_detail_cubit.dart';
import '../../recipe_detail/cubit/recipe_detail_state.dart';
import '../../recipe_list/cubit/recipe_list_cubit.dart';
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

  static const _notFoundOverride = {
    BrewingErrorCode.notFound: 'Recipe not found or no longer shared with you',
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

  Future<void> _edit(UuidValue id) async {
    await context.push(Routes.editRecipe(id));
    if (!mounted) return;
    await context.read<RecipeDetailCubit>().reload();
  }

  Future<void> _delete(RecipeDetail detail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this recipe?'),
        content: Text(
          '“${detail.recipe.title}” will be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('brew-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final deleted = await context.read<RecipeDetailCubit>().delete();
    if (!mounted) return;
    if (deleted) {
      unawaited(context.read<RecipeListCubit>().load());
      _leave();
      return;
    }
    final error = context.read<RecipeDetailCubit>().state.error;
    if (error != null) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            errorMessage(error, overrides: _notFoundOverride),
            style: TextStyle(color: colors.onErrorContainer),
          ),
          backgroundColor: colors.errorContainer,
        ),
      );
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
          final detail = state.detail;
          return Scaffold(
            appBar: AppBar(
              title: Text(detail?.recipe.title ?? 'Brew'),
              actions: [
                if (detail != null) ...[
                  IconButton(
                    key: const Key('brew-share'),
                    tooltip: 'Share',
                    icon: const Icon(Icons.ios_share),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sharing is coming soon.'),
                        ),
                      );
                    },
                  ),
                  if (detail.access.canEdit)
                    IconButton(
                      key: const Key('brew-edit'),
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(detail.recipe.id!),
                    ),
                  if (detail.access.canDelete)
                    IconButton(
                      key: const Key('brew-delete'),
                      tooltip: 'Delete',
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
                overrides: _notFoundOverride,
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
              errorMessage(error, overrides: overrides),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (isNotFound || onRetry == null)
              FilledButton(onPressed: onBack, child: const Text('Back'))
            else
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
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
    final recipe = detail.recipe;
    final ingredient = detail.ingredient;
    final method =
        recipe.extractionMethod == ExtractionMethod.other &&
            (recipe.extractionMethodNote?.isNotEmpty ?? false)
        ? recipe.extractionMethodNote!
        : recipe.extractionMethod.label;
    final details = ingredientDetails(ingredient);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ingredient.name, style: theme.textTheme.titleMedium),
            Text(
              [
                ingredient.kind.label,
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
            Text('Prep & extra steps', style: theme.textTheme.titleMedium),
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
          'No extraction time recorded',
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
        final finished = state.phase == BrewTimerPhase.finished;
        return Card(
          key: const Key('brew-timer'),
          color: finished ? colors.tertiaryContainer : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Extraction timer', style: theme.textTheme.titleMedium),
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
                    'Target ${formatDuration(state.target!)}',
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
                    segments: const [
                      ButtonSegment(
                        value: BrewTimerMode.countDown,
                        label: Text('Count down'),
                        icon: Icon(Icons.timer_outlined),
                      ),
                      ButtonSegment(
                        value: BrewTimerMode.countUp,
                        label: Text('Count up'),
                        icon: Icon(Icons.timelapse),
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
                        label: const Text('Stop alarm'),
                      )
                    else ...[
                      if (state.phase == BrewTimerPhase.idle)
                        FilledButton.icon(
                          key: const Key('brew-start'),
                          onPressed: cubit.start,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                        ),
                      if (state.phase == BrewTimerPhase.running)
                        FilledButton.icon(
                          key: const Key('brew-pause'),
                          onPressed: cubit.pause,
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause'),
                        ),
                      if (state.phase == BrewTimerPhase.paused)
                        FilledButton.icon(
                          key: const Key('brew-resume'),
                          onPressed: cubit.resume,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Resume'),
                        ),
                      if (state.phase != BrewTimerPhase.idle)
                        OutlinedButton.icon(
                          key: const Key('brew-stop'),
                          onPressed: cubit.stop,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
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
