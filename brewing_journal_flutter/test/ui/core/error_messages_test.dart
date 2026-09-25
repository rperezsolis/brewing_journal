import 'package:brewing_journal_client/brewing_journal_client.dart';
import 'package:brewing_journal_flutter/ui/core/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a client network error maps to the connection message', () {
    expect(
      errorMessage(const ServerpodClientNetworkException('down')),
      connectionErrorMessage,
    );
  });

  test('any other client error maps to the connection message', () {
    expect(
      errorMessage(ServerpodClientInternalServerError()),
      connectionErrorMessage,
    );
  });

  test('an unknown error maps to the generic message', () {
    expect(errorMessage(StateError('boom')), genericErrorMessage);
  });
}
