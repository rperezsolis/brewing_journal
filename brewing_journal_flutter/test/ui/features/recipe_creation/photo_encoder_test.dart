import 'dart:typed_data';

import 'package:brewing_journal_flutter/ui/features/recipe_creation/photo_encoder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:platform_image_converter/platform_image_converter.dart';

void main() {
  test('JPEG bytes pass through unchanged', () async {
    final jpeg = img.encodeJpg(img.Image(width: 4, height: 4));
    final result = await preparePhotoBytes(jpeg);
    expect(result.format, StoredPhotoFormat.jpeg);
    expect(Uint8List.sublistView(result.bytes), jpeg);
  });

  test('PNG bytes pass through unchanged', () async {
    final png = img.encodePng(img.Image(width: 4, height: 4));
    expect(isPng(png), isTrue);
    expect(storesWithoutConversion(png), isTrue);

    final result = await preparePhotoBytes(
      png,
      encodeWebp: (_) async => fail('PNG must not be converted'),
    );
    expect(result.format, StoredPhotoFormat.png);
    expect(Uint8List.sublistView(result.bytes), png);
  });

  test('HEIC bytes are stored as WebP and the original is dropped', () async {
    final heic = Uint8List.fromList(const [
      0x00, 0x00, 0x00, 0x18, //
      0x66, 0x74, 0x79, 0x70, // ftyp
      0x68, 0x65, 0x69, 0x63, // heic
    ]);
    final webp = _webpHeader();
    Uint8List? seen;

    final result = await preparePhotoBytes(
      heic,
      encodeWebp: (input) async {
        seen = Uint8List.fromList(input);
        return webp;
      },
    );

    expect(seen, heic);
    expect(result.format, StoredPhotoFormat.webp);
    expect(result.contentType, 'image/webp');
    expect(Uint8List.sublistView(result.bytes), webp);
    expect(Uint8List.sublistView(result.bytes), isNot(heic));
  });

  test('a converter failure is a format error', () {
    expect(
      preparePhotoBytes(
        Uint8List.fromList(const [1, 2, 3, 4]),
        encodeWebp: (_) async => throw const ImageDecodingException('nope'),
      ),
      throwsFormatException,
    );
  });

  test('a converter that does not return WebP is a format error', () {
    expect(
      preparePhotoBytes(
        Uint8List.fromList(const [1, 2, 3, 4]),
        encodeWebp: (_) async => Uint8List.fromList(const [1, 2, 3, 4]),
      ),
      throwsFormatException,
    );
  });
}

Uint8List _webpHeader() => Uint8List.fromList(const [
  0x52, 0x49, 0x46, 0x46, //
  0x00, 0x00, 0x00, 0x00, //
  0x57, 0x45, 0x42, 0x50,
]);
