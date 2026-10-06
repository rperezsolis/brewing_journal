import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/analytics/tracked_button.dart';
import '../../../core/l10n.dart';
import '../cubit/recipe_creation_cubit.dart';
import 'wizard_screen_name.dart';
import '../cubit/recipe_creation_state.dart';
import '../recipe_limits.dart';

/// Step 4 (optional): an ordered list of free-text extra instructions.
class StepInstructions extends StatefulWidget {
  const StepInstructions({super.key});

  @override
  State<StepInstructions> createState() => _StepInstructionsState();
}

class _StepInstructionsState extends State<StepInstructions> {
  final _input = TextEditingController();

  RecipeCreationCubit get _cubit => context.read<RecipeCreationCubit>();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add() {
    if (_cubit.addInstruction(_input.text)) _input.clear();
  }

  Future<void> _edit(int index, String text) async {
    final screen = wizardScreenName(context);
    final updated = await showDialog<String>(
      context: context,
      builder: (_) =>
          _EditInstructionDialog(initial: text, currentScreen: screen),
    );
    if (updated != null) _cubit.updateInstruction(index, updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<RecipeCreationCubit, RecipeCreationState>(
      buildWhen: (previous, current) =>
          previous.instructions != current.instructions,
      builder: (context, state) {
        final l10n = context.l10n;
        final instructions = state.instructions;
        final full = instructions.length >= kMaxInstructions;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.extraSteps,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  TrackedButton(
                    buttonLabel: 'skip',
                    buttonAction: 'skip_instructions',
                    currentScreen: wizardScreenName(context),
                    onPressed: _cubit.skipInstructions,
                    builder: (context, onPressed) => TextButton(
                      key: const Key('instructions-skip'),
                      onPressed: onPressed,
                      child: Text(l10n.skip),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.extraStepsHelp,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                key: const Key('instruction-input'),
                controller: _input,
                maxLength: kInstructionMaxLength,
                enabled: !full,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  labelText: full
                      ? l10n.atMostSteps(kMaxInstructions)
                      : l10n.addAStep,
                  border: const OutlineInputBorder(),
                  suffixIcon: TrackedButton(
                    buttonLabel: 'add_step',
                    buttonAction: 'add_instruction',
                    currentScreen: wizardScreenName(context),
                    onPressed: full ? null : _add,
                    builder: (context, onPressed) => IconButton(
                      key: const Key('instruction-add'),
                      tooltip: l10n.addStep,
                      icon: const Icon(Icons.add),
                      onPressed: onPressed,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: instructions.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noExtraSteps,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: instructions.length,
                      onReorderItem: _cubit.moveInstruction,
                      itemBuilder: (context, index) {
                        final text = instructions[index];
                        return TrackedButton(
                          key: ValueKey('instruction-$index'),
                          buttonLabel: 'instruction',
                          buttonAction: 'edit_instruction',
                          currentScreen: wizardScreenName(context),
                          onPressed: () => _edit(index, text),
                          builder: (context, onTile) => ListTile(
                            leading: ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_handle,
                                semanticLabel: l10n.reorder,
                              ),
                            ),
                            title: Text('${index + 1}. $text'),
                            onTap: onTile,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TrackedButton(
                                  buttonLabel: 'edit_step',
                                  buttonAction: 'edit_instruction',
                                  currentScreen: wizardScreenName(context),
                                  onPressed: () => _edit(index, text),
                                  builder: (context, onPressed) => IconButton(
                                    tooltip: l10n.editStep,
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: onPressed,
                                  ),
                                ),
                                TrackedButton(
                                  buttonLabel: 'remove_step',
                                  buttonAction: 'remove_instruction',
                                  currentScreen: wizardScreenName(context),
                                  onPressed: () =>
                                      _cubit.removeInstruction(index),
                                  builder: (context, onPressed) => IconButton(
                                    tooltip: l10n.removeStep,
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: onPressed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EditInstructionDialog extends StatefulWidget {
  const _EditInstructionDialog({
    required this.initial,
    required this.currentScreen,
  });

  final String initial;
  final String currentScreen;

  @override
  State<_EditInstructionDialog> createState() => _EditInstructionDialogState();
}

class _EditInstructionDialogState extends State<_EditInstructionDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.editStep),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: kInstructionMaxLength,
        minLines: 1,
        maxLines: 4,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          errorText: _valid ? null : l10n.stepCantBeEmpty,
        ),
      ),
      actions: [
        TrackedButton(
          buttonLabel: 'cancel',
          buttonAction: 'dismiss_edit_instruction',
          currentScreen: widget.currentScreen,
          onPressed: () => Navigator.of(context).pop(),
          builder: (context, onPressed) => TextButton(
            onPressed: onPressed,
            child: Text(l10n.cancel),
          ),
        ),
        TrackedButton(
          buttonLabel: 'save',
          buttonAction: 'save_instruction',
          currentScreen: widget.currentScreen,
          onPressed: _valid
              ? () => Navigator.of(context).pop(_controller.text)
              : null,
          builder: (context, onPressed) => FilledButton(
            onPressed: onPressed,
            child: Text(l10n.save),
          ),
        ),
      ],
    );
  }
}
