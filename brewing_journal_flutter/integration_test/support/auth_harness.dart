import 'dart:async';
import 'dart:io';

import 'package:brewing_journal_flutter/app_scope.dart';
import 'package:brewing_journal_flutter/client.dart';
import 'package:brewing_journal_flutter/main.dart' as app;
import 'package:brewing_journal_flutter/router.dart';
import 'package:brewing_journal_flutter/ui/features/auth/cubit/auth_cubit.dart';
import 'package:brewing_journal_flutter/ui/features/recipe_list/view/recipe_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgres/postgres.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Drives the email sign-in UI against the development server.
///
/// Verification codes are not returned to the client. Development mode writes
/// `Registration code for alice@example.com: <12345678>` into `serverpod_log`,
/// and these tests read that row back.
class AuthHarness {
  var _opened = false;
  var _accountSequence = 0;
  Connection? _db;

  /// Email of the account created by [signUp], when one has been created.
  String? accountEmail;

  String freshEmail() {
    _accountSequence += 1;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return 'it$stamp$_accountSequence@example.com';
  }

  /// Shows the signed-out sign-up screen, signing out first when a session
  /// was restored from this Mac's keychain.
  Future<void> ensureSignedOut(WidgetTester tester) async {
    await openApp(tester);
    if (find.byType(RecipeListScreen).evaluate().isNotEmpty) {
      await signOut(tester);
    }
    expect(find.byKey(const ValueKey('sign-in')), findsOneWidget);
    expect(find.byType(RecipeListScreen), findsNothing);
  }

  Future<void> openApp(
    WidgetTester tester, {
    bool assertNoSignIn = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    if (!_opened) {
      await app.main();
      _opened = true;
    } else {
      await _mountFresh(tester);
    }
    await tester.pump();

    if (assertNoSignIn) {
      await _waitForHomeWithoutSignIn(tester);
      return;
    }
    await _waitUntil(
      tester,
      () =>
          find.byKey(const ValueKey('sign-in')).evaluate().isNotEmpty ||
          find.byType(RecipeListScreen).evaluate().isNotEmpty,
      'the sign-in screen or the journal',
    );
  }

  Future<void> signUp(
    WidgetTester tester,
    String email,
    String password,
  ) async {
    await _enterField(tester, 'Email', email);
    _blockPastedVerificationCode(tester);
    try {
      final code = await _continueToVerification(tester, email);
      await _submitCode(tester, code);
      await _waitFor(
        tester,
        find.text('Set account password'),
        'Set account password',
      );
      await _enterField(tester, 'Password', password);
      await _tapButton(tester, 'Sign up');
      await _waitFor(
        tester,
        find.byType(RecipeListScreen),
        'the journal',
      );
      expect(find.byKey(const ValueKey('sign-in')), findsNothing);
      accountEmail = email;
    } finally {
      _restoreClipboard(tester);
    }
  }

  Future<void> rejectVerificationCode(
    WidgetTester tester,
    String email,
  ) async {
    await _enterField(tester, 'Email', email);
    _blockPastedVerificationCode(tester);
    try {
      final code = await _continueToVerification(tester, email);
      await _submitCode(tester, _differentCode(code));
      await _waitFor(
        tester,
        find.textContaining('Invalid verification code'),
        'the invalid-code error',
      );
      expect(find.text('Verify account'), findsOneWidget);
      expect(find.byType(RecipeListScreen), findsNothing);
      expect(find.byKey(const ValueKey('sign-in')), findsOneWidget);
    } finally {
      _restoreClipboard(tester);
    }
  }

  Future<void> signOut(WidgetTester tester) async {
    final button = find.byKey(const ValueKey('sign-out'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await _waitFor(tester, find.byKey(const ValueKey('sign-in')), 'sign-in');
    expect(find.byType(RecipeListScreen), findsNothing);
  }

  Future<void> showLogin(WidgetTester tester) async {
    if (find.text('Sign In with email').evaluate().isNotEmpty) return;
    await tester.tap(find.widgetWithText(TextButton, 'Sign in'));
    await tester.pump();
    await _waitFor(
      tester,
      find.text('Sign In with email'),
      'Sign In with email',
    );
    await _waitUntil(
      tester,
      () => find.text('Sign Up with email').evaluate().isEmpty,
      'the sign-up form to leave',
    );
  }

  Future<void> expectRejectedLogin(
    WidgetTester tester,
    String email,
    String password,
  ) async {
    await showLogin(tester);
    for (final messenger in tester.stateList<ScaffoldMessengerState>(
      find.byType(ScaffoldMessenger),
    )) {
      messenger.clearSnackBars();
    }
    await tester.pump();
    await _enterField(tester, 'Email', email);
    await _enterField(tester, 'Password', password);
    await _tapButton(tester, 'Sign in');
    await _waitFor(
      tester,
      find.textContaining('Invalid email or password'),
      'the invalid-credentials error',
    );
    expect(find.text('Sign In with email'), findsOneWidget);
    expect(find.byType(RecipeListScreen), findsNothing);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> _mountFresh(WidgetTester tester) async {
    client.authSessionManager = createAuthSessionManager();
    final repositories = AppRepositories();
    final authCubit = AuthCubit(repositories.auth);
    unawaited(authCubit.start());
    await tester.pumpWidget(
      AppScope(
        repositories: repositories,
        authCubit: authCubit,
        child: app.BrewSyncApp(router: createRouter(authCubit)),
      ),
    );
  }

  Future<void> _waitForHomeWithoutSignIn(WidgetTester tester) async {
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    var sawSignIn = false;
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const ValueKey('sign-in')).evaluate().isNotEmpty) {
        sawSignIn = true;
      }
      if (find.byType(RecipeListScreen).evaluate().isNotEmpty) {
        expect(
          sawSignIn,
          isFalse,
          reason: 'A restored session showed the sign-in screen.',
        );
        return;
      }
    }
    fail('A restored session did not open the journal.');
  }

  Future<void> _enterField(
    WidgetTester tester,
    String label,
    String value,
  ) async {
    final field = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    );
    expect(field, findsOneWidget, reason: 'No "$label" field.');
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
    // Email validation notifies after a 500ms debounce, which enables Continue.
    await tester.pump(const Duration(milliseconds: 700));
  }

