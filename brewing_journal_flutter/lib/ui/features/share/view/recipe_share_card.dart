import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';

import '../../../core/brewing_labels.dart';
import '../../../core/duration_format.dart';
import '../../../core/widgets/flavor_radar_chart.dart';
import '../share_card_layout.dart';

/// Fixed 360×450 recipe summary. Painted to a PNG at pixel ratio 3
/// (1080×1350). Photos are left out so capture never waits on the network.
class RecipeShareCard extends StatelessWidget {
  const RecipeShareCard({super.key, required this.detail});

  static const width = 360.0;
  static const height = 450.0;
  static const footerHeight = 24.0;

  final RecipeDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final recipe = detail.recipe;
    final instructions = [...detail.instructions]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final preview = visibleInstructions([
      for (final step in instructions) step.text,
    ]);
    final method =
        recipe.extractionMethod == ExtractionMethod.other &&
            (recipe.extractionMethodNote?.isNotEmpty ?? false)
        ? recipe.extractionMethodNote!
        : recipe.extractionMethod.label;
    final duration = recipe.extractionDuration;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: colors.surface,
        child: Column(
          children: [
            Expanded(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: 0,
                  maxHeight: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detail.ingredient.name,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          detail.ingredient.kind.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$method · ${_formatNumber(recipe.doseGrams)} g · '
                          '${_formatNumber(recipe.waterTempC)} °C',
                        ),
                        Text('${recipe.grindSize} · ${recipe.grinderModel}'),
                        if (duration != null) Text(formatDuration(duration)),
                        const SizedBox(height: 8),
                        Center(
                          child: FlavorRadarChart(
                            acidity: recipe.acidity,
                            sweetness: recipe.sweetness,
                            body: recipe.body,
                            bitterness: recipe.bitterness,
                            size: 120,
                          ),
                        ),
                        if (detail.flavorTags.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              for (final tag in detail.flavorTags)
                                Chip(
                                  label: Text(tag.tag),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ],
                        if (preview.rows.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Column(
                            key: const Key('share-instructions'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final row in preview.rows)
                                Text(
                                  row,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (preview.moreCount > 0)
                                Text('+${preview.moreCount} more'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              key: const Key('share-footer'),
              height: footerHeight,
              width: double.infinity,
              child: ColoredBox(
                color: colors.primaryContainer,
                child: Center(
                  child: Text(
                    'Made with BrewSync',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatNumber(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toString();
