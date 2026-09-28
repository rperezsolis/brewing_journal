import 'dart:async';

import 'package:brewing_journal_client/brewing_journal_client.dart';

import 'auth_repository.dart';

/// In-memory [AuthRepository] for tests and previews.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.hasStoredSession = false, this.currentUserId});

  /// Whether [restore] finds a persisted session.
  final bool hasStoredSession;
  final _controller = StreamController<bool>.broadcast();
  bool _isAuthenticated = false;

  @override
  UuidValue? currentUserId;

  @override
  Stream<bool> get authStateChanges => _controller.stream;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> restore() async {
    _isAuthenticated = hasStoredSession;
  }

  @override
  Future<void> signOut() async => setAuthenticated(false);

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    _controller.add(value);
  }

  Future<void> dispose() => _controller.close();
}
