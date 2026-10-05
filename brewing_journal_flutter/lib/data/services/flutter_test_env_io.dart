import 'dart:io';

/// True when this process was started by `flutter test`, including
/// integration tests. Those runs must not ingest product analytics.
bool get isFlutterTestEnvironment =>
    Platform.environment['FLUTTER_TEST'] == 'true';
