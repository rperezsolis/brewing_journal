![Cata Café coffee journal](brewing_journal_flutter/assets/images/cata_cafe_iso_plus_logo.PNG)

# BrewSync - Cata Café

BrewSync (a.k.a. Cata Café) is a multi-user brewing journal for coffee, tea, and matcha. You record a recipe (ingredient, extraction parameters, flavor notes, extra instructions, and photos), replay it in Brew Mode with an in-app timer, save a personal or team favorite, share it with a team, and export a summary card through the device share sheet. It is the ultimate collaborative tool for refining your personal/team coffee, matcha, and tea recipes.

The app is a Flutter client backed by a [Serverpod](https://docs.serverpod.dev) 4 server. Sign-in is email and password through `serverpod_auth_idp`. Team viewer and editor roles live on a `team_membership` row and are checked in the recipe access policy.

## Layout

This repo is a Dart workspace (`pubspec.yaml` at the root).


| Package                   | Role                                                                                                              |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `brewing_journal_server`  | Serverpod server: endpoints, models (`.spy.yaml`), migrations, and the web server that serves the Flutter web app |
| `brewing_journal_client`  | Generated Serverpod client. Do not edit it by hand; it is rewritten by `serverpod generate`                       |
| `brewing_journal_flutter` | Flutter app (iOS, Android, web, and desktop). State is held in Cubits                                             |


Product and architecture notes are in `docs/hackaton_sep_2026/`.

## Requirements

- Dart SDK `^3.12.2`
- Flutter `^3.44.4`
- [Serverpod CLI](https://docs.serverpod.dev) `4.0.2` (`dart install serverpod_cli@4.0.2`)

Local development and tests use Serverpod's embedded PostgreSQL (`database.dataPath` in the server config). Docker is not required. Redis is disabled in development.

`brewing_journal_server/config/passwords.yaml` is gitignored. Create it before the first start, as described in [Run](#run). The server and `dart test` both refuse to start without it.

## Run

Local development is one terminal session: `serverpod start` generates the client, starts an embedded PostgreSQL, applies pending migrations, starts the server, and launches the Flutter app. Run it from the repository root or from any package directory. The CLI finds `brewing_journal_server` on its own.

### 1. Fetch packages

From the repository root (the Dart workspace):

```bash
dart pub get
```

That resolves `brewing_journal_server`, `brewing_journal_client`, and `brewing_journal_flutter`. Flutter must be on your `PATH` (`flutter --version`). The first launch compiles native assets and can take a minute.

### 2. Create `passwords.yaml`

Create `brewing_journal_server/config/passwords.yaml`. It is listed in `brewing_journal_server/.gitignore`. Each value is a random string used only on your machine. Generate one per key:

```bash
openssl rand -base64 32
```

`serverpod start` loads the `development` block. `dart test` loads the `test` block. Use a different value for every key.

```yaml
development:
  database: 'paste-a-random-string-here'
  redis: 'paste-a-random-string-here'
  serviceSecret: 'paste-a-random-string-here'
  emailSecretHashPepper: 'paste-a-random-string-here'
  jwtHmacSha512PrivateKey: 'paste-a-random-string-here'
  jwtRefreshTokenHashPepper: 'paste-a-random-string-here'

test:
  database: 'paste-a-random-string-here'
  redis: 'paste-a-random-string-here'
  emailSecretHashPepper: 'paste-a-random-string-here'
  jwtHmacSha512PrivateKey: 'paste-a-random-string-here'
  jwtRefreshTokenHashPepper: 'paste-a-random-string-here'
```

Replace every placeholder. `openssl rand -base64 32` is long enough: `serviceSecret` must be longer than 20 characters or Insights stays off, and `jwtRefreshTokenHashPepper` must be at least 10 characters or sign-in throws at startup.

`JwtConfigFromPasswords` reads `jwtHmacSha512PrivateKey` and `jwtRefreshTokenHashPepper`. The email identity provider reads `emailSecretHashPepper`. `database` is the password of the embedded PostgreSQL, which is created with that value on first start. To change it later, delete `brewing_journal_server/.serverpod/development/pgdata` (and `.serverpod/test/pgdata` for tests) before the next start. Development leaves Redis off (`redis.enabled: false` in `config/development.yaml`); keep the `redis` key so the password is already there if you enable it. Add `staging` and `production` blocks when you start the server with `--mode staging` or `--mode production`.

### 3. Start

```bash
serverpod start
```

What that does, in order:

1. Generates `brewing_journal_client` and `brewing_journal_server/lib/src/generated/` from the `.spy.yaml` models and the endpoints.
2. Starts the embedded PostgreSQL for the `development` run mode. Its data lives in `brewing_journal_server/.serverpod/development/pgdata` (gitignored). Removing that directory gives you an empty database on the next start.
3. Applies any pending migrations, then starts the API, Insights, and web servers.
4. Launches the Flutter app declared in `brewing_journal_server/pubspec.yaml` under `serverpod.flutter_apps.brewing_journal`: package `brewing_journal_flutter`, entrypoint `lib/main.dart`, web host `localhost`, web port `8090`. The app is set to `auto_launch: true` and has no `device`, so Flutter's web server starts and the default browser opens at `http://localhost:8090`.

The session is interactive. A tab shows the server log, and another shows the Flutter app. A second `serverpod start` for the same project exits and tells you a session is already running.

To start the server and leave the app for a later `flutter run`, pass `--no-flutter`. You can still launch the configured app from that session with `Ctrl+R`.

### 4. Sign in

Open `http://localhost:8090` if the browser did not. Create an account with an email and password. In development the verification code is printed in the server log (the server tab of the same terminal). Enter that code, then set a preferred name. The session stays signed in across restarts. Staging and production send the code through Serverpod Cloud email.

The debug app talks to the API at `http://localhost:8080`, from `brewing_journal_flutter/assets/config.json`.

### Ports

| Service | URL | Role |
| --- | --- | --- |
| API | `http://localhost:8080` | Endpoints the Flutter client calls |
| Insights | `http://localhost:8081` | Serverpod Insights |
| Web server | `http://localhost:8082` | Built Flutter web app and team invite links |
| Flutter debug app | `http://localhost:8090` | App launched by `serverpod start` |

Web sign-in uses httpOnly cookies. `config/development.yaml` allows those cookies from `http://localhost:8090` and `http://localhost:8082`. When you launch the web app yourself, pass `--web-hostname=localhost --web-port=8090` so the origin matches.

### While the session is running

Saving a file hot reloads the running process:

- Server Dart hot reloads. If the reload fails, the server restarts.
- A model or endpoint change regenerates the client, then hot reloads.
- Flutter Dart hot reloads the running app. A new asset, font, or native plugin relaunches it.
- After you edit anything under `brewing_journal_server/config/`, press `R`. Those files are read at startup.

The letter keys below are lowercase. Press `H` for the full list.

| Key | Action |
| --- | --- |
| `Q` | Stop the server, the Flutter app, and the embedded database |
| `R` | Hot restart. Use this when a change only runs at startup |
| `H` | List every shortcut |
| `M` | Create a migration from the current models and apply it |
| `Shift+M` | Same as `M`, and allow a migration that drops columns or tables |
| `A` | Apply migrations that are already written |
| `Ctrl+R` | Open the panel that launches a configured Flutter app |

If the project does not compile, the session stays open and prints the error. Save a fix and the server boots again, or press `R` to rebuild now.

### Invite links and the built web app

Team invite URLs are `http://localhost:8082/invite/<token>`. The web server on port 8082 serves the release build in `brewing_journal_server/web/app`. That directory is gitignored, so a fresh clone does not have it. Until you build it, `http://localhost:8082` shows a page titled "Flutter web app not built".

Build it from the server package, in another terminal, while `serverpod start` is running or after you quit:

```bash
cd brewing_journal_server
serverpod run flutter_build
```

That runs the `flutter_build` script in the server `pubspec.yaml`: it builds `brewing_journal_flutter` for the web with `--base-href /` and writes the output to `brewing_journal_server/web/app`. Press `R` in the `serverpod start` session afterward so the web server mounts that directory. Then the invite URL opens the app.

You can also paste the URL or the token into the debug app at Teams → Join with invite. The debug app on port 8090 is the one to use while you are changing code. The build on port 8082 is the copy an invite link opens.

### Desktop, simulator, or a phone

Leave `serverpod start` running. In another terminal:

```bash
cd brewing_journal_flutter
flutter devices
flutter run -d macos
```

Replace `macos` with an id from `flutter devices` (`chrome`, an iOS simulator, or an Android emulator). The bundled `assets/config.json` points at `http://localhost:8080`. That address is the API for a desktop app, the iOS simulator, or Chrome on this computer. For Chrome, add `--web-hostname=localhost --web-port=8090`.

On an Android emulator, `localhost` is the emulator. Point the app at the host machine:

```bash
flutter run --dart-define=SERVER_URL=http://10.0.2.2:8080/
```

A phone on the same network uses your computer's LAN address (`ifconfig` on macOS or Linux, `ipconfig` on Windows). The API listens on port 8080, so the phone can reach it there:

```bash
flutter run --dart-define=SERVER_URL=http://<your-computer-ip>:8080/
```

`publicHost` in `config/development.yaml` stays `localhost`. Invite URLs and the built web app keep using that host.

### Server only

```bash
serverpod start --no-flutter
```

`serverpod start -- --mode staging` selects another run mode. The Flutter apps launch in the `development` run mode.

`serverpod start` is the development command: it watches files, regenerates the client, and launches Flutter. To run the server binary on its own, from `brewing_journal_server`:

```bash
dart run bin/main.dart --apply-migrations
```

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

Flutter UI integration tests use `package:integration_test` and live in `integration_test/`. Run them on macOS or a mobile device:

```bash
cd brewing_journal_flutter
flutter test integration_test -d macos
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

## Features



### Accounts

Sign-up and sign-in use email and password. A new account confirms a verification code and sets a preferred name. The session stays signed in across restarts. In development the verification code is printed in the server log.

Flutter draws the sign-in screens and keeps the session with `serverpod_auth_idp_flutter` (`FlutterAuthSessionManager`, and httpOnly cookies on web). Serverpod's email identity provider registers the account, checks the password, and issues JWTs from `JwtConfigFromPasswords`. Verification mail goes out through Serverpod Cloud email. The preferred name is saved by the `userProfileEdit` endpoint.

### Recipes

A five-step wizard creates a recipe or edits one already saved. Saving again keeps the previous version.

1. **Ingredient.** Coffee, tea, or matcha. Search ingredients you already have and ingredients used by recipes on your teams, or register a new one with origin, roaster, roast level, and processing.
2. **Extraction.** Title, water temperature, dose, water volume, grind size, grinder, and method (for example V60, espresso, or French press). The grinder field suggests models from your recipes and from your teams. A stopwatch on this step records the extraction time.
3. **Flavor.** Scores for acidity, sweetness, body, and bitterness, shown on a radar chart, plus free-text flavor tags.
4. **Extra instructions.** An optional ordered list of steps outside the extraction parameters, such as milk, ice, or a stir. Items can be edited, reordered, and removed.
5. **Photos.** Optional pictures of the cup, crema, or packaging. The server checks each upload before it is stored on the recipe.

Flutter runs the wizard, including the radar chart and the stopwatch, and submits the draft through the generated client. Serverpod's `recipe` endpoint stores it, writing a new row on edit so the previous version remains. `ingredient` searches, registers, and copies team ingredients, and `recipe.listGrinderModels` supplies the grinder suggestions. For a photo, `recipeMedia` creates an upload description, Flutter uploads the bytes with `FileUploader`, and `confirmUpload` verifies the file before the path is stored. Local development uses `DatabaseCloudStorage`; a Serverpod Cloud deploy uses its public storage.

### Brew Mode

Opening a saved recipe shows its parameters, extra instructions, and photos so you can brew it again. A timer starts from the saved extraction time and plays an in-app alarm when that time is reached while Brew Mode stays open. A recipe with no recorded time still opens, and the timer stays off.

Flutter loads the recipe and draws the read-only screen. `BrewTimerCubit` counts from the saved duration and plays the alarm while that screen is open. Serverpod's `recipe.get` returns the recipe after `RecipeAccessPolicy` confirms the caller can read it.

### Teams

Create a team and add recipes to it. The owner invites someone with a single-use link that expires, and chooses viewer or editor on that invite.


| Role   | Access                                                                |
| ------ | --------------------------------------------------------------------- |
| Viewer | Read team recipes and see which ones the team has marked as favorites |
| Editor | Read, create, and update team recipes, and mark team favorites        |


Every member can open the member list and see each person's preferred name, email, and role. The owner can switch a member between viewer and editor. That member receives an email naming the team, the new role, and what the role can do.

Ingredients and grinder models on team recipes show up while any member creates a recipe. Choosing a team ingredient copies it onto that member's account.

Flutter lists teams, builds the invite, shows members, and accepts a link at `/invite/<token>`. Serverpod's `team` endpoint creates the team, stores the single-use token, builds the invite URL from the web server config, and writes the `team_membership` row when the link is accepted. `RecipeAccessPolicy` reads that row to allow a viewer to read and an editor to change recipes. The web server's `FlutterRoute` serves the built app at the invite URL. A role change is saved on the server, which then emails the member.

### Favorites

A heart on My recipes, or in Brew Mode opened from that list, saves the recipe to your favorites. A heart on a team, or in Brew Mode opened from that team, saves it to the team's favorites. The two lists stay separate. Each list keeps one favorite per recipe name, ignoring capitalization. Saving a second recipe with the same name asks whether to replace the current favorite. An app-bar heart filters the list to favorites.

Flutter draws the hearts, the replace dialog, and the filter. Serverpod's `recipe` endpoint saves and removes the two lists (`saveFavorite`, `removeFavorite`, `saveTeamFavorite`, `removeTeamFavorite`). A save whose name is already a favorite returns `FavoriteSaveResult` with `saved: false` until Flutter calls again with `replace: true`. `listFavorites` and `listTeamFavorites` supply the filtered lists.

### Share

Anyone who can read a recipe can export a summary card: parameters, flavor map, and extra instructions when the recipe has them. The card ends with "Made with Cata Café". The device share sheet sends that image. On the web, where the browser cannot share a file, the image can be downloaded instead.

Flutter paints the card, captures it as a PNG, and opens the device share sheet with `share_plus`. The recipe on the card is the one Serverpod already returned from `recipe.get`, after `RecipeAccessPolicy` allows that read. The image itself is shared from the app.

## How it was built

I leverage the use of AI for building this project. I made use of Cursor AI IDE.
I started with the general idea of the App and a starting set of features. I manually described the features the best I could, and I asked Cursor to create a PRD document based on that. Then I asked for a system design document based on the features described in the PRD, and after that I asked for a task breakdown document with the list of all the implementation steps required to build each feature. The documents can be found in [docs/hackaton_sep_2026](https://github.com/rperezsolis/brewing_journal/tree/main/docs/hackaton_sep_2026) .

Once I was happy with the documents, I asked for implementation and code review, I manually tested the functionalities, and asked for the creation of automated tests. I did this sequentially, feature by feature, making sure to run the automated tests every time a new implementation was made, and manually testing along the way to identify and fix any defects.

When the MVP was done on my local, I deployed the project to Serverpod Cloud. Once the project was live, I made several rounds of manual tests, found a few bugs, and fixed them. During the process, I identified some functionality gaps and added more functionality than I initially thought, going through the process described above again.

There are still a few things I would like to implement, such as scanning the bags of coffee/matcha/tea to fill in the ingredient step in an easier and faster way, a Terms and Conditions page, among other things, but I decided to keep that out of the scope of this Hackaton period. More features will be coming soon.

Thanks for reading. I encourage you to use my app the next time you make yourself a cappuccino  :D