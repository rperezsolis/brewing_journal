import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/app_scope.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_auth_repository.dart';
import 'package:brewing_journal_flutter/data/services/analytics_service.dart';
import 'package:brewing_journal_flutter/ui/features/auth/cubit/auth_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tracks App Opened once after a restored session', (
    tester,
  ) async {
    final userId = const Uuid().v7obj();
    final auth = FakeAuthRepository(
      hasStoredSession: true,
      currentUserId: userId,
    );
    final analytics = _RecordingAnalyticsService();
    final cubit = AuthCubit(auth);

    await tester.pumpWidget(
      AppScope(
        repositories: AppRepositories.fake(auth: auth, analytics: analytics),
        authCubit: cubit,
        child: const SizedBox.shrink(),
      ),
    );
    await cubit.start();
    await tester.pump();

    expect(analytics.userIds, [userId.uuid]);
    expect(analytics.appOpens, [true]);

    await cubit.signOut();
    await tester.pump();

    expect(analytics.appOpens, [true]);
    expect(analytics.resetCount, 1);

    addTearDown(() async {
      await cubit.close();
      await auth.dispose();
    });
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('tracks App Opened signed out without a user id', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final analytics = _RecordingAnalyticsService();
    final cubit = AuthCubit(auth);

    await tester.pumpWidget(
      AppScope(
        repositories: AppRepositories.fake(auth: auth, analytics: analytics),
        authCubit: cubit,
        child: const SizedBox.shrink(),
      ),
    );
    await cubit.start();
    await tester.pump();

    expect(analytics.userIds, isEmpty);
    expect(analytics.resetCount, 0);
    expect(analytics.appOpens, [false]);

    addTearDown(() async {
      await cubit.close();
      await auth.dispose();
    });
  }, timeout: const Timeout(Duration(seconds: 20)));
}

class _RecordingAnalyticsService implements AnalyticsService {
  final userIds = <String?>[];
  final appOpens = <bool>[];
  var resetCount = 0;

  @override
  Future<void> start() async {}

  @override
  Future<void> setUserId(String? userId) async {
    userIds.add(userId);
  }

  @override
  Future<void> reset() async {
    resetCount += 1;
  }

  @override
  Future<void> trackAppOpened({required bool signedIn}) async {
    appOpens.add(signedIn);
  }
}
