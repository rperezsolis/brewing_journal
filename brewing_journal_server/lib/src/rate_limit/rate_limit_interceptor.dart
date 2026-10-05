import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'rate_limit_config.dart';

/// Counts RPC calls in a fixed window and throws [RateLimitException] when an
/// identity exceeds [RateLimitConfig.maxRequests].
///
/// Serverpod 4 has no endpoint-interceptor parameter on [Serverpod]. This
/// class wraps each generated [MethodConnector] (and stream connector) so the
/// check runs after authentication is attached to the session and before the
/// endpoint method. Register [install] with
/// [ExperimentalApi.registerStartHook]: hot reload rebuilds the connectors,
/// and start hooks run again after that rebuild.
///
/// Authenticated calls are keyed by [AuthenticationInfo.userIdentifier].
/// Calls with no signed-in user are keyed by [Request.remoteInfo] (the
/// `Forwarded` header, then `X-Forwarded-For`, then the socket address).
///
/// When Redis is enabled, the counter is an atomic `INCR` on the same Redis
/// instance as [Caches.global]. [Caches] has no `redis` getter; `global` is
/// the Redis-backed cache, and a get-then-put on it would lose increments
/// across servers. With Redis disabled, `global` is a process-local fallback
/// and this limiter updates that cache under a per-process lock.
class RateLimitInterceptor {
  const RateLimitInterceptor({
    this.config = const RateLimitConfig(),
    this.clock,
  });

  final RateLimitConfig config;

  /// Overrides the clock in tests. Production leaves this null and uses
  /// [DateTime.now].
  final DateTime Function()? clock;

  static const _fixedWindowScript = '''
local current = redis.call('INCR', KEYS[1])
local ttl = redis.call('PTTL', KEYS[1])
if ttl < 0 then
  redis.call('PEXPIRE', KEYS[1], ARGV[1])
end
return current
''';

  DateTime get _now => (clock ?? DateTime.now)();

  void _requirePositiveWindow() {
    if (config.window.inMicroseconds <= 0) {
      throw ArgumentError.value(
        config.window,
        'window',
        'must be positive',
      );
    }
  }

  /// Serializes local-cache increments for this process. One chain is enough:
  /// this path only runs when the process is not sharing Redis with other
  /// servers.
  static Future<void>? _localTail;

  /// Wraps every connector currently registered on [pod]. Safe to run again
  /// after hot reload replaces those connectors.
  void install(Serverpod pod) {
    _requirePositiveWindow();
    _wrapDispatch(pod.endpoints);
  }

  /// Rejects the call when [endpointPath] is over its limit.
  ///
  /// A Redis outage allows the call through and logs a warning. A brewing
  /// journal should stay available when the counter store is down.
  Future<void> enforce(
    Session session,
    String endpointPath,
    String methodName,
  ) async {
    _requirePositiveWindow();
    if (config.bypasses(endpointPath, methodName)) return;

    final now = _now;
    final identity = _identity(session);
    final key = 'rate-limit:$identity:${_windowStart(now)}';
    final count = await _increment(session, key);
    if (count == null || count <= config.maxRequests) return;

    final retryAfter = _retryAfterSeconds(now);
    session.setResponseHeader('Retry-After', '$retryAfter');
    session.log(
      'Rate limit exceeded for $endpointPath.$methodName',
      level: LogLevel.info,
    );
    throw RateLimitException(
      message: 'Too many requests. Try again in $retryAfter seconds.',
      retryAfterSeconds: retryAfter,
    );
  }

  void _wrapDispatch(EndpointDispatch dispatch, [String? moduleName]) {
    for (final connector in dispatch.connectors.values) {
      final endpointPath = moduleName == null
          ? connector.name
          : '$moduleName.${connector.name}';
      final names = connector.methodConnectors.keys.toList();
      for (final name in names) {
        final method = connector.methodConnectors[name]!;
        if (method is _LimitedMethodConnector ||
            method is _LimitedStreamConnector) {
          continue;
        }
        connector.methodConnectors[name] = switch (method) {
          MethodConnector() => _LimitedMethodConnector(
            inner: method,
            limiter: this,
            endpointPath: endpointPath,
          ),
          MethodStreamConnector() => _LimitedStreamConnector(
            inner: method,
            limiter: this,
            endpointPath: endpointPath,
          ),
          _ => method,
        };
      }
    }

    if (moduleName != null) return;
    for (final module in dispatch.modules.entries) {
      _wrapDispatch(module.value, module.key);
    }
  }

  String _identity(Session session) {
    final userId = session.authenticated?.userIdentifier;
    if (userId != null) return 'user:$userId';

    final request = session.request;
    if (request == null) return 'anonymous';
    try {
      final remote = request.remoteInfo;
      if (remote.isNotEmpty) return 'ip:$remote';
    } catch (error, stackTrace) {
      session.log(
        'Could not read the client address for rate limiting',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
    }
    return 'ip:${request.connectionInfo.remote.address}';
  }

  int _windowStart(DateTime now) {
    final windowMs = config.window.inMilliseconds;
    final nowMs = now.millisecondsSinceEpoch;
    return nowMs - (nowMs % windowMs);
  }

  int _retryAfterSeconds(DateTime now) {
    final windowMs = config.window.inMilliseconds;
    final remainingMs = windowMs - (now.millisecondsSinceEpoch % windowMs);
    final seconds = (remainingMs + 999) ~/ 1000;
    return seconds < 1 ? 1 : seconds;
  }

  Future<int?> _increment(Session session, String key) async {
    final redis = session.serverpod.redisController;
    if (redis != null) {
      try {
        return await _incrementRedis(redis, key);
      } catch (error, stackTrace) {
        session.log(
          'Rate limiter could not reach Redis; allowing the call',
          level: LogLevel.warning,
          exception: error,
          stackTrace: stackTrace,
        );
        return null;
      }
    }

    return _serialized(() async {
      final cache = session.caches.global;
      final current = await cache.get<int>(key) ?? 0;
      final next = current + 1;
      await cache.put<int>(key, next, lifetime: config.window);
      return next;
    });
  }

  Future<int?> _incrementRedis(RedisController redis, String key) async {
    final command = await redis.getConnection();
    if (command == null) return null;
    final result = await command.send_object([
      'EVAL',
      _fixedWindowScript,
      '1',
      key,
      '${config.window.inMilliseconds}',
    ]);
    if (result is int) return result;
    if (result is String) return int.parse(result);
    return null;
  }

  Future<T> _serialized<T>(Future<T> Function() action) {
    final previous = _localTail ?? Future<void>.value();
    final done = Completer<void>();
    _localTail = done.future;
    return previous.then((_) async {
      try {
        return await action();
      } finally {
        done.complete();
      }
    });
  }
}

class _LimitedMethodConnector extends MethodConnector {
  _LimitedMethodConnector({
    required MethodConnector inner,
    required RateLimitInterceptor limiter,
    required String endpointPath,
  }) : super(
         name: inner.name,
         params: inner.params,
         returnsVoid: inner.returnsVoid,
         call: (session, params) async {
           await limiter.enforce(session, endpointPath, inner.name);
           return inner.call(session, params);
         },
       );
}

class _LimitedStreamConnector extends MethodStreamConnector {
  _LimitedStreamConnector({
    required MethodStreamConnector inner,
    required RateLimitInterceptor limiter,
    required String endpointPath,
  }) : super(
         name: inner.name,
         params: inner.params,
         returnType: inner.returnType,
         streamParams: inner.streamParams,
         call: (session, params, streams) async {
           await limiter.enforce(session, endpointPath, inner.name);
           return inner.call(session, params, streams);
         },
       );
}
