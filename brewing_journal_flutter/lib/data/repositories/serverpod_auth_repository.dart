import 'dart:async';

import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'auth_repository.dart';

class ServerpodAuthRepository implements AuthRepository {
  ServerpodAuthRepository(this._auth);

  final FlutterAuthSessionManager _auth;

  @override
  Stream<bool> get authStateChanges {
    late final StreamController<bool> controller;
    void onChange() => controller.add(_auth.isAuthenticated);
    controller = StreamController<bool>(
      onListen: () => _auth.authInfoListenable.addListener(onChange),
      onCancel: () => _auth.authInfoListenable.removeListener(onChange),
    );
    return controller.stream;
  }

  @override
  bool get isAuthenticated => _auth.isAuthenticated;

  @override
  Future<void> restore() async {
    await _auth.initialize();
  }

  @override
  Future<void> signOut() async {
    await _auth.signOutDevice();
  }
}
