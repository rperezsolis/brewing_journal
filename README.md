# BrewSync

BrewSync is a multi-user brewing journal for coffee, tea, and matcha. You record a recipe (ingredient, extraction parameters, flavor notes, extra instructions, and photos), replay it in Brew Mode with an in-app timer, share it with a team, and export a summary card through the device share sheet.

The app is a Flutter client backed by a [Serverpod](https://docs.serverpod.dev) 4 server. Sign-in is email and password through `serverpod_auth_idp`. Team viewer and editor roles live on a `team_membership` row and are checked in the recipe access policy.

## Layout

This repo is a Dart workspace (`pubspec.yaml` at the root).

| Package | Role |
| --- | --- |
| `brewing_journal_server` | Serverpod server: endpoints, models (`.spy.yaml`), migrations, and the web server that serves the Flutter web app |
| `brewing_journal_client` | Generated Serverpod client. Do not edit it by hand; it is rewritten by `serverpod generate` |
| `brewing_journal_flutter` | Flutter app (iOS, Android, web, and desktop). State is held in Cubits |

Product and architecture notes are in `docs/hackaton_sep_2026/`.

## Requirements

- Dart SDK `^3.12.2`
- Flutter `^3.44.4`
- [Serverpod CLI](https://docs.serverpod.dev) `4.0.2` (`dart install serverpod_cli@4.0.2`)

Local development and tests use Serverpod's embedded PostgreSQL (`database.dataPath` in the server config). Docker is not required. Redis is disabled in development.

`brewing_journal_server/config/passwords.yaml` is gitignored. It must exist on your machine with the development and test secrets (database, Redis, and the JWT keys read by `JwtConfigFromPasswords`) before the server or the tests will start.

## Run

From the server package, start the server. It also launches the Flutter app (`brewing_journal_flutter`, entrypoint `lib/driver.dart`):

```bash
cd brewing_journal_server
serverpod start
```

Press `Q` to shut the server down.

| Service | Port |
| --- | --- |
| API | 8080 |
| Insights | 8081 |
| Web (Flutter web app and invite links) | 8082 |

Team invite URLs are `http://localhost:8082/invite/<token>`. The link opens the web app. Native App Links and Universal Links are not used.

In development, email verification codes are written to the server log. Staging and production send them through Serverpod Cloud email.

`serverpod start` watches for file changes, regenerates the client when models or endpoints change, and hot reloads the server and the Flutter app. Stop it with `Q` and run `serverpod start` again when a change needs a full restart.

## Tests

Server tests start their own embedded PostgreSQL. No Docker:

```bash
cd brewing_journal_server
dart test
```

Flutter widget and cubit tests:

```bash
cd brewing_journal_flutter
flutter test
```

Continuous integration (`.github/workflows/tests.yml`) runs `serverpod generate` and `dart test` in the server package on pushes and pull requests to `main`.

## Models and migrations

Change protocol files under `brewing_journal_server/lib/src/` (`.spy.yaml` models and endpoint Dart files). Leave `brewing_journal_server/lib/src/generated/` and `brewing_journal_client` alone.

After a table change:

```bash
cd brewing_journal_server
serverpod create-migration
```

`serverpod start` applies pending migrations when the server boots. New databases are created from each migration's `definition.sql`.
