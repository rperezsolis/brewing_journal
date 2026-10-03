import 'package:flutter/material.dart';

import '../l10n.dart';

/// Heart toggle for saving or filtering a recipe.
class FavoriteIconButton extends StatelessWidget {
  const FavoriteIconButton({
    super.key,
    required this.selected,
    required this.onPressed,
    this.tooltip,
  });

  final bool selected;
  final VoidCallback? onPressed;

  /// Overrides the add/remove tooltip, for the list filter.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IconButton(
      isSelected: selected,
      tooltip:
          tooltip ??
          (selected ? l10n.removeFromFavorites : l10n.addToFavorites),
      selectedIcon: const Icon(Icons.favorite),
      icon: const Icon(Icons.favorite_border),
      onPressed: onPressed,
    );
  }
}
