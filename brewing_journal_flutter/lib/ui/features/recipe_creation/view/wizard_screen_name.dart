import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/analytics/screen_names.dart';
import '../cubit/recipe_creation_cubit.dart';

/// Screen id for the open wizard: create until a recipe id exists, then edit.
String wizardScreenName(BuildContext context) {
  return context.read<RecipeCreationCubit>().state.isEditing
      ? ScreenNames.recipeEdit
      : ScreenNames.recipeCreate;
}
