import 'dart:convert';

import 'package:brewing_journal_server/src/generated/protocol.dart';
import 'package:brewing_journal_server/src/rate_limit/rate_limit_config.dart';
import 'package:brewing_journal_server/src/rate_limit/rate_limit_interceptor.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../helpers/test_users.dart';
import '../test_tools/serverpod_test_tools.dart';

/// Calls the wrapped `recipe.listMine` connector.
///
/// The generated test client casts `method.call` to `Future<List<Recipe>>`.
/// The limiter returns the inner result from a new future, so that cast does
/// not hold. Production awaits the call without that cast.
Future<List<Recipe>> _listMine(TestSessionBuilder builder) async {
  final session = builder.build();
  final parameters =
      jsonDecode(
            SerializationManager.encodeForProtocol({
              'limit': 10,
              'offset': 0,
            }),
          )
          as Map<String, dynamic>;
  final context = await session.server.endpoints.getMethodCallContext(
    createSessionCallback: (_) => session,
    endpointPath: 'recipe',
    methodName: 'listMine',
    parameters: parameters,
    serializationManager: session.server.serializationManager,
  );
  final result = await context.method.call(session, context.arguments);
  return List<Recipe>.from(result as List);
}

void main() {
  withServerpod(
    'Given a fixed window of 2 calls',
    (sessionBuilder, endpoints) {
      late TestUser user;

      setUp(() async {
        user = await createTestUser(sessionBuilder);
        final session = sessionBuilder.build();
        await session.caches.global.clear();
        const RateLimitInterceptor(
          config: RateLimitConfig(
            maxRequests: 2,
            window: Duration(seconds: 60),
          ),
        ).install(session.server.serverpod);
      });

      test(
        'when the caller stays within the limit then listMine succeeds',
        () async {
          await _listMine(user.sessionBuilder);
          final recipes = await _listMine(user.sessionBuilder);

          expect(recipes, isEmpty);
        },
      );

      test(
        'when the caller exceeds the limit then RateLimitException '
        'carries retryAfterSeconds',
        () async {
          await _listMine(user.sessionBuilder);
          await _listMine(user.sessionBuilder);

          await expectLater(
            _listMine(user.sessionBuilder),
            throwsA(
              isA<RateLimitException>()
                  .having((error) => error.message, 'message', isNotEmpty)
                  .having(
                    (error) => error.retryAfterSeconds,
                    'retryAfterSeconds',
                    inInclusiveRange(1, 60),
                  ),
            ),
          );
        },
      );

      test(
        'when a second user calls then their quota is separate',
        () async {
          final other = await createTestUser(sessionBuilder);
          await _listMine(user.sessionBuilder);
          await _listMine(user.sessionBuilder);

          final recipes = await _listMine(other.sessionBuilder);

          expect(recipes, isEmpty);
        },
      );

      test('when the window elapses then the counter resets', () async {
        var now = DateTime.utc(2026, 1, 1, 0, 0, 30);
        final timed = RateLimitInterceptor(
          config: const RateLimitConfig(
            maxRequests: 1,
            window: Duration(seconds: 60),
          ),
          clock: () => now,
        );
        final session = user.sessionBuilder.build();

        await timed.enforce(session, 'recipe', 'listMine');
        await expectLater(
          timed.enforce(session, 'recipe', 'listMine'),
          throwsA(isA<RateLimitException>()),
        );

        now = DateTime.utc(2026, 1, 1, 0, 1, 0);
        await timed.enforce(session, 'recipe', 'listMine');
      });

      test(
        'when one method is bypassed then other methods on that endpoint '
        'are still limited',
        () async {
          final timed = const RateLimitInterceptor(
            config: RateLimitConfig(
              maxRequests: 1,
              window: Duration(seconds: 60),
              bypassEndpoints: {'recipe.listMine'},
            ),
          );
          final session = user.sessionBuilder.build();

          await timed.enforce(session, 'recipe', 'listMine');
          await timed.enforce(session, 'recipe', 'listMine');
          await timed.enforce(session, 'recipe', 'get');
          await expectLater(
            timed.enforce(session, 'recipe', 'get'),
            throwsA(isA<RateLimitException>()),
          );
        },
      );

      test(
        'when one call is anonymous and one is signed in then each has a quota',
        () async {
          final timed = const RateLimitInterceptor(
            config: RateLimitConfig(
              maxRequests: 1,
              window: Duration(seconds: 60),
            ),
          );
          await timed.enforce(sessionBuilder.build(), 'recipe', 'listMine');
          await timed.enforce(
            user.sessionBuilder.build(),
            'recipe',
            'listMine',
          );
        },
      );
    },
  );

  withServerpod(
    'Given the recipe endpoint is bypassed',
    (sessionBuilder, endpoints) {
      late TestUser user;

      setUp(() async {
        user = await createTestUser(sessionBuilder);
        final session = sessionBuilder.build();
        await session.caches.global.clear();
        const RateLimitInterceptor(
          config: RateLimitConfig(
            maxRequests: 1,
            window: Duration(seconds: 60),
            bypassEndpoints: {'recipe'},
          ),
        ).install(session.server.serverpod);
      });

      test(
        'when calls exceed the limit then listMine still succeeds',
        () async {
          await _listMine(user.sessionBuilder);
          final recipes = await _listMine(user.sessionBuilder);

          expect(recipes, isEmpty);
        },
      );
    },
  );
}
