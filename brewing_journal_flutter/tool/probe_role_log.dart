import 'dart:io';

import 'package:postgres/postgres.dart';

Future<void> main() async {
  final root = Directory.current.path.endsWith('brewing_journal_flutter')
      ? Directory.current.parent.path
      : Directory.current.path;
  final socketDir = Directory(
    '$root/brewing_journal_server/.serverpod/development/run',
  );
  const short = '/tmp/brewing-journal-pg';
  final link = Link(short);
  if (link.existsSync()) link.deleteSync();
  link.createSync(socketDir.path);

  final connection = await Connection.open(
    Endpoint(
      host: '$short/.s.PGSQL.5432',
      database: 'brewing_journal',
      username: 'postgres',
      isUnixSocket: true,
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
  final rows = await connection.execute(
    "SELECT \"logLevel\", left(message, 500) FROM serverpod_log "
    "WHERE message LIKE '%Role change%' ORDER BY id DESC LIMIT 5",
  );
  for (final row in rows) {
    stdout.writeln('--- level ${row[0]} ---');
    stdout.writeln(row[1]);
  }
  if (rows.isEmpty) stdout.writeln('no role-change rows');
  await connection.close();
}
