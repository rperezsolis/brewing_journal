import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/services/alarm_player.dart';
import 'brew_timer_state.dart';

/// Countdown / count-up timer for Brew Mode. The alarm runs only while this
/// cubit is open; [close] stops it and cancels the ticker.
class BrewTimerCubit extends Cubit<BrewTimerState> {
  BrewTimerCubit(this._alarm) : super(const BrewTimerState());

  final AlarmPlayer _alarm;

  Stopwatch? _stopwatch;
  Timer? _ticker;
  var _alarmPlayed = false;

  void configure(Duration? target) {
    _cancelTicker();
    _stopwatch = null;
    _alarmPlayed = false;
    if (target == null) {
      emit(const BrewTimerState());
      return;
    }
    emit(
      BrewTimerState(
        mode: BrewTimerMode.countDown,
        target: target,
        remaining: target,
      ),
    );
  }

  /// Switches count-down / count-up. Ignored unless the timer is idle and
  /// has a target.
  void setMode(BrewTimerMode mode) {
    if (state.phase != BrewTimerPhase.idle || state.target == null) return;
    if (mode == BrewTimerMode.idle) return;
    emit(state.copyWith(mode: mode));
  }

  /// No-op when there is no target. Prepares the alarm before the ticker so
  /// the later play is allowed on web (called from the Start tap).
  Future<void> start() async {
    if (state.mode == BrewTimerMode.idle || state.target == null) return;
    if (state.phase != BrewTimerPhase.idle) return;
    await _alarm.prepare();
    if (isClosed || state.phase != BrewTimerPhase.idle) return;
    _stopwatch = clock.stopwatch()..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => tick());
    emit(state.copyWith(phase: BrewTimerPhase.running));
  }

  void pause() {
    if (state.phase != BrewTimerPhase.running) return;
    _stopwatch?.stop();
    _ticker?.cancel();
    _ticker = null;
    _emitProgress(BrewTimerPhase.paused);
  }

  void resume() {
    if (state.phase != BrewTimerPhase.paused) return;
    _stopwatch?.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => tick());
    emit(state.copyWith(phase: BrewTimerPhase.running));
  }

  void stop() {
    _cancelTicker();
    _stopwatch
      ?..stop()
      ..reset();
    _alarmPlayed = false;
    unawaited(_alarm.stop());
    if (isClosed) return;
    emit(
      BrewTimerState(
        mode: state.mode == BrewTimerMode.idle
            ? BrewTimerMode.idle
            : state.mode,
        target: state.target,
        remaining: state.target,
      ),
    );
  }

  void tick() {
    if (state.phase != BrewTimerPhase.running) return;
    final elapsed = _stopwatch?.elapsed ?? Duration.zero;
    final target = state.target;
    if (target != null && elapsed >= target) {
      _cancelTicker();
      _stopwatch?.stop();
      emit(
        state.copyWith(
          phase: BrewTimerPhase.finished,
          elapsed: elapsed,
          remaining: Duration.zero,
        ),
      );
      if (!_alarmPlayed) {
        _alarmPlayed = true;
        unawaited(_alarm.play());
      }
      return;
    }
    _emitProgress(BrewTimerPhase.running, elapsed: elapsed);
  }

  void _emitProgress(BrewTimerPhase phase, {Duration? elapsed}) {
    final current = elapsed ?? _stopwatch?.elapsed ?? Duration.zero;
    final target = state.target;
    emit(
      state.copyWith(
        phase: phase,
        elapsed: current,
        remaining: target == null ? null : _remaining(target, current),
      ),
    );
  }

  static Duration _remaining(Duration target, Duration elapsed) {
    if (elapsed >= target) return Duration.zero;
    return target - elapsed;
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  Future<void> close() {
    _cancelTicker();
    _stopwatch?.stop();
    unawaited(_alarm.stop());
    return super.close();
  }
}
