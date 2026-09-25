import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    _subscription = _repository.authStateChanges.listen(_emitFrom);
  }

  final AuthRepository _repository;
  late final StreamSubscription<bool> _subscription;

  /// Restores a persisted session and resolves the `unknown` status.
  ///
  /// Needed because [AuthRepository.authStateChanges] only fires on changes,
  /// so a restored session would otherwise stay `unknown`.
  Future<void> start() async {
    try {
      await _repository.restore();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    if (isClosed) return;
    _emitFrom(_repository.isAuthenticated);
  }

  Future<void> signOut() => _repository.signOut();

  void _emitFrom(bool isAuthenticated) {
    emit(
      AuthState(
        status: isAuthenticated
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
