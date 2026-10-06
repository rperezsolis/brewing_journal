import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/analytics/tracked_button.dart';
import '../../../core/brewing_labels.dart';
import '../../../core/l10n.dart';
import '../../../core/widgets/favorite_icon_button.dart';

/// One recipe in a list: title, author, save time, and brew summary.
class RecipeTile extends StatelessWidget {
  const RecipeTile({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onFavorite,
    required this.currentScreen,
    this.favoriteBusy = false,
    this.favoriteEnabled = true,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  /// Screen that owns the list, recorded with each tap.
  final String currentScreen;
  final bool favoriteBusy;

  /// When false the heart stays visible and selected, but does not respond.
  final bool favoriteEnabled;

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
      child: TrackedButton(
        buttonLabel: 'recipe',
        buttonAction: 'open_recipe',
        currentScreen: currentScreen,
        onPressed: onTap,
        builder: (context, onPressed) => ListTile(
          isThreeLine: true,
          titleAlignment: ListTileTitleAlignment.center,
          leading: CircleAvatar(
            child: Icon(switch (ingredient?.kind) {
              BeverageKind.tea => Icons.emoji_food_beverage_outlined,
              BeverageKind.matcha => Icons.eco_outlined,
              _ => Icons.coffee_outlined,
            }),
          ),
          title: Text(recipe.title),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.recipeByline(
                  author == null || author.isEmpty
                      ? l10n.unknownAuthor
                      : author,
                  updated,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(summary, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TrackedButton(
                buttonLabel: 'favorite',
                buttonAction: recipe.isFavorite
                    ? 'remove_favorite'
                    : 'save_favorite',
                currentScreen: currentScreen,
                onPressed: favoriteBusy || !favoriteEnabled ? null : onFavorite,
                builder: (context, onPressed) => FavoriteIconButton(
                  key: ValueKey('recipe-favorite-${recipe.id?.uuid}'),
                  selected: recipe.isFavorite,
                  tooltip: favoriteEnabled
                      ? null
                      : l10n.viewersCantChangeTeamFavorites,
                  onPressed: onPressed,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: onPressed,
        ),
      ),
    );
  }

  static String _formatNumber(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}
