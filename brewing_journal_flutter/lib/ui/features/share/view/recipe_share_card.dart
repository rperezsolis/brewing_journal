import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/brewing_labels.dart';
import '../../../core/l10n.dart';
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
    final l10n = context.l10n;
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
        : recipe.extractionMethod.label(l10n);
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
                          l10n.kindAndName(
                            detail.ingredient.kind.label(l10n),
                            detail.ingredient.name,
                          ),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe.waterMl == null
                              ? l10n.brewingSummary(
                                  method,
                                  _formatNumber(recipe.doseGrams),
                                  _formatNumber(recipe.waterTempC),
                                )
                              : l10n.brewingSummaryWithWater(
                                  method,
                                  _formatNumber(recipe.doseGrams),
                                  _formatNumber(recipe.waterMl!),
                                  _formatNumber(recipe.waterTempC),
                                ),
                        ),
                        Text(
                          l10n.grindingSummary(
                            recipe.grindSize,
                            recipe.grinderModel,
                          ),
                        ),
                        if (duration != null)
                          Text(_formatTimer(duration, l10n)),
                        const SizedBox(height: 8),
                        Center(
                          child: FlavorRadarChart(
                            acidity: recipe.acidity,
                            sweetness: recipe.sweetness,
                            body: recipe.body,
                            bitterness: recipe.bitterness,
                            size: 112,
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
                                Text(l10n.moreCount(preview.moreCount)),
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
                    l10n.madeWithBrewSync,
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

/// `Timer: 3m 00s`, with a tenth when the duration has one (`2m 30.5s`).
String _formatTimer(Duration duration, AppLocalizations l10n) {
  final tenths = duration.inMilliseconds ~/ 100;
  final minutes = tenths ~/ 600;
  final seconds = (tenths ~/ 10) % 60;
  final fraction = tenths % 10 == 0 ? '' : '.${tenths % 10}';
  return l10n.timerSummary('$minutes', '${_two(seconds)}$fraction');
}

String _two(int value) => value.toString().padLeft(2, '0');
