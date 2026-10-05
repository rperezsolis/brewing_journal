/// Fixed-window limits applied to incoming RPC calls.
class RateLimitConfig {
  const RateLimitConfig({
    this.maxRequests = 100,
    this.window = const Duration(seconds: 60),
    this.bypassEndpoints = const {},
  }) : assert(maxRequests > 0, 'maxRequests must be positive');

  /// How many calls one identity may make inside [window].
  final int maxRequests;

  /// Length of one fixed window. Must be positive. The counter resets when
  /// the next window starts, not a sliding interval after each call.
  final Duration window;

  /// Endpoint paths that skip the limiter.
  ///
  /// A path is the connector name (`recipe`) or, for a module endpoint,
  /// `module.endpoint` (`serverpod_auth_idp.status`). A single method can be
  /// excluded with `endpoint.method` (`recipe.listMine`) without excluding
  /// the rest of that endpoint.
  final Set<String> bypassEndpoints;

  bool bypasses(String endpointPath, String methodName) {
    return bypassEndpoints.contains(endpointPath) ||
        bypassEndpoints.contains('$endpointPath.$methodName');
  }
}
