import 'dart:typed_data';

import 'package:brewing_journal_flutter/data/services/share_service.dart';
import 'package:brewing_journal_flutter/ui/features/share/cubit/share_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/share/cubit/share_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  late FakeShareService share;
  late ShareCubit cubit;

  setUp(() {
    share = FakeShareService();
    cubit = ShareCubit(share);
  });

  tearDown(() => cubit.close());

  test('beginRender goes to rendering', () {
    cubit.beginRender();
    expect(cubit.state.status, ShareStatus.rendering);
  });

  test('a dismissed share goes back to idle', () async {
    share.nextStatus = ShareResultStatus.dismissed;
    cubit.beginRender();
    await cubit.share(Uint8List.fromList([1, 2, 3]), 'Morning V60');
    expect(cubit.state.status, ShareStatus.idle);
    expect(cubit.state.pngBytes, Uint8List.fromList([1, 2, 3]));
    expect(share.lastTitle, 'Morning V60');
  });

  test('an unavailable share goes to unavailable', () async {
    share.nextStatus = ShareResultStatus.unavailable;
    await cubit.share(Uint8List.fromList([1]), 'Morning V60');
    expect(cubit.state.status, ShareStatus.unavailable);
  });

  test('a thrown share goes to unavailable', () async {
    share.shareError = Exception('no share sheet');
    await cubit.share(Uint8List.fromList([1]), 'Morning V60');
    expect(cubit.state.status, ShareStatus.unavailable);
    expect(cubit.state.pngBytes, isNotNull);
  });

  test('a failed download goes to failure', () async {
    share.nextStatus = ShareResultStatus.unavailable;
    await cubit.share(Uint8List.fromList([9]), 'Morning V60');
    share.downloadError = Exception('disk full');
    await cubit.download();
    expect(cubit.state.status, ShareStatus.failure);
    expect(share.downloadCount, 1);
  });
}
