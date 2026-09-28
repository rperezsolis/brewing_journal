import 'package:brewing_journal_flutter/ui/features/invite/invite_token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('takes the last path segment of a URL', () {
    expect(
      inviteTokenFromInput('http://localhost:8082/invite/abc'),
      'abc',
    );
  });

  test('accepts a bare token', () {
    expect(inviteTokenFromInput('  abc  '), 'abc');
  });
}
