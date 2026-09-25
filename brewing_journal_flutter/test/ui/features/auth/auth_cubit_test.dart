import 'package:bloc_test/bloc_test.dart';
import 'package:brewing_journal_flutter/data/repositories/fake_auth_repository.dart';
import 'package:brewing_journal_flutter/ui/features/auth/cubit/auth_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/auth/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const unknown = AuthState();
  const authenticated = AuthState(status: AuthStatus.authenticated);
  const unauthenticated = AuthState(status: AuthStatus.unauthenticated);

  late FakeAuthRepository repository;

  tearDown(() => repository.dispose());

  test('initial state is unknown', () {
    repository = FakeAuthRepository();
    final cubit = AuthCubit(repository);
    expect(cubit.state, unknown);
    cubit.close();
  });

  blocTest<AuthCubit, AuthState>(
    'start() with a restored session emits authenticated',
    setUp: () => repository = FakeAuthRepository(hasStoredSession: true),
    build: () => AuthCubit(repository),
    act: (cubit) => cubit.start(),
    expect: () => [authenticated],
  );

  blocTest<AuthCubit, AuthState>(
    'start() without a stored session emits unauthenticated',
    setUp: () => repository = FakeAuthRepository(),
    build: () => AuthCubit(repository),
    act: (cubit) => cubit.start(),
    expect: () => [unauthenticated],
  );

  blocTest<AuthCubit, AuthState>(
    'a stream value of true emits authenticated, a later false unauthenticated',
    setUp: () => repository = FakeAuthRepository(),
    build: () => AuthCubit(repository),
    act: (cubit) async {
      repository.setAuthenticated(true);
      await Future<void>.delayed(Duration.zero);
      repository.setAuthenticated(false);
    },
    expect: () => [authenticated, unauthenticated],
  );

  blocTest<AuthCubit, AuthState>(
    'signOut() emits unauthenticated',
    setUp: () => repository = FakeAuthRepository(hasStoredSession: true),
    build: () => AuthCubit(repository),
    act: (cubit) async {
      await cubit.start();
      await cubit.signOut();
    },
    expect: () => [authenticated, unauthenticated],
  );
}
