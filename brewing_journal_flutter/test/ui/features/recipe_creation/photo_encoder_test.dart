import 'dart:typed_data';

import 'package:brewing_journal_flutter/ui/features/recipe_creation/photo_encoder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('JPEG bytes pass through unchanged', () {
    final jpeg = img.encodeJpg(img.Image(width: 4, height: 4));
    final result = encodeBytesAsJpeg(jpeg);
    expect(Uint8List.sublistView(result), jpeg);
  });

  test('PNG bytes are re-encoded as JPEG', () {
    final png = img.encodePng(img.Image(width: 4, height: 4));
    expect(isJpeg(png), isFalse);

    final result = Uint8List.sublistView(encodeBytesAsJpeg(png));
    expect(isJpeg(result), isTrue);
  });

  test('a large PNG is shrunk to the max edge', () {
    final png = img.encodePng(img.Image(width: 3000, height: 1000));
    final result = img.decodeJpg(
      Uint8List.sublistView(encodeBytesAsJpeg(png)),
    )!;
    expect(result.width, kPhotoMaxEdge);
  });

  test('unknown bytes are rejected', () {
    expect(
      () => encodeBytesAsJpeg(Uint8List.fromList([1, 2, 3, 4])),
      throwsFormatException,
    );
  });
}
