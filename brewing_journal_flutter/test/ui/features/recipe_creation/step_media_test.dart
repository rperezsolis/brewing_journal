import 'dart:async';
import 'dart:typed_data';

import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_ingredient_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_media_repository.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_recipe_repository.dart';
import 'package:brewing_journal_flutter/l10n/app_localizations.dart';
import 'package:brewing_journal_flutter/ui/core/locale_resolution.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/cubit/recipe_creation_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/photo_encoder.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_creation/view/step_media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  late FakeRecipeMediaRepository media;
  late RecipeCreationCubit cubit;
  late ImagePickerPlatform previousPicker;

  setUp(() async {
    final ingredients = FakeIngredientRepository();
    media = FakeRecipeMediaRepository();
    cubit = RecipeCreationCubit(
      recipes: FakeRecipeRepository(ingredients),
      ingredients: ingredients,
      media: media,
    );
    await cubit.registerIngredient(
      IngredientDraft(kind: BeverageKind.coffee, name: 'Ethiopia Guji'),
    );
    cubit
      ..setTitle('Morning V60')
      ..setWaterTemp(93)
      ..setDose(15)
      ..setWater(250)
      ..setGrindSize('Medium-fine')
      ..setGrinderModel('Comandante')
      ..setExtractionMethod(ExtractionMethod.v60);
    previousPicker = ImagePickerPlatform.instance;
  });

  tearDown(() async {
    ImagePickerPlatform.instance = previousPicker;
    await cubit.close();
  });

  Future<void> pump(
    WidgetTester tester, {
    WebpEncoder? encodeWebp,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: resolveBrewSyncLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: StepMedia(encodeWebp: encodeWebp),
          ),
        ),
      ),
    );
  }

  testWidgets('JPEG is uploaded without a processing dialog', (tester) async {
    final jpeg = img.encodeJpg(img.Image(width: 4, height: 4));
    ImagePickerPlatform.instance = _FixedPicker(jpeg);
    await pump(
      tester,
      encodeWebp: (_) async => fail('JPEG must not be converted'),
    );

    await tester.tap(find.byKey(const Key('media-add')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Processing images'), findsNothing);
    expect(media.uploadedContentTypes, ['image/jpeg']);
    expect(media.uploadedBytes.single, jpeg);
  });

  testWidgets('HEIC shows Processing images and uploads only WebP', (
    tester,
  ) async {
    final heic = Uint8List.fromList(const [
      0x00,
      0x00,
      0x00,
      0x18,
      0x66,
      0x74,
      0x79,
      0x70,
      0x68,
      0x65,
      0x69,
      0x63,
    ]);
    final webp = img.encodeWebP(img.Image(width: 4, height: 4));
    final gate = Completer<Uint8List>();
    ImagePickerPlatform.instance = _FixedPicker(heic);
    await pump(tester, encodeWebp: (_) => gate.future);

    await tester.tap(find.byKey(const Key('media-add')));
    await _until(tester, find.text('Processing images'));

    expect(media.uploadedBytes, isEmpty);
    gate.complete(webp);
    await _until(tester, find.text('Processing images'), present: false);

    expect(media.uploadedContentTypes, ['image/webp']);
    expect(media.uploadedBytes.single, webp);
    expect(media.uploadedBytes.single, isNot(heic));
  });
}

Future<void> _until(
  WidgetTester tester,
  Finder finder, {
  bool present = true,
}) async {
  for (var i = 0; i < 20; i++) {
    final found = finder.evaluate().isNotEmpty;
    if (found == present) return;
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, present ? findsOneWidget : findsNothing);
}

class _FixedPicker extends ImagePickerPlatform {
  _FixedPicker(this.bytes);

  final Uint8List bytes;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile.fromData(bytes, name: 'photo.bin');
  }
}
