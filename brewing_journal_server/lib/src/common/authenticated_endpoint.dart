import 'package:serverpod/serverpod.dart';

/// Base class for every domain endpoint: all methods require a signed-in user.
abstract class AuthenticatedEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
}
