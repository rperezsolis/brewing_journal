import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/analytics/tracked_button.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/duration_format.dart';
import '../../../core/l10n.dart';
import 'wizard_screen_name.dart';
import '../cubit/recipe_creation_cubit.dart';
import '../cubit/recipe_creation_state.dart';
import '../recipe_limits.dart';

const _grinderSearchDebounce = Duration(milliseconds: 250);

/// Step 2: the extraction parameters and a stopwatch that records the time.
class StepExtraction extends StatefulWidget {
  const StepExtraction({super.key});

  @override
  State<StepExtraction> createState() => _StepExtractionState();
}

class _StepExtractionState extends State<StepExtraction> {
  late final TextEditingController _title;
  late final TextEditingController _temp;
  late final TextEditingController _dose;
  late final TextEditingController _water;
  late final TextEditingController _grind;
  late final TextEditingController _grinder;
  late final TextEditingController _note;
  late final TextEditingController _duration;
  Timer? _grinderSearch;

  RecipeCreationCubit get _cubit => context.read<RecipeCreationCubit>();

  @override
  void initState() {
    super.initState();
    final s = _cubit.state;
    _title = TextEditingController(text: s.title);
    _temp = TextEditingController(text: _formatNumber(s.waterTempC));
    _dose = TextEditingController(text: _formatNumber(s.doseGrams));
    _water = TextEditingController(text: _formatNumber(s.waterMl));
    _grind = TextEditingController(text: s.grindSize);
    _grinder = TextEditingController(text: s.grinderModel);
    _note = TextEditingController(text: s.extractionMethodNote);
    _duration = TextEditingController(
      text: s.extractionDuration == null
          ? ''
          : formatDuration(s.extractionDuration!),
    );
    unawaited(_cubit.searchGrinderModels(s.grinderModel));
  }

