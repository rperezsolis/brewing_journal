import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/brewing_labels.dart';
import '../../../core/duration_format.dart';
import '../cubit/recipe_creation_cubit.dart';
import '../cubit/recipe_creation_state.dart';
import '../recipe_limits.dart';

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
  late final TextEditingController _grind;
  late final TextEditingController _grinder;
  late final TextEditingController _note;
  late final TextEditingController _duration;

  RecipeCreationCubit get _cubit => context.read<RecipeCreationCubit>();

  @override
  void initState() {
    super.initState();
    final s = _cubit.state;
    _title = TextEditingController(text: s.title);
    _temp = TextEditingController(text: _formatNumber(s.waterTempC));
    _dose = TextEditingController(text: _formatNumber(s.doseGrams));
    _grind = TextEditingController(text: s.grindSize);
    _grinder = TextEditingController(text: s.grinderModel);
    _note = TextEditingController(text: s.extractionMethodNote);
    _duration = TextEditingController(
      text: s.extractionDuration == null
          ? ''
          : formatDuration(s.extractionDuration!),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _temp,
      _dose,
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
    const gap = SizedBox(height: 16);
    return BlocListener<RecipeCreationCubit, RecipeCreationState>(
      listenWhen: (previous, current) =>
          previous.extractionDuration != current.extractionDuration &&
          !current.stopwatchRunning,
      listener: _syncDurationField,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Brew parameters', style: theme.textTheme.titleLarge),
          gap,
          TextField(
            key: const Key('extraction-title'),
            controller: _title,
            maxLength: kTitleMaxLength,
            onChanged: _cubit.setTitle,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Recipe title',
              border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Water temperature',
                    suffixText: '°C',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Dose',
                    suffixText: 'g',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          gap,
          TextField(
            key: const Key('extraction-grind'),
            controller: _grind,
            maxLength: kGrindMaxLength,
            onChanged: _cubit.setGrindSize,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Grind size',
              hintText: 'Medium-fine, 18 clicks…',
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            key: const Key('extraction-grinder'),
            controller: _grinder,
            maxLength: kGrindMaxLength,
            onChanged: _cubit.setGrinderModel,
            decoration: const InputDecoration(
              labelText: 'Grinder model',
              hintText: 'Comandante C40, Niche Zero…',
              border: OutlineInputBorder(),
            ),
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
                  decoration: const InputDecoration(
                    labelText: 'Extraction method',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final method in ExtractionMethod.values)
                      DropdownMenuItem(
                        value: method,
                        child: Text(method.label),
                      ),
                  ],
                  onChanged: _cubit.setExtractionMethod,
                ),
                if (state.extractionMethod == ExtractionMethod.other) ...[
                  gap,
                  TextField(
                    key: const Key('extraction-method-note'),
                    controller: _note,
                    onChanged: _cubit.setExtractionMethodNote,
                    decoration: const InputDecoration(
                      labelText: 'Describe the method',
                      border: OutlineInputBorder(),
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
                labelText: 'Or enter the time (m:ss)',
                errorText:
                    _duration.text.trim().isNotEmpty &&
                        parseDuration(_duration.text) == null
                    ? 'Use m:ss, for example 2:30'
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
                Text('Extraction time', style: theme.textTheme.titleMedium),
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
                      FilledButton.icon(
                        key: const Key('stopwatch-stop'),
                        onPressed: cubit.stopStopwatch,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                      )
                    else
                      FilledButton.icon(
                        key: const Key('stopwatch-start'),
                        onPressed: cubit.startStopwatch,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                      ),
                    OutlinedButton.icon(
                      key: const Key('stopwatch-reset'),
                      onPressed: hasReading || running
                          ? cubit.resetStopwatch
                          : null,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset'),
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
