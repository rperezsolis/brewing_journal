import 'package:audioplayers/audioplayers.dart';

/// In-app alarm used by Brew Mode. The sound loops until [stop].
abstract class AlarmPlayer {
  /// Loads the alarm asset. Called from [BrewTimerCubit.start] so the later
  /// play is tied to a user gesture on web.
  Future<void> prepare();

  Future<void> play();

  Future<void> stop();
}

/// [AlarmPlayer] backed by [audioplayers].
class AudioAlarmPlayer implements AlarmPlayer {
  AudioAlarmPlayer({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  static const assetPath = 'sounds/brew_alarm.mp3';

  final AudioPlayer _player;

  @override
  Future<void> prepare() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setSource(AssetSource(assetPath));
  }

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> stop() => _player.stop();
}

/// Counts calls, for tests and widget previews.
class FakeAlarmPlayer implements AlarmPlayer {
  int prepareCount = 0;
  int playCount = 0;
  int stopCount = 0;

  @override
  Future<void> prepare() async {
    prepareCount++;
  }

  @override
  Future<void> play() async {
    playCount++;
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }
}
