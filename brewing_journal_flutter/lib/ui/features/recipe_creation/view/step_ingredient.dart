import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/brewing_labels.dart';
import '../../../core/l10n.dart';
import '../cubit/recipe_creation_cubit.dart';
import '../cubit/recipe_creation_state.dart';
import '../recipe_limits.dart';

const _searchDebounce = Duration(milliseconds: 250);

/// Step 1: search, select, or register a bean, tea leaf, or matcha grade.
class StepIngredient extends StatefulWidget {
  const StepIngredient({super.key});

  @override
  State<StepIngredient> createState() => _StepIngredientState();
}

class _StepIngredientState extends State<StepIngredient> {
  late final TextEditingController _query;
  Timer? _debounce;

  RecipeCreationCubit get _cubit => context.read<RecipeCreationCubit>();

  @override
  void initState() {
    super.initState();
    final state = _cubit.state;
    _query = TextEditingController(text: state.ingredientQuery);
    unawaited(
      _cubit.searchIngredients(state.ingredientKind, state.ingredientQuery),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      unawaited(_cubit.searchIngredients(_cubit.state.ingredientKind, query));
    });
  }

  Future<void> _openRegisterSheet() async {
    final cubit = _cubit;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: RegisterIngredientSheet(
          kind: cubit.state.ingredientKind,
          initialName: _query.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<RecipeCreationCubit, RecipeCreationState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final selected = state.selectedIngredient;
        final kindName = state.ingredientKind.label(l10n).toLowerCase();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.whatAreYouBrewing, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<BeverageKind>(
              segments: [
                for (final kind in BeverageKind.values)
                  ButtonSegment(value: kind, label: Text(kind.label(l10n))),
              ],
              selected: {state.ingredientKind},
              onSelectionChanged: (kinds) {
                _debounce?.cancel();
                unawaited(_cubit.searchIngredients(kinds.single, _query.text));
              },
            ),
            const SizedBox(height: 16),
            if (selected != null) ...[
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: Text(selected.name),
                  subtitle: Text(
                    [
                      selected.kind.label(l10n),
                      ingredientDetails(selected, l10n),
                    ].where((s) => s.isNotEmpty).join(' · '),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              key: const Key('ingredient-search'),
              controller: _query,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: l10n.searchIngredient(kindName),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.searchingIngredients
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            for (final ingredient in state.ingredientResults)
              ListTile(
                key: ValueKey(ingredient.id),
                title: Text(ingredient.name),
                subtitle: ingredientDetails(ingredient, l10n).isEmpty
                    ? null
                    : Text(ingredientDetails(ingredient, l10n)),
                trailing: ingredient.id == state.adoptingIngredientId
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ingredient.id == selected?.id
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                selected:
                    ingredient.id == selected?.id ||
                    ingredient.id == state.adoptingIngredientId,
                onTap: state.adoptingIngredientId == null
                    ? () => unawaited(_cubit.selectIngredient(ingredient))
                    : null,
              ),
            if (state.ingredientResults.isEmpty && !state.searchingIngredients)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  state.ingredientQuery.trim().isEmpty
                      ? l10n.nothingRegistered
                      : l10n.noMatches(state.ingredientQuery.trim()),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              child: OutlinedButton.icon(
                key: const Key('ingredient-register-open'),
                onPressed: _openRegisterSheet,
                icon: const Icon(Icons.add),
                label: Text(l10n.registerNewKind(kindName)),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The "Register new" form. Pops itself once the ingredient is registered.
class RegisterIngredientSheet extends StatefulWidget {
  const RegisterIngredientSheet({
    super.key,
    required this.kind,
    this.initialName = '',
  });

  final BeverageKind kind;
  final String initialName;

  @override
  State<RegisterIngredientSheet> createState() =>
      _RegisterIngredientSheetState();
}

class _RegisterIngredientSheetState extends State<RegisterIngredientSheet> {
  late final _name = TextEditingController(text: widget.initialName);
  final _origin = TextEditingController();
  final _roaster = TextEditingController();
  final _processing = TextEditingController();
  RoastLevel? _roastLevel;

  @override
  void dispose() {
    for (final c in [_name, _origin, _roaster, _processing]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    String? optional(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    final registered = await context
        .read<RecipeCreationCubit>()
        .registerIngredient(
          IngredientDraft(
            kind: widget.kind,
            name: _name.text,
            origin: optional(_origin),
            roaster: optional(_roaster),
            roastLevel: _roastLevel,
            processing: optional(_processing),
          ),
        );
    if (registered && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final busy = context.select(
      (RecipeCreationCubit c) => c.state.registeringIngredient,
    );
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.registerNewKind(widget.kind.label(l10n).toLowerCase()),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('ingredient-name'),
              controller: _name,
              autofocus: widget.initialName.isEmpty,
              maxLength: kIngredientNameMaxLength,
              decoration: InputDecoration(
                labelText: l10n.nameLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('ingredient-origin'),
              controller: _origin,
              maxLength: kIngredientDetailMaxLength,
              decoration: InputDecoration(
                labelText: l10n.originOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roaster,
              maxLength: kIngredientDetailMaxLength,
              decoration: InputDecoration(
                labelText: l10n.roasterOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RoastLevel?>(
              initialValue: _roastLevel,
              decoration: InputDecoration(
                labelText: l10n.roastLevelOptional,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.notSet)),
                for (final level in RoastLevel.values)
                  DropdownMenuItem(
                    value: level,
                    child: Text(level.label(l10n)),
                  ),
              ],
              onChanged: (level) => setState(() => _roastLevel = level),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _processing,
              maxLength: kIngredientDetailMaxLength,
              decoration: InputDecoration(
                labelText: l10n.processingOptional,
                hintText: l10n.processingHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('ingredient-register'),
              onPressed: busy ? null : _register,
              child: busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.register),
            ),
          ],
        ),
      ),
    );
  }
}
