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

`brewing_journal_server/config/passwords.yaml` is gitignored. It must exist on your machine with the development and test secrets (database, Redis, and the JWT keys read by `JwtConfigFromPasswords`) before the server or the tests will start.

## Run

From the server package, start the server. It also launches the Flutter app (`brewing_journal_flutter`, entrypoint `lib/main.dart`) at `http://localhost:8090`:

```bash
cd brewing_journal_server
serverpod start
```

Press `Q` to shut the server down.


| Service                                             | Port |
| --------------------------------------------------- | ---- |
| API                                                 | 8080 |
| Insights                                            | 8081 |
| Web server (built Flutter web app and invite links) | 8082 |
| Flutter debug app launched by `serverpod start`     | 8090 |


Team invite URLs are `http://localhost:8082/invite/<token>`. The link opens the built web app on the web server. Native App Links and Universal Links are not used.

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