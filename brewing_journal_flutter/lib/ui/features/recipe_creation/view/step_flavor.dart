import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/analytics/tracked_button.dart';
import '../../../core/l10n.dart';
import '../../../core/widgets/flavor_radar_chart.dart';
import 'wizard_screen_name.dart';
import '../cubit/recipe_creation_cubit.dart';
import '../cubit/recipe_creation_state.dart';
import '../recipe_limits.dart';

/// Step 3: the four flavor scores, a live radar chart, and flavor tags.
class StepFlavor extends StatefulWidget {
  const StepFlavor({super.key});

  @override
  State<StepFlavor> createState() => _StepFlavorState();
}

class _StepFlavorState extends State<StepFlavor> {
  final _tag = TextEditingController();

  @override
  void dispose() {
    _tag.dispose();
    super.dispose();
  }

  void _addTag() {
    final cubit = context.read<RecipeCreationCubit>();
    final before = cubit.state.flavorTags;
    cubit.setFlavor(tags: [...before, _tag.text]);
    if (cubit.state.error == null) _tag.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<RecipeCreationCubit>();
    return BlocBuilder<RecipeCreationCubit, RecipeCreationState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final sliders = Column(
          children: [
            _ScoreSlider(
              label: l10n.acidity,
              value: state.acidity,
              onChanged: (v) => cubit.setFlavor(acidity: v),
            ),
            _ScoreSlider(
              label: l10n.sweetness,
              value: state.sweetness,
              onChanged: (v) => cubit.setFlavor(sweetness: v),
            ),
            _ScoreSlider(
              label: l10n.flavorBody,
              value: state.body,
              onChanged: (v) => cubit.setFlavor(body: v),
            ),
            _ScoreSlider(
              label: l10n.bitterness,
              value: state.bitterness,
              onChanged: (v) => cubit.setFlavor(bitterness: v),
            ),
          ],
        );
        final chart = FlavorRadarChart(
          acidity: state.acidity,
          sweetness: state.sweetness,
          body: state.body,
          bitterness: state.bitterness,
        );
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.flavorMap, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth >= 560
                  ? Row(
                      children: [
                        Expanded(child: sliders),
                        const SizedBox(width: 16),
                        chart,
                      ],
                    )
                  : Column(children: [chart, sliders]),
            ),
            const SizedBox(height: 24),
            Text(l10n.flavorTags, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in state.flavorTags)
                  TrackedButton(
                    buttonLabel: 'flavor_tag',
                    buttonAction: 'remove_flavor_tag',
                    currentScreen: wizardScreenName(context),
                    onPressed: () => cubit.setFlavor(
                      tags: [...state.flavorTags]..remove(tag),
                    ),
                    builder: (context, onPressed) => InputChip(
                      label: Text(tag),
                      onDeleted: onPressed,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('flavor-tag'),
              controller: _tag,
              maxLength: kTagMaxLength,
              enabled: state.flavorTags.length < kMaxTags,
              onSubmitted: (_) => _addTag(),
              decoration: InputDecoration(
                labelText: state.flavorTags.length < kMaxTags
                    ? l10n.addTagHint
                    : l10n.atMostTags(kMaxTags),
                border: const OutlineInputBorder(),
                suffixIcon: TrackedButton(
                  buttonLabel: 'add_tag',
                  buttonAction: 'add_flavor_tag',
                  currentScreen: wizardScreenName(context),
                  onPressed: state.flavorTags.length < kMaxTags
                      ? _addTag
                      : null,
                  builder: (context, onPressed) => IconButton(
                    tooltip: l10n.addTag,
                    icon: const Icon(Icons.add),
                    onPressed: onPressed,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScoreSlider extends StatelessWidget {
  const _ScoreSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 88, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            max: kMaxScore.toDouble(),
            divisions: kMaxScore,
            label: '$value',
            semanticFormatterCallback: (v) => '$label ${v.round()}',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 20, child: Text('$value', textAlign: TextAlign.end)),
      ],
    );
  }
}