  Future<void> _tapButton(WidgetTester tester, String label) async {
    final deadline = DateTime.now().add(const Duration(seconds: 8));
    while (DateTime.now().isBefore(deadline)) {
      final button = _enabledButton(label);
      if (button.evaluate().isNotEmpty) {
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pump();
        return;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('No enabled "$label" button.');
  }

  Finder _enabledButton(String label) {
    return find.byWidgetPredicate((widget) {
      if (widget is! ElevatedButton || widget.onPressed == null) return false;
      final child = widget.child;
      return child is Text && child.data == label;
    });
  }

  /// Hides the development verification code from the pin field.
  ///
  /// The running server copies that code onto the system clipboard, and the
  /// pin field pastes anything of the right length. Reads are answered here
  /// so the test can type the code it intends.
  void _blockPastedVerificationCode(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    const codec = JSONMethodCodec();
    final channel = SystemChannels.platform.name;
    messenger.setMockMessageHandler(channel, (message) {
      if (message != null) {
        try {
          final call = codec.decodeMethodCall(message);
          if (call.method == 'Clipboard.getData') {
            return Future<ByteData?>.value(
              codec.encodeSuccessEnvelope(<String, dynamic>{'text': ''}),
            );
          }
          if (call.method == 'Clipboard.hasStrings') {
            return Future<ByteData?>.value(
              codec.encodeSuccessEnvelope(<String, dynamic>{'value': false}),
            );
          }
        } on FormatException {
          // Not a method call this handler understands.
        }
      }
      return messenger.delegate.send(channel, message);
    });
  }

  void _restoreClipboard(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      SystemChannels.platform.name,
      null,
    );
  }

  /// Starts registration and waits on the empty verification form.
  Future<String> _continueToVerification(
    WidgetTester tester,
    String email,
  ) async {
    await _tapButton(tester, 'Continue');
    final codeFuture = registrationCode(email);
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 16));
      if (find.text('Set account password').evaluate().isNotEmpty) {
        fail('A pasted verification code finished registration.');
      }
      final onVerify = find.text('Verify account').evaluate().isNotEmpty;
      final signingUp = find.text('Sign Up with email').evaluate().isNotEmpty;
      if (onVerify && !signingUp) {
        return codeFuture;
      }
    }
    fail('Timed out waiting for Verify account.');
  }

  Future<void> _submitCode(WidgetTester tester, String code) async {
    final pin = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == 'Pinput',
    );
    expect(pin, findsOneWidget, reason: 'No verification code field.');
    final editable = tester.widget<EditableText>(
      find.descendant(of: pin, matching: find.byType(EditableText)),
    );
    editable.controller.value = TextEditingValue(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );
    await tester.pump();
    expect(
      editable.controller.text,
      code,
      reason: 'Verification field did not keep the code.',
    );

    final deadline = DateTime.now().add(const Duration(milliseconds: 800));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Set account password').evaluate().isNotEmpty) return;
      if (find
          .textContaining('Invalid verification code')
          .evaluate()
          .isNotEmpty) {
        return;
      }
    }
    await _tapButton(tester, 'Verify');
  }

  String _differentCode(String code) {
    final chars = code.split('');
    chars[0] = chars[0] == '2' ? '3' : '2';
    final changed = chars.join();
    return changed == code ? '33333333' : changed;
  }

  Future<String> registrationCode(String email) async {
    final db = await _database();
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    final pattern = 'Registration code for $email: <%';
    while (DateTime.now().isBefore(deadline)) {
      final rows = await db.execute(
        Sql.named(
          'SELECT message FROM serverpod_log '
          'WHERE message LIKE @pattern:text '
          'ORDER BY id DESC LIMIT 1',
        ),
        parameters: {'pattern': pattern},
      );
      if (rows.isNotEmpty) {
        final message = rows.first.first! as String;
        final code = RegExp(r'<([1-9]{8})>').firstMatch(message)?.group(1);
        if (code != null) return code;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw StateError(
      'No registration code was logged for $email. '
      'The development server must be running (`serverpod start`).',
    );
  }

  Future<Connection> _database() async {
    final existing = _db;
    if (existing != null && existing.isOpen) return existing;

    final socket = _developmentSocket();
    final endpoint = socket != null
        ? Endpoint(
            host: socket.path,
            database: 'brewing_journal',
            username: 'postgres',
            isUnixSocket: true,
          )
        : Endpoint(
            host: '127.0.0.1',
            port: 8090,
            database: 'brewing_journal',
            username: 'postgres',
            password: _developmentDatabasePassword(),
          );
    try {
      final connection = await Connection.open(
        endpoint,
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 5),
        ),
      );
      _db = connection;
      return connection;
    } catch (error) {
      throw StateError(
        'Could not open the development database. '
        'Start it with `serverpod start`. ($error)',
      );
    }
  }

  /// Serverpod's development Postgres listens on a Unix socket, not TCP.
  ///
  /// macOS limits that path to 104 bytes, and the repo path is longer, so the
  /// connection goes through a short symlink.
  File? _developmentSocket() {
    final root = _projectRoot();
    if (root == null) return null;
    final directory = Directory(
      '$root/brewing_journal_server/.serverpod/development/run',
    );
    if (!File('${directory.path}/.s.PGSQL.5432').existsSync()) return null;

    const shortDirectory = '/tmp/brewing-journal-pg';
    final link = Link(shortDirectory);
    if (link.existsSync()) link.deleteSync();
    link.createSync(directory.path);
    final socket = File('$shortDirectory/.s.PGSQL.5432');
    if (socket.existsSync()) return socket;
    return null;
  }

  String _developmentDatabasePassword() {
    final fromEnvironment =
        Platform.environment['BREWING_JOURNAL_DEV_DB_PASSWORD'];
    if (fromEnvironment != null && fromEnvironment.isNotEmpty) {
      return fromEnvironment;
    }

    final file = _passwordsFile();
    if (file == null) {
      throw StateError(
        'Could not find brewing_journal_server/config/passwords.yaml '
        'from ${Directory.current.path}. Run this test from the Flutter '
        'package while the development server is running, or set '
        'BREWING_JOURNAL_DEV_DB_PASSWORD.',
      );
    }

    final lines = file.readAsLinesSync();
    var inDevelopment = false;
    for (final line in lines) {
      if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
      if (!line.startsWith(' ') && !line.startsWith('\t')) {
        inDevelopment = line.trim() == 'development:';
        continue;
      }
      if (!inDevelopment) continue;
      final match = RegExp(
        "^\\s*database:\\s*['\"]([^'\"]*)['\"]",
      ).firstMatch(line);
      if (match != null) return match.group(1)!;
    }
    throw StateError(
      'passwords.yaml has no development database password.',
    );
  }

  File? _passwordsFile() {
    final fromDefine = const String.fromEnvironment('PASSWORDS_FILE');
    final candidates = <String>[
      if (fromDefine.isNotEmpty) fromDefine,
      ?Platform.environment['BREWING_JOURNAL_PASSWORDS'],
      ?_passwordsPathFromStack(),
    ];
    for (final path in candidates) {
      final file = File(path);
      if (file.existsSync()) return file;
    }
    return null;
  }

  /// Debug builds keep source URIs in the stack, and the macOS test runs
  /// inside the app container, so [Directory.current] is not the project.
  String? _passwordsPathFromStack() {
    final root = _projectRoot();
    if (root == null) return null;
    return '$root/brewing_journal_server/config/passwords.yaml';
  }

  String? _projectRoot() {
    final match = RegExp(
      r'file://(/.+)/brewing_journal_flutter/integration_test/',
    ).firstMatch(StackTrace.current.toString());
    return match?.group(1);
  }

  Future<void> _waitFor(
    WidgetTester tester,
    Finder finder,
    String description,
  ) {
    return _waitUntil(
      tester,
      () => finder.evaluate().isNotEmpty,
      description,
    );
  }

  Future<void> _waitUntil(
    WidgetTester tester,
    bool Function() condition,
    String description,
  ) async {
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (condition()) return;
    }
    final visible = find
        .byType(Text)
        .evaluate()
        .map((element) {
          final widget = element.widget as Text;
          return widget.data ?? widget.textSpan?.toPlainText();
        })
        .whereType<String>()
        .where((text) => text.trim().isNotEmpty)
        .join(' | ');
    fail('Timed out waiting for $description. Visible text: $visible');
  }
}
