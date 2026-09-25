import 'package:brewing_journal_flutter/ui/core/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatStopwatch shows mm:ss.t', () {
    expect(formatStopwatch(Duration.zero), '00:00.0');
    expect(
      formatStopwatch(
        const Duration(minutes: 2, seconds: 5, milliseconds: 340),
      ),
      '02:05.3',
    );
  });

  test('formatDuration round-trips through parseDuration', () {
    for (final duration in const [
      Duration(seconds: 30),
      Duration(minutes: 3, seconds: 5),
      Duration(minutes: 1, milliseconds: 500),
    ]) {
      expect(parseDuration(formatDuration(duration)), duration);
    }
  });

  test('parseDuration accepts m:ss, tenths, and plain seconds', () {
    expect(parseDuration('2:30'), const Duration(minutes: 2, seconds: 30));
    expect(
      parseDuration('0:27,5'),
      const Duration(seconds: 27, milliseconds: 500),
    );
    expect(parseDuration('90'), const Duration(seconds: 90));
  });

  test('parseDuration rejects malformed input', () {
    for (final text in ['', 'abc', '1:75', '1:2:3', '-5']) {
      expect(parseDuration(text), isNull, reason: text);
    }
  });
}
