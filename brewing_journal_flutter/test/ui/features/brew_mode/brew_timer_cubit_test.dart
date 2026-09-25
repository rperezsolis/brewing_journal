import 'package:brewing_journal_flutter/data/services/alarm_player.dart';
import 'package:brewing_journal_flutter/ui/features/brew_mode/cubit/brew_timer_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/brew_mode/cubit/brew_timer_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAlarmPlayer alarm;
  late BrewTimerCubit cubit;

  setUp(() {
    alarm = FakeAlarmPlayer();
    cubit = BrewTimerCubit(alarm);
  });

  tearDown(() => cubit.close());

  test('configure(null) stays idle and start does not prepare the alarm', () {
    fakeAsync((async) {
      cubit.configure(null);
      expect(cubit.state.mode, BrewTimerMode.idle);
      expect(cubit.state.phase, BrewTimerPhase.idle);
      expect(cubit.state.target, isNull);

      cubit.start();
      async.flushMicrotasks();

      expect(cubit.state.phase, BrewTimerPhase.idle);
      expect(alarm.prepareCount, 0);
      expect(alarm.playCount, 0);
    });
  });

  test('start with a target prepares the alarm once', () {
    fakeAsync((async) {
      cubit.configure(const Duration(seconds: 5));
      cubit.start();
      async.flushMicrotasks();

      expect(alarm.prepareCount, 1);
      expect(cubit.state.phase, BrewTimerPhase.running);
    });
  });

  test('count-down to 3s plays the alarm once and clamps remaining', () {
    fakeAsync((async) {
      cubit.configure(const Duration(seconds: 3));
      cubit.start();
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 3));
      expect(cubit.state.phase, BrewTimerPhase.finished);
      expect(cubit.state.remaining, Duration.zero);
      expect(alarm.playCount, 1);

      cubit.tick();
      async.elapse(const Duration(seconds: 2));
      expect(alarm.playCount, 1);
    });
  });

  test('count-up to 3s also alarms at 3s', () {
    fakeAsync((async) {
      cubit.configure(const Duration(seconds: 3));
      cubit.setMode(BrewTimerMode.countUp);
      cubit.start();
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 3));
      expect(cubit.state.mode, BrewTimerMode.countUp);
      expect(cubit.state.phase, BrewTimerPhase.finished);
      expect(cubit.state.elapsed >= const Duration(seconds: 3), isTrue);
      expect(alarm.playCount, 1);
    });
  });

  test('pause freezes elapsed and resume continues from it', () {
    fakeAsync((async) {
      cubit.configure(const Duration(seconds: 10));
      cubit.start();
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 2));
      final frozen = cubit.state.elapsed;
      cubit.pause();
      expect(cubit.state.phase, BrewTimerPhase.paused);

      async.elapse(const Duration(seconds: 4));
      expect(cubit.state.elapsed, frozen);

      cubit.resume();
      async.elapse(const Duration(seconds: 1));
      expect(cubit.state.phase, BrewTimerPhase.running);
      expect(
        cubit.state.elapsed >= frozen + const Duration(seconds: 1),
        isTrue,
      );
    });
  });

  test('stop resets to idle and stops the alarm', () {
    fakeAsync((async) {
      cubit.configure(const Duration(seconds: 8));
      cubit.start();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 2));

      cubit.stop();
      expect(cubit.state.phase, BrewTimerPhase.idle);
      expect(cubit.state.elapsed, Duration.zero);
      expect(cubit.state.remaining, const Duration(seconds: 8));
      expect(alarm.stopCount, 1);
    });
  });

  test('setMode works only while idle', () {
    fakeAsync((async) {
      cubit.configure(const Duration(seconds: 5));
      cubit.setMode(BrewTimerMode.countUp);
      expect(cubit.state.mode, BrewTimerMode.countUp);

      cubit.start();
      async.flushMicrotasks();
      cubit.setMode(BrewTimerMode.countDown);
      expect(cubit.state.mode, BrewTimerMode.countUp);
    });
  });

  test('closing mid-run stops the alarm and later ticks never play', () {
    fakeAsync((async) {
      // The cubit must be created inside this zone; closing one from setUp
      // deadlocks StreamController.close against FakeAsync.
      final alarm = FakeAlarmPlayer();
      final cubit = BrewTimerCubit(alarm);
      cubit.configure(const Duration(seconds: 5));
      cubit.start();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 1));

      cubit.close();
      async.flushMicrotasks();
      expect(alarm.stopCount, 1);
      expect(alarm.playCount, 0);

      async.elapse(const Duration(seconds: 10));
      expect(alarm.playCount, 0);
    });
  });
}
