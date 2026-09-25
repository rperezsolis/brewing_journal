import 'package:equatable/equatable.dart';

enum BrewTimerMode { idle, countUp, countDown }

enum BrewTimerPhase { idle, running, paused, finished }

class BrewTimerState extends Equatable {
  const BrewTimerState({
    this.mode = BrewTimerMode.idle,
    this.phase = BrewTimerPhase.idle,
    this.target,
    this.elapsed = Duration.zero,
    this.remaining,
  });

  final BrewTimerMode mode;
  final BrewTimerPhase phase;

  /// `recipe.extractionDuration`. Null means no timer controls.
  final Duration? target;
  final Duration elapsed;
  final Duration? remaining;

  /// The value shown on the large readout: remaining for count-down,
  /// elapsed for count-up.
  Duration get display {
    if (mode == BrewTimerMode.countUp) return elapsed;
    return remaining ?? Duration.zero;
  }

  BrewTimerState copyWith({
    BrewTimerMode? mode,
    BrewTimerPhase? phase,
    Duration? target,
    Duration? elapsed,
    Duration? remaining,
  }) {
    return BrewTimerState(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      target: target ?? this.target,
      elapsed: elapsed ?? this.elapsed,
      remaining: remaining ?? this.remaining,
    );
  }

  @override
  List<Object?> get props => [mode, phase, target, elapsed, remaining];
}
