import 'package:brewing_journal_flutter/ui/features/share/share_card_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('zero instructions give no rows', () {
    final preview = visibleInstructions(const []);
    expect(preview.rows, isEmpty);
    expect(preview.moreCount, 0);
  });

  test('one instruction is shown in full', () {
    final preview = visibleInstructions(const ['bloom']);
    expect(preview.rows, ['bloom']);
    expect(preview.moreCount, 0);
  });

  test('four instructions are shown in full', () {
    final preview = visibleInstructions(const ['a', 'b', 'c', 'd']);
    expect(preview.rows, ['a', 'b', 'c', 'd']);
    expect(preview.moreCount, 0);
  });

  test('five instructions keep the first three and count the rest', () {
    final preview = visibleInstructions(const ['a', 'b', 'c', 'd', 'e']);
    expect(preview.rows, ['a', 'b', 'c']);
    expect(preview.moreCount, 2);
  });

  test('thirty instructions keep the first three and count the rest', () {
    final preview = visibleInstructions([
      for (var i = 0; i < 30; i++) 'step $i',
    ]);
    expect(preview.rows, ['step 0', 'step 1', 'step 2']);
    expect(preview.moreCount, 27);
  });
}
