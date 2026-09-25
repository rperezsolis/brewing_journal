/// `mm:ss.t`, as shown by a running stopwatch.
String formatStopwatch(Duration duration) {
  final tenths = duration.inMilliseconds ~/ 100;
  final minutes = tenths ~/ 600;
  final seconds = (tenths ~/ 10) % 60;
  return '${_two(minutes)}:${_two(seconds)}.${tenths % 10}';
}

/// `m:ss`, or `m:ss.t` when there are tenths; the format [parseDuration] reads.
String formatDuration(Duration duration) {
  final tenths = duration.inMilliseconds ~/ 100;
  final minutes = tenths ~/ 600;
  final seconds = (tenths ~/ 10) % 60;
  final fraction = tenths % 10 == 0 ? '' : '.${tenths % 10}';
  return '$minutes:${_two(seconds)}$fraction';
}

final _durationPattern = RegExp(r'^(?:(\d+):)?(\d+)(?:[.,](\d))?$');

/// Reads `m:ss`, `m:ss.t`, or plain seconds (`90`). Returns null when [text]
/// is not a duration.
Duration? parseDuration(String text) {
  final match = _durationPattern.firstMatch(text.trim());
  if (match == null) return null;
  final minutes = match[1] == null ? 0 : int.parse(match[1]!);
  final seconds = int.parse(match[2]!);
  if (match[1] != null && seconds >= 60) return null;
  final tenths = match[3] == null ? 0 : int.parse(match[3]!);
  return Duration(
    minutes: minutes,
    seconds: seconds,
    milliseconds: tenths * 100,
  );
}

String _two(int value) => value.toString().padLeft(2, '0');
