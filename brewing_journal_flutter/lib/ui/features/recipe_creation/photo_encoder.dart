import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platform_image_converter/platform_image_converter.dart';

const kPhotoMaxEdge = 2048;
const kPhotoJpegQuality = 85;

/// Formats stored as picked. Everything else is converted to WebP first.
enum StoredPhotoFormat { jpeg, png, webp }

/// Bytes ready to upload, and the content type the server should store.
///
/// [bytes] is the WebP encoding when [format] is [StoredPhotoFormat.webp].
/// The original file is not retained.
class PreparedPhoto {
  const PreparedPhoto(this.bytes, this.format);

  final ByteData bytes;
  final StoredPhotoFormat format;

  String get contentType => switch (format) {
    StoredPhotoFormat.jpeg => 'image/jpeg',
    StoredPhotoFormat.png => 'image/png',
    StoredPhotoFormat.webp => 'image/webp',
  };
}

/// Converts [input] to WebP. Tests replace this so they skip native codecs.
typedef WebpEncoder = Future<Uint8List> Function(Uint8List input);

/// True when [bytes] can be stored without conversion.
bool storesWithoutConversion(Uint8List bytes) => isJpeg(bytes) || isPng(bytes);

/// Reads a picked photo and returns the bytes that should be uploaded.
Future<PreparedPhoto> preparePickedPhoto(
  XFile file, {
  WebpEncoder? encodeWebp,
}) {
  return file.readAsBytes().then(
    (bytes) => preparePhotoBytes(bytes, encodeWebp: encodeWebp),
  );
}

/// JPEG and PNG pass through. Every other format is encoded as WebP and the
/// original bytes are dropped.
Future<PreparedPhoto> preparePhotoBytes(
  Uint8List bytes, {
  WebpEncoder? encodeWebp,
}) async {
  if (isJpeg(bytes)) {
    return PreparedPhoto(ByteData.sublistView(bytes), StoredPhotoFormat.jpeg);
  }
  if (isPng(bytes)) {
    return PreparedPhoto(ByteData.sublistView(bytes), StoredPhotoFormat.png);
  }

  final Uint8List webp;
  try {
    webp = await (encodeWebp ?? encodeAsWebp)(bytes);
  } on ImageConversionException {
    throw const FormatException('This image format is not supported');
  }
  if (!isWebp(webp)) {
    throw const FormatException('This image format is not supported');
  }
  return PreparedPhoto(ByteData.sublistView(webp), StoredPhotoFormat.webp);
}

/// Encodes [input] as WebP, shrinking it so the long edge is at most
/// [kPhotoMaxEdge].
///
/// The web backend draws on the page canvas, which a background isolate
/// cannot reach, so that platform converts on the calling isolate.
Future<Uint8List> encodeAsWebp(Uint8List input) {
  return ImageConverter.convert(
    inputData: input,
    format: OutputFormat.webp,
    quality: kPhotoJpegQuality,
    resizeMode: const FitResizeMode(
      width: kPhotoMaxEdge,
      height: kPhotoMaxEdge,
    ),
    runInIsolate: !kIsWeb,
  );
}

/// Checks the JPEG magic bytes; `XFile.mimeType` is often null on mobile.
bool isJpeg(Uint8List bytes) =>
    bytes.length > 2 &&
    bytes[0] == 0xFF &&
    bytes[1] == 0xD8 &&
    bytes[2] == 0xFF;

/// Checks the PNG signature.
bool isPng(Uint8List bytes) =>
    bytes.length >= 8 &&
    bytes[0] == 0x89 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x4E &&
    bytes[3] == 0x47 &&
    bytes[4] == 0x0D &&
    bytes[5] == 0x0A &&
    bytes[6] == 0x1A &&
    bytes[7] == 0x0A;

/// Checks the RIFF/WEBP header.
bool isWebp(Uint8List bytes) =>
    bytes.length >= 12 &&
    bytes[0] == 0x52 &&
    bytes[1] == 0x49 &&
    bytes[2] == 0x46 &&
    bytes[3] == 0x46 &&
    bytes[8] == 0x57 &&
    bytes[9] == 0x45 &&
    bytes[10] == 0x42 &&
    bytes[11] == 0x50;
