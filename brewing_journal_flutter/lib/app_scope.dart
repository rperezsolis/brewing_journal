import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/serverpod_auth_repository.dart';
import 'ui/features/auth/cubit/auth_cubit.dart';

/// App-level repositories, backed by the global Serverpod [client].
class AppRepositories {
  AppRepositories() : auth = ServerpodAuthRepository(client.auth);

  AppRepositories.custom({required this.auth});

  final AuthRepository auth;
}

/// Provides the app-level repositories and session-scoped Cubits to every
/// route. The [authCubit] is created outside so the router can share it.
class AppScope extends StatelessWidget {
  const AppScope({
    super.key,
    required this.repositories,
    required this.authCubit,
    required this.child,
  });

  final AppRepositories repositories;
  final AuthCubit authCubit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: repositories.auth),
      ],
      child: MultiBlocProvider(
        providers: [BlocProvider<AuthCubit>.value(value: authCubit)],
        child: child,
      ),
    );
  }
}