  @override
  void dispose() {
    _grinderSearch?.cancel();
    for (final c in [
      _title,
      _temp,
      _dose,
      _water,
      _grind,
      _grinder,
      _note,
      _duration,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _formatNumber(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  static double? _parseNumber(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  void _scheduleGrinderSearch(String query) {
    _grinderSearch?.cancel();
    _grinderSearch = Timer(_grinderSearchDebounce, () {
      unawaited(_cubit.searchGrinderModels(query));
    });
  }

  static bool _isGrinderSuggestion(String model, String current) {
    final folded = model.trim().toLowerCase();
    return folded.startsWith(current) && folded != current;
  }

  void _selectGrinder(String model) {
    _grinderSearch?.cancel();
    _grinder.value = TextEditingValue(
      text: model,
      selection: TextSelection.collapsed(offset: model.length),
    );
    _cubit.setGrinderModel(model);
    unawaited(_cubit.searchGrinderModels(model));
  }

  void _onDurationChanged(String text) {
    if (text.trim().isEmpty) {
      _cubit.setExtractionDuration(null);
    } else {
      final duration = parseDuration(text);
      if (duration != null) _cubit.setExtractionDuration(duration);
    }
    setState(() {});
  }

  /// Mirrors a stopwatch stop or reset into the manual field, without
  /// rewriting what the user is typing.
  void _syncDurationField(BuildContext context, RecipeCreationState state) {
    final duration = state.extractionDuration;
    final typed = _duration.text.trim().isEmpty
        ? null
        : parseDuration(_duration.text);
    if (typed == duration) return;
    _duration.text = duration == null ? '' : formatDuration(duration);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    const gap = SizedBox(height: 16);
    return BlocListener<RecipeCreationCubit, RecipeCreationState>(
      listenWhen: (previous, current) =>
          previous.extractionDuration != current.extractionDuration &&
          !current.stopwatchRunning,
      listener: _syncDurationField,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.brewParameters, style: theme.textTheme.titleLarge),
          gap,
          TextField(
            key: const Key('extraction-title'),
            controller: _title,
            maxLength: kTitleMaxLength,
            onChanged: _cubit.setTitle,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.recipeTitle,
              border: const OutlineInputBorder(),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('extraction-temp'),
                  controller: _temp,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  onChanged: (text) => _cubit.setWaterTemp(_parseNumber(text)),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.waterTemperature,
                    suffixText: '°C',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  key: const Key('extraction-dose'),
                  controller: _dose,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  onChanged: (text) => _cubit.setDose(_parseNumber(text)),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.dose,
                    suffixText: 'g',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          gap,
          TextField(
            key: const Key('extraction-water'),
            controller: _water,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            onChanged: (text) => _cubit.setWater(_parseNumber(text)),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.waterQuantity,
              suffixText: 'ml',
              border: const OutlineInputBorder(),
            ),
          ),
          gap,
          TextField(
            key: const Key('extraction-grind'),
            controller: _grind,
            maxLength: kGrindMaxLength,
            onChanged: _cubit.setGrindSize,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.grindSize,
              hintText: l10n.grindSizeHint,
              border: const OutlineInputBorder(),
            ),
          ),
          TextField(
            key: const Key('extraction-grinder'),
            controller: _grinder,
            maxLength: kGrindMaxLength,
            onChanged: (value) {
              _cubit.setGrinderModel(value);
              _scheduleGrinderSearch(value);
            },
            decoration: InputDecoration(
              labelText: l10n.grinderModel,
              hintText: l10n.grinderModelHint,
              border: const OutlineInputBorder(),
            ),
          ),
          BlocBuilder<RecipeCreationCubit, RecipeCreationState>(
            buildWhen: (previous, current) =>
                previous.grinderSuggestions != current.grinderSuggestions ||
                previous.grinderModel != current.grinderModel,
            builder: (context, state) {
              final current = state.grinderModel.trim().toLowerCase();
              final suggestions = [
                for (final model in state.grinderSuggestions)
                  if (_isGrinderSuggestion(model, current)) model,
              ];
              if (suggestions.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  for (final model in suggestions)
                    TrackedButton(
                      buttonLabel: 'grinder_suggestion',
                      buttonAction: 'select_grinder',
                      currentScreen: wizardScreenName(context),
                      onPressed: () => _selectGrinder(model),
                      builder: (context, onPressed) => ListTile(
                        key: ValueKey('grinder-suggestion-$model'),
                        dense: true,
                        title: Text(model),
                        onTap: onPressed,
                      ),
                    ),
                ],
              );
            },
          ),
          BlocBuilder<RecipeCreationCubit, RecipeCreationState>(
            buildWhen: (previous, current) =>
                previous.extractionMethod != current.extractionMethod,
            builder: (context, state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<ExtractionMethod>(
                  key: const Key('extraction-method'),
                  initialValue: state.extractionMethod,
                  decoration: InputDecoration(
                    labelText: l10n.extractionMethodLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final method in ExtractionMethod.values)
                      DropdownMenuItem(
                        value: method,
                        child: Text(method.label(l10n)),
                      ),
                  ],
                  onChanged: _cubit.setExtractionMethod,
                ),
                if (state.extractionMethod == ExtractionMethod.other) ...[
                  gap,
                  TextField(
                    key: const Key('extraction-method-note'),
                    controller: _note,
                    maxLength: kExtractionNoteMaxLength,
                    onChanged: _cubit.setExtractionMethodNote,
                    decoration: InputDecoration(
                      labelText: l10n.describeTheMethod,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _StopwatchCard(
            durationField: TextField(
              key: const Key('extraction-duration'),
              controller: _duration,
              onChanged: _onDurationChanged,
              enabled: !context.select(
                (RecipeCreationCubit c) => c.state.stopwatchRunning,
              ),
              decoration: InputDecoration(
                labelText: l10n.enterTime,
                errorText:
                    _duration.text.trim().isNotEmpty &&
                        parseDuration(_duration.text) == null
                    ? l10n.timeFormatError
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopwatchCard extends StatelessWidget {
  const _StopwatchCard({required this.durationField});

  final Widget durationField;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cubit = context.read<RecipeCreationCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<RecipeCreationCubit, RecipeCreationState>(
          buildWhen: (previous, current) =>
              previous.stopwatchRunning != current.stopwatchRunning ||
              previous.stopwatchElapsed != current.stopwatchElapsed ||
              previous.extractionDuration != current.extractionDuration,
          builder: (context, state) {
            final running = state.stopwatchRunning;
            final reading = running
                ? state.stopwatchElapsed
                : state.extractionDuration ?? state.stopwatchElapsed;
            final hasReading = reading > Duration.zero;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.extractionTime, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  formatStopwatch(reading),
                  key: const Key('stopwatch-readout'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (running)
                      TrackedButton(
                        buttonLabel: 'stop',
                        buttonAction: 'stop_stopwatch',
                        currentScreen: wizardScreenName(context),
                        onPressed: cubit.stopStopwatch,
                        builder: (context, onPressed) => FilledButton.icon(
                          key: const Key('stopwatch-stop'),
                          onPressed: onPressed,
                          icon: const Icon(Icons.stop),
                          label: Text(l10n.stop),
                        ),
                      )
                    else
                      TrackedButton(
                        buttonLabel: 'start',
                        buttonAction: 'start_stopwatch',
                        currentScreen: wizardScreenName(context),
                        onPressed: cubit.startStopwatch,
                        builder: (context, onPressed) => FilledButton.icon(
                          key: const Key('stopwatch-start'),
                          onPressed: onPressed,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(l10n.start),
                        ),
                      ),
                    TrackedButton(
                      buttonLabel: 'reset',
                      buttonAction: 'reset_stopwatch',
                      currentScreen: wizardScreenName(context),
                      onPressed: hasReading || running
                          ? cubit.resetStopwatch
                          : null,
                      builder: (context, onPressed) => OutlinedButton.icon(
                        key: const Key('stopwatch-reset'),
                        onPressed: onPressed,
                        icon: const Icon(Icons.restart_alt),
                        label: Text(l10n.reset),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                durationField,
              ],
            );
          },
        ),
      ),
    );
  }
}
