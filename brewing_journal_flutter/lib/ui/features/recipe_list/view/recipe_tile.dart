import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/brewing_labels.dart';
import '../../../core/l10n.dart';

/// One recipe in a list: title, author, save time, and brew summary.
class RecipeTile extends StatelessWidget {
  const RecipeTile({super.key, required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ingredient = recipe.ingredient;
    final author = recipe.authorName?.trim();
    final updated = DateFormat.yMMMd(
      l10n.localeName,
    ).add_jm().format(recipe.updatedAt.toLocal());
    final summary = [
      if (ingredient != null) ingredient.name,
      recipe.extractionMethod == ExtractionMethod.other &&
              recipe.extractionMethodNote != null
          ? recipe.extractionMethodNote!
          : recipe.extractionMethod.label(l10n),
      '${_formatNumber(recipe.doseGrams)} g',
      '${_formatNumber(recipe.waterTempC)} °C',
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: ListTile(
        isThreeLine: true,
        leading: CircleAvatar(
          child: Icon(switch (ingredient?.kind) {
            BeverageKind.tea => Icons.emoji_food_beverage_outlined,
            BeverageKind.matcha => Icons.eco_outlined,
            _ => Icons.coffee_outlined,
          }),
        ),
        title: Text(recipe.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recipeByline(
                author == null || author.isEmpty ? l10n.unknownAuthor : author,
                updated,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(summary, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  static String _formatNumber(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}
