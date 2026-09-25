# BrewSync MVP — Task Breakdown and Execution Plan

**Sources:** `[brewing_journal_mvp_prd.md](./brewing_journal_mvp_prd.md)` (requirements, user stories) and `[brewing_journal_mvp_system_design.md](./brewing_journal_mvp_system_design.md)` (schemas, endpoint contracts, Cubits).

**Packages:** `brewing_journal_server` (Serverpod 4.0.2), `brewing_journal_client` (generated — never edit), `brewing_journal_flutter` (Flutter app).

---

## How to use this plan

Each feature follows the same four phases in this order. Finish a phase before starting the next one in that feature:

1. **Backend Schemas & Database:** `.spy.yaml` models, code generation, migrations.
2. **Backend API Endpoints:** endpoint classes, business logic, server tests.
3. **Flutter UI & State Management:** screens, widgets, and Cubits, backed by fake repositories.
4. **Integration Layer:** real repositories on the generated client, loading states, and error mapping.

Features are ordered so each one depends only on the features before it. The one deviation from the final schema in the system design is that **Feature 2 builds personal recipes only**. `Recipe.team`, `RecipeDraft.teamId`, `RecipeAccess.role`, and the `recipe_team_updated_idx` index are added in **Feature 4**. That migration creates the three team tables and adds one nullable column to `recipe`, so no existing data is lost. When Feature 4 is done, the schema matches the system design exactly.

The one exception to phase isolation is the Feature 1 `requireLogin` test: it needs a domain endpoint, so it is written in Feature 1 and first run after Feature 2's endpoints exist.

### Command reference

The dev loop runs under `serverpod start`, which watches files, regenerates code, and hot reloads the server and the app. Use the `serverpod` MCP tools while it is running. Use the CLI only when the server cannot start at all.


| Action                           | While `serverpod start` is running (MCP) | Fallback (CLI, in `brewing_journal_server/`)                                      |
| -------------------------------- | ---------------------------------------- | --------------------------------------------------------------------------------- |
| Regenerate code                  | automatic on save                        | `serverpod generate`                                                              |
| Create migration                 | `create_migration`                       | `serverpod create-migration --tag <name>` (add `--force` for destructive changes) |
| Apply migrations                 | `apply_migrations`                       | applied automatically on the next `serverpod start`                               |
| Repair drifted DB                | `create_repair_migration`                | `serverpod create-repair-migration`                                               |
| Restart                          | `hot_restart`                            | restart `serverpod start`                                                         |
| Logs                             | `tail_server_logs`, `tail_flutter_logs`  | terminal output                                                                   |
| Build the web app into `web/app` | —                                        | `serverpod run flutter_build` (script in the server `pubspec.yaml`)               |


**Checklist after each phase, in order** (from `AGENTS.md`):

- [ ] `dart analyze` in the changed package(s)
- [ ] `dart format .` in the changed package(s)
- [ ] `create_migration` + `apply_migrations` (MCP), only if a `table` model changed
- [ ] `hot_restart` (MCP) if the Flutter change needs it
- [ ] `dart test` in `brewing_journal_server/` (embedded Postgres from `config/test.yaml`, no Docker) after backend phases
- [ ] `flutter test` in `brewing_journal_flutter/` after Flutter phases
- [ ] `tail_server_logs` and `tail_flutter_logs` (MCP) show no errors



### Folder conventions

```text
brewing_journal_server/lib/src/
├── common/     # session helpers shared by endpoints
├── brewing/    # ingredient, recipe, instruction, tag, photo models + endpoints
└── teams/      # team, membership, invite models + endpoint

brewing_journal_flutter/lib/
├── data/repositories/   # wrap brewing_journal_client; one per endpoint group
├── data/services/       # wrap platform plugins (audio, share sheet)
├── ui/core/             # theme, shared widgets, error-message mapping
├── ui/features/<name>/cubit/
├── ui/features/<name>/view/
├── ui/features/<name>/*.dart   # pure helpers for that feature (limits, encoders, layout)
├── app_scope.dart       # app-level repository and Cubit providers
└── router.dart          # go_router config
```

**Where state lives.** This avoids routes reaching for Cubits they cannot see:

- **Repositories** are registered once in `app_scope.dart` (`MultiRepositoryProvider` above `MaterialApp.router`). Every route's `BlocProvider` reads them with `context.read<...Repository>()`. The Flutter UI phase registers fakes and the Integration phase swaps in the Serverpod implementations in that one file.
- **Session-scoped Cubits** live in `app_scope.dart` too, so any route can refresh them: `AuthCubit` (Feature 1), the personal `RecipeListCubit` (Feature 2), and `TeamsCubit` (Feature 4). The last two call `load()` when `AuthCubit` becomes `authenticated` and `reset()` when it becomes `unauthenticated`, so one account never sees another account's data.
- **Route-scoped Cubits** are created by the route's `BlocProvider` and disposed with it: `RecipeCreationCubit`, `RecipeDetailCubit`, `BrewTimerCubit`, `InviteAcceptCubit`, `ShareCubit`, and the team `RecipeListCubit(teamId)`. A screen that owns one of these and pushes another route reloads on return (`await context.push(...); cubit.load()`).

---



## Feature 0 — Project Foundation (one-time)

This is setup, not a product feature. It is here so the Feature 1 tasks do not mix in dependency installs.

- [ ] Add Flutter dependencies from `brewing_journal_flutter/`:
  - [ ] `flutter pub add flutter_bloc equatable go_router`
  - [ ] `flutter pub add --dev bloc_test mocktail fake_async`
- [ ] Create the folder skeleton above (`data/repositories`, `data/services`, `ui/core`, `ui/features`).
- [ ] Remove the starter example:
  - [ ] Delete `brewing_journal_server/lib/src/greetings/` (`greeting.spy.yaml`, `greeting_endpoint.dart`). It has no `table`, so no migration is needed.
  - [ ] Delete `brewing_journal_server/test/integration/greeting_endpoint_test.dart`.
  - [ ] Delete `brewing_journal_flutter/lib/screens/greetings_screen.dart`, and replace `MyHomePage`'s body in `main.dart` with a placeholder `Text('BrewSync')` so the app still compiles until the Feature 1 router replaces it.
  - [ ] Let code generation run (or `serverpod generate`), then confirm `client.greeting` is gone from `brewing_journal_client`.
- [ ] Rename the app to BrewSync: `MaterialApp.title`, and `appDisplayName: 'BrewSync'` in `ServerpodCloudEmailIdpConfig` (`lib/server.dart`) so verification emails carry the product name.
- [ ] Raise `maxRequestSize` in `config/development.yaml` from `524288` (512 KB) to `10485760` (10 MB). Locally, photos go to `DatabaseCloudStorage` through the API server, and a 2048px JPEG is often larger than 512 KB. `config/test.yaml` needs no change, because server tests write files with `session.storage.storeFile` and never make an HTTP upload. Leave staging and production alone, because Serverpod Cloud storage uploads bypass the API server.
- [ ] Run the post-phase checklist.

---



## Feature 1 — Authentication

**Stories:** US-1.1 sign up, US-1.2 persistent session, US-1.3 failed sign-in stays signed out, US-1.4 bad verification code rejected.

### 1.1 Backend Schemas & Database

The auth tables (`serverpod_auth_idp_email_account`, `serverpod_auth_idp_email_account_request`, `serverpod_auth_core_jwt_refresh_token`, and the rest) are already in migration `20260925162018290`.

- [x] Confirm `migrations/migration_registry.txt` lists `20260925162018290` and that `definition.sql` contains `serverpod_auth_idp_email_account` and `serverpod_auth_core_jwt_refresh_token`.
- [ ] Run `apply_migrations` (MCP) and confirm in `tail_server_logs` that there are no pending migrations.
- [x] Confirm `config/generator.yaml` sets no module nickname, so later models can reference `module:serverpod_auth_core:AuthUser`.
- [x] No new `.spy.yaml` files in this feature.



### 1.2 Backend API Endpoints

- [x] Review `lib/src/auth/email_idp_endpoint.dart` (`EmailIdpEndpoint extends EmailIdpBaseEndpoint`) and `jwt_refresh_endpoint.dart` (`JwtRefreshEndpoint extends RefreshJwtTokensEndpoint`). No changes expected.
- [x] Confirm `pod.initializeAuthServices` in `lib/server.dart` uses `JwtConfigFromPasswords()` and `ServerpodCloudEmailIdpConfig`, and that `config/passwords.yaml` has the JWT secrets for `development` and `test`.
- [x] Create `lib/src/common/session_auth.dart` with an extension on `Session`:
  - [x] `UuidValue get callerId => authenticated!.authUserId;`, used only inside endpoints that set `requireLogin => true`. `authUserId` is an extension from `package:serverpod_auth_idp_server/core.dart`, so import it there.
- [x] Create `lib/src/common/authenticated_endpoint.dart`: `abstract class AuthenticatedEndpoint extends Endpoint { @override bool get requireLogin => true; }`. Every domain endpoint in later features extends it.
- [ ] Development check: register an email through the app and confirm the verification code shows up in `tail_server_logs`.
- [x] Test helper `test/integration/helpers/test_users.dart`. Every domain table has a foreign key to `serverpod_auth_core_user`, so a test user must be a real row:
  - [x] `Future<TestUser> createTestUser(TestSessionBuilder sb)` calls `const AuthUsers().create(sb.build())` (from `package:serverpod_auth_idp_server/core.dart`) and returns the `authUserId` plus `sb.copyWith(authentication: AuthenticationOverride.authenticationInfo(authUser.id.toString(), {}))`.
  - [x] All later server tests get users A, B, and so on from this helper.
- [ ] Server test `test/integration/auth/require_login_test.dart` (`withServerpod`). This test depends on the first `AuthenticatedEndpoint` subclass, so write it now and run it after 2.2: **Deferred to 2.2** (it cannot compile before `endpoints.recipe` exists). `test/integration/auth/test_users_test.dart` covers the helper in the meantime.
  - [ ] An unauthenticated `sessionBuilder` call to `endpoints.recipe.listMine` fails with `ServerpodUnauthenticatedException`.
  - [ ] The same call with a `createTestUser` session builder succeeds and returns `[]`.
- [ ] Run the post-phase checklist. `dart analyze`, `dart format` and `dart test` pass; the MCP log tails are not checked yet.



### 1.3 Flutter UI & State Management

- [x] `lib/data/repositories/auth_repository.dart`: abstract `AuthRepository` with `Stream<bool> authStateChanges`, `bool get isAuthenticated`, `Future<void> restore()`, and `Future<void> signOut()`. Add `FakeAuthRepository` for tests and previews.
- [x] `lib/ui/features/auth/cubit/auth_state.dart`: `enum AuthStatus { unknown, authenticated, unauthenticated }`, and an `AuthState` (Equatable) holding `status`.
- [x] `lib/ui/features/auth/cubit/auth_cubit.dart`: `AuthCubit(AuthRepository)` that subscribes to `authStateChanges` in its constructor, plus `signOut()`. Cancel the subscription in `close()`.
  - [x] `start()` awaits `restore()` and then emits from `isAuthenticated`. The listenable only fires on changes, so without this a restored session would stay `unknown`.
- [x] `lib/ui/features/auth/view/splash_screen.dart`: a spinner shown while `status == unknown`, so a restored session does not flash the sign-in screen (US-1.2).
- [x] `lib/ui/features/auth/view/sign_in_screen.dart`: move the existing `lib/screens/sign_in_screen.dart` here. Keep `SignInWidget(client: ...)`, which already handles the email, verification-code, and password steps. `onError` shows a snackbar with an error message (US-1.3, US-1.4). Remove the `child` wrapper, since routing replaces it.
- [x] `lib/router.dart` (`go_router`):
  - [x] Routes: `/splash`, `/sign-in`, `/` (home placeholder for now).
  - [x] `redirect`, carrying the original location as `from` on every hop:
    - [x] `unknown` goes to `/splash?from=<location>`. Without `from` here, a cold start on `/invite/<token>` (Feature 4) would be lost while the session is being restored.
    - [x] `unauthenticated` goes to `/sign-in?from=<location>` (keeping an existing `from` when coming from `/splash`).
    - [x] `authenticated` on `/splash` or `/sign-in` goes to `from`, or `/` if there is none.
  - [x] `refreshListenable`: a small `ChangeNotifier` adapter (`GoRouterRefreshStream`) that calls `notifyListeners` on each `AuthCubit.stream` event. `go_router` has no stream adapter built in.
  - [x] `GoRouter createRouter(AuthCubit auth)`, so the router and the widget tree share one `AuthCubit` instance.
- [x] `app_scope.dart`: `AppScope` widget with a `MultiRepositoryProvider` (`AuthRepository` for now) and a `MultiBlocProvider` (`BlocProvider.value` of the `AuthCubit`). Later features add their repositories and session-scoped Cubits here.
- [x] `main.dart`: create the `AuthCubit` and call `start()`, build the router with `createRouter(authCubit)`, and run `AppScope(child: MaterialApp.router(...))`. Remove `MyHomePage` and the Feature 0 placeholder.
- [x] `/` home placeholder with a Sign out action that calls `AuthCubit.signOut()`.
- [x] `ui/core/error_messages.dart`: `String errorMessage(Object error, {Map<BrewingErrorCode, String> overrides = const {}})`. It returns `overrides[code]` first, then the shared default for that code, then the connection message (see 1.4). Screens that need different wording for the same code pass `overrides` instead of changing the shared defaults. `BrewingErrorCode` does not exist until Feature 2, so in this feature the function only handles connection errors, and the `overrides` parameter is added in 2.4.
- [x] Cubit tests (`bloc_test`, fake repository): the initial state is `unknown`; `start()` with a restored session emits `authenticated`, and with none emits `unauthenticated`; a stream value of `true` emits `authenticated`; a later `false` emits `unauthenticated`.
- [ ] Run the post-phase checklist, then `hot_restart` (the router change needs it).



### 1.4 Integration Layer

- [x] `ServerpodAuthRepository implements AuthRepository` on the global `client`:
  - [x] `authStateChanges` bridges `client.auth.authInfoListenable` to a stream that emits `client.auth.isAuthenticated`.
  - [x] `restore()` awaits `client.auth.initialize()`. Remove the `unawaited(client.auth.initialize())` call from `initializeClient()` in `client.dart`, so initialization happens once, through `AuthCubit.start()`.
  - [x] `signOut()` calls `client.auth.signOutDevice()`.
- [x] Register `ServerpodAuthRepository` in `app_scope.dart` in place of `FakeAuthRepository`.
- [ ] Manual checks against the dev server:
  - [x] Register a new email, read the code from `tail_server_logs`, finish registration, and land on `/` (US-1.1).
  - [x] Enter a wrong or expired code: registration does not complete and an error is shown (US-1.4).
  - [x] Enter a wrong password or unknown email: the user stays on `/sign-in` with an error (US-1.3).
  - [x] `hot_restart`: the user goes from `/splash` straight to `/` without signing in again (US-1.2).
  - [x] Sign out, and confirm the user goes to `/sign-in` and that protected routes redirect there.
  - [x] Signed out, open `/some/deep/path` directly, sign in, and confirm the user lands on `/some/deep/path` (checks that `from` survives `/splash` and `/sign-in`). The app uses hash URLs, so open `/#/some/deep/path`. The first half is verified: it lands on `/#/sign-in?from=/some/deep/path`; signing in is not checked yet.
- [x] Error handling: in `errorMessage`, map `ServerpodClientNetworkException` (and any other `ServerpodClientException`) to "Can't reach the server". Do not catch `SocketException`: `dart:io` is not available on web.
- [ ] Run the post-phase checklist, and check both log tails.

---



## Feature 2 — 5-Step Recipe Creation (with File Uploads)

**Stories:** US-2.1 through US-2.12. Personal recipes only; team fields come in Feature 4.

### 2.1 Backend Schemas & Database

Every table model declares `id: UuidValue?, defaultPersist=random_v7`.

- [ ] **Enums** (`serialized: byName`):
  - [ ] `lib/src/brewing/beverage_kind.spy.yaml`: `coffee, tea, matcha`
  - [ ] `lib/src/brewing/roast_level.spy.yaml`: `light, medium, mediumDark, dark`
  - [ ] `lib/src/brewing/extraction_method.spy.yaml`: `v60, espresso, frenchPress, aeropress, chemex, coldBrew, matchaWhisk, other`
  - [ ] `lib/src/brewing/brewing_error_code.spy.yaml`: `notFound, forbidden, validation, inviteExpired, inviteUsed, alreadyMember, uploadRejected` (all codes now, so the enum does not churn in Feature 4)
- [ ] **Exception**: `lib/src/brewing/brewing_exception.spy.yaml` with `code: BrewingErrorCode` and `message: String`.
- [ ] **Table** `ingredient` (`ingredient.spy.yaml`):
  - [ ] Fields: `owner: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)`, `kind`, `name`, `nameKey`, `origin?`, `roaster?`, `roastLevel?`, `processing?`, `createdAt: DateTime, default=now`.
  - [ ] Index `ingredient_owner_kind_name_idx` on `ownerId, kind, nameKey`.
- [ ] **Table** `recipe` (`recipe.spy.yaml`), without `team`:
  - [ ] `owner` (Cascade), `ingredient: Ingredient?, relation(onDelete=NoAction)`.
  - [ ] `title`, `waterTempC: double`, `doseGrams: double`, `grindSize`, `grinderModel`, `extractionMethod`, `extractionMethodNote: String?`, `extractionDuration: Duration?`.
  - [ ] `acidity`, `sweetness`, `body`, `bitterness: int`.
  - [ ] `createdAt` and `updatedAt`, both `default=now`.
  - [ ] Child lists: `instructions` (`recipe_instructions`), `photos` (`recipe_photos`), `flavorTags` (`recipe_flavor_tags`).
  - [ ] Indexes `recipe_owner_updated_idx` (`ownerId, updatedAt`) and `recipe_ingredient_idx` (`ingredientId`).
- [ ] **Table** `recipe_instruction`: `recipe` (Cascade, `recipe_instructions`), `sortOrder: int`, `text: String`. Unique index `recipe_instruction_order_idx` on `recipeId, sortOrder`.
- [ ] **Table** `recipe_flavor_tag`: `recipe` (Cascade, `recipe_flavor_tags`), `tag`, `tagKey`. Unique `recipe_flavor_tag_recipe_idx` (`recipeId, tagKey`), plus `recipe_flavor_tag_key_idx` (`tagKey`).
- [ ] **Table** `recipe_photo`: `recipe` (Cascade, `recipe_photos`), `storagePath`, `sortOrder`, `createdAt`, `publicUrl: Uri?, !persist`. Unique `recipe_photo_order_idx` (`recipeId, sortOrder`) and unique `recipe_photo_path_idx` (`storagePath`).
- [ ] **DTOs** (no `table`):
  - [ ] `ingredient_draft.spy.yaml`: `kind`, `name`, `origin?`, `roaster?`, `roastLevel?`, `processing?`
  - [ ] `recipe_draft.spy.yaml`: every field in the system design except `teamId`: `id?`, `ingredientId`, the parameters, the scores, `flavorTags: List<String>`, `instructions: List<String>`
  - [ ] `recipe_access.spy.yaml`: `canEdit: bool`, `canDelete: bool` (`role` comes in Feature 4)
  - [ ] `recipe_detail.spy.yaml`: `recipe`, `ingredient`, `instructions`, `flavorTags`, `photos`, `access`
  - [ ] `upload_ticket.spy.yaml`: `path`, `description`
- [ ] Generate: save and watch `serverpod start` output, or run `serverpod generate`. Fix any YAML errors before continuing.
- [ ] Confirm the generated `Recipe.ownerId`, `Recipe.ingredientId`, and `RecipeInstruction.recipeId` are `UuidValue`.
- [ ] `create_migration` (MCP), or CLI `serverpod create-migration --tag recipes`.
- [ ] Review the new `migration.sql`: 5 `CREATE TABLE` statements, foreign keys to `serverpod_auth_core_user` with `ON DELETE CASCADE`, `recipe.ingredientId` with `NO ACTION`, and all 8 indexes.
- [ ] `apply_migrations` (MCP), then `tail_server_logs` to confirm it applied.



### 2.2 Backend API Endpoints

- [ ] `lib/src/brewing/recipe_limits.dart` with constants shared by the endpoints and tests: `kInstructionMaxLength = 280`, `kMaxInstructions = 30`, `kMaxTags = 12`, `kTagMaxLength = 40`, `kTitleMaxLength = 120`, `kGrindMaxLength = 80`, `kMaxPhotos = 6`.
- [ ] `lib/src/brewing/recipe_validator.dart`: pure functions that throw `BrewingException(code: validation, message: '<field>: ...')`:
  - [ ] title 1..120, grind size and grinder model 1..80 (after trim)
  - [ ] `waterTempC` 1..100, `doseGrams` 0.1..500, `extractionDuration` null or 1s..2h
  - [ ] each score 0..5
  - [ ] `extractionMethod == other` requires a non-empty `extractionMethodNote`
  - [ ] tags 1..40 after trim, at most 12; de-duplicate by `tagKey`
  - [ ] instructions: trim each, reject blank or > 280, at most 30, keep duplicates and order (US-2.7, US-2.8, US-2.11)
- [ ] `lib/src/brewing/recipe_access_policy.dart`: `RecipeAccessPolicy.resolve(session, recipe)`. For now, the owner gets `canEdit/canDelete = true` and anyone else gets `notFound`. Feature 4 adds the team branch.
- [ ] `lib/src/brewing/ingredient_endpoint.dart`: `IngredientEndpoint extends AuthenticatedEndpoint`:
  - [ ] `search(kind, query, limit)`: clamp `limit` to 1..30, filter `ownerId == callerId`, `kind`, `nameKey.like('${key}%')`, order by `nameKey`
  - [ ] `register(IngredientDraft)`: trim the name (1..120), compute `nameKey`, return the existing row on `(owner, kind, nameKey)`, otherwise insert
- [ ] `lib/src/brewing/recipe_endpoint.dart`: `RecipeEndpoint extends AuthenticatedEndpoint`:
  - [ ] `save(RecipeDraft)` inside `session.db.transaction`, following steps 1–6 of the system design: load and resolve access on update, check the ingredient, validate, insert or update (refresh `updatedAt`), delete and re-insert `recipe_instruction` (`sortOrder = index`) and `recipe_flavor_tag`, then return `get`
  - [ ] `get(id)`: one query with `include` for ingredient, instructions (`orderBy sortOrder`), tags, and photos (`orderBy sortOrder`); fill `photos[].publicUrl` with `session.storage.publicDownloadUrl(storageId: 'public', path: ...)` and fill `access`
  - [ ] `listMine(limit, offset)`: clamp to 1..50, `ownerId == callerId`, `orderBy updatedAt desc`
  - [ ] `getAccess(id)`
  - [ ] `delete(id)`: requires `canDelete`; reads the photo `storagePath`s first, deletes the row (children cascade), then calls `session.storage.deleteFile(storageId: 'public', path: ...)` for each path after commit, logging failures instead of throwing
- [ ] `lib/src/brewing/recipe_media_endpoint.dart`: `RecipeMediaEndpoint extends AuthenticatedEndpoint`:
  - [ ] `createUploadDescription(recipeId)`: requires `canEdit`, at most 6 photos, path `recipes/<recipeId>/<Uuid().v4()>.jpg`, returns `UploadTicket(path: path, description: await session.storage.createUploadDescription(storageId: 'public', path: path))`
  - [ ] `confirmUpload(recipeId, path)`: requires `canEdit`; the path must match `^recipes/<recipeId>/[0-9a-f-]{36}\.jpg$`; return the existing row if one exists; `session.storage.verifyUpload(storageId: 'public', path: path)` false gives `uploadRejected` (US-2.12); insert with `sortOrder = max + 1` in a transaction and retry once on a unique conflict
  - [ ] `remove(photoId)`: requires `canEdit` on the parent recipe, deletes the row, then deletes the storage object best-effort
- [ ] Server tests in `test/integration/brewing/` (`withServerpod`, users A and B from `createTestUser`):
  - [ ] `ingredient_endpoint_test.dart`: prefix search is case-insensitive; `register` with the same name in different case returns the same id; an empty name gives `validation`; user B cannot see user A's ingredients
  - [ ] `recipe_save_test.dart`:
    - [ ] insert, then update; the update refreshes `updatedAt` and keeps `createdAt`
    - [ ] instructions `['  stir ', 'stir']` are saved as `['stir', 'stir']` in order (US-2.7, US-2.8)
    - [ ] `'use 150ml of whole milk'` round-trips unchanged (US-2.10)
    - [ ] `''` or `'   '` gives `validation`; 281 characters gives `validation`; exactly 280 is accepted; 31 items gives `validation`
    - [ ] saving `instructions: []` removes every row (US-2.4)
    - [ ] tags `['Fruity', ' fruity ']` are stored once; a 41-character tag gives `validation`
    - [ ] saving with user B's `ingredientId` gives `notFound`
  - [ ] `recipe_get_test.dart`: instructions come back in `sortOrder`; user B calling `get` gives `notFound`; `access` is `canEdit/canDelete = true` for the owner
  - [ ] `recipe_list_test.dart`: `listMine` is newest `updatedAt` first, pages with `limit`/`offset`, and never includes user B's recipes
  - [ ] `recipe_validation_test.dart`: one case per boundary (temp 0/101, dose 0/501, duration 0s/2h1s, score -1/6, `other` with no note, 13 tags, title of 121 characters)
  - [ ] `recipe_media_test.dart`:
    - [ ] happy path: `createUploadDescription`, then `session.storage.storeFile(storageId: 'public', path: ticket.path, byteData: ...)`, then `confirmUpload` returns a row with a `publicUrl`; a second `confirmUpload` with the same path returns the same row
    - [ ] a forged path gives `validation`; confirming without an upload gives `uploadRejected` and no row; the 7th upload description gives `validation`; `remove` by user B gives `notFound`
  - [ ] `recipe_delete_test.dart`: owner delete cascades to instructions, tags, and photos; user B calling `delete` gives `notFound`
- [ ] Run the post-phase checklist, then `dart test` in `brewing_journal_server/`.



### 2.3 Flutter UI & State Management

- [ ] Dependencies: `flutter pub add image_picker image`.
- [ ] iOS: add `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription` to `ios/Runner/Info.plist`, or the picker crashes. Android's photo picker needs no permission.
- [ ] Abstract repositories in `lib/data/repositories/`, plus in-memory fakes:
  - [ ] `IngredientRepository`: `search`, `register`
  - [ ] `RecipeRepository`: `save`, `get`, `listMine`, `getAccess`, `delete`
  - [ ] `RecipeMediaRepository`: `uploadPhoto(recipeId, ByteData)` returning `RecipePhoto`, and `remove(photoId)`
- [ ] Mirror the server limits in `lib/ui/features/recipe_creation/recipe_limits.dart` (`kInstructionMaxLength = 280`, and so on).
- [ ] `RecipeCreationState` (Equatable), with every field from the system design except `teamId` (Feature 4). Include `enum RecipeWizardStep` and `enum SaveStatus`.
- [ ] `RecipeCreationCubit`:
  - [ ] `startNew()`, `load(id)`
  - [ ] `searchIngredients`, with a 250ms debounce in the view; `selectIngredient`, `registerIngredient`
  - [ ] `setExtraction(...)`, `setExtractionDuration(Duration?)`
  - [ ] `startStopwatch` / `stopStopwatch` / `resetStopwatch`: a `Stopwatch` plus a 100ms `Timer.periodic`; cancel it in `close()`
  - [ ] `setFlavor({scores, tags})`
  - [ ] `addInstruction` / `updateInstruction` / `removeInstruction` / `moveInstruction`: trim, reject blank or > 280 without changing the list, cap at 30, allow duplicates
  - [ ] `skipInstructions()`, `next()` / `back()` with the per-step guards (`next` from extraction stops a running stopwatch)
  - [ ] `save()`; `addPhoto(ByteData)`, which calls `save()` first when `recipeId == null`; `removePhoto(id)`
- [ ] Views in `lib/ui/features/recipe_creation/view/`:
  - [ ] `recipe_wizard_screen.dart`: `BlocProvider` at the route, a step indicator (1–5), Back/Next buttons, and a `BlocListener` for `error`, which shows a snackbar
  - [ ] `step_ingredient.dart`: kind selector (`SegmentedButton<BeverageKind>`), search field, result list, and a "Register new" bottom sheet form (origin, roaster, roast level, processing)
  - [ ] `step_extraction.dart`: title, temperature, dose, grind size, grinder model (US-2.1), method dropdown plus a note field when `other`; stopwatch card with Start/Stop/Reset and a live `mm:ss.t` readout (US-2.2); a manual duration field
  - [ ] `step_flavor.dart`: 4 sliders (0..5) plus a live `FlavorRadarChart` (`CustomPainter` in `ui/core/widgets/flavor_radar_chart.dart`, reused by Feature 5) and a tag chip input (US-2.3)
  - [ ] `step_instructions.dart`: a `ReorderableListView` of editable rows, an add field with a `maxLength: 280` counter, delete per row, and a Skip button (US-2.4, US-2.5)
  - [ ] `step_media.dart`: photo grid, add via `ImagePicker().pickImage(maxWidth: 2048, maxHeight: 2048, imageQuality: 85)`, a progress overlay while `pendingUpload`, delete per photo, and a Finish button that works with 0 photos (US-2.6). Finish calls `save()` and returns to the list. The Add button is hidden once there are 6 photos.
  - [ ] `lib/ui/features/recipe_creation/photo_encoder.dart`: turns the picked `XFile` into JPEG `ByteData`. If `mimeType` is not `image/jpeg` (web keeps PNG input as PNG), decode and re-encode with `package:image` (`encodeJpg(quality: 85)`), so the bytes match the server's `.jpg` path.
- [ ] Register the three fake repositories in `app_scope.dart`.
- [ ] `lib/ui/features/recipe_list/`: `RecipeListCubit({UuidValue? teamId})` with `load()`, `loadMore()`, and `reset()`, calling `listMine` for now. Feature 4 adds the `teamId` branch.
  - [ ] Add the personal instance (no `teamId`) to `app_scope.dart` as a session-scoped Cubit that loads on `authenticated` and resets on `unauthenticated`.
  - [ ] `RecipeListScreen` is the new `/` home and replaces the Feature 1 placeholder. Its app bar keeps the Sign out action, and a FAB goes to `/recipes/new`.
  - [ ] An empty state ("No recipes yet") when the list is empty.
- [ ] Routes: `/recipes/new` and `/recipes/:id/edit`. Declare `/recipes/new` before any `/recipes/:id` route, so `new` is not read as an id. Until Brew Mode exists (Feature 3), tapping a list item opens `/recipes/:id/edit`.
- [ ] Cubit tests (`bloc_test` with fakes):
  - [ ] instruction add, edit, move, and remove, including removing the last item, which leaves `[]`
  - [ ] blank or 281-character input sets `error` and leaves the list unchanged
  - [ ] `next()` guards on each step
  - [ ] the stopwatch writes `extractionDuration` on stop and clears it on reset
  - [ ] `load` restores the instructions in order (US-2.9)
  - [ ] `addPhoto` with no `recipeId` calls `save` first; an `uploadRejected` failure leaves `photos` unchanged
  - [ ] `skipInstructions()` clears the list and advances to the media step
  - [ ] a failed `save` keeps every field and sets `saveStatus = failure`
  - [ ] `RecipeListCubit`: `loadMore` appends the next page; `reset` empties the list (sign-out)
- [ ] Widget test: `step_instructions` reorders two rows by drag.
- [ ] Run the post-phase checklist, then `hot_restart`.



### 2.4 Integration Layer

- [ ] Serverpod-backed implementations:
  - [ ] `ServerpodIngredientRepository` on `client.ingredient`
  - [ ] `ServerpodRecipeRepository` on `client.recipe`
  - [ ] `ServerpodRecipeMediaRepository`: `client.recipeMedia.createUploadDescription`, then `FileUploader(ticket.description).uploadByteData(bytes)`, then `client.recipeMedia.confirmUpload(recipeId, ticket.path)`. If the upload returns false, throw a local `uploadRejected` without calling confirm. A `FileUploader` can upload only once, so create a new one for each attempt.
- [ ] Register these in `app_scope.dart` in place of the fakes. Route `BlocProvider`s already read them with `context.read`, so no route changes.
- [ ] Loading states:
  - [ ] `saveStatus == saving` disables Next/Finish and shows a progress indicator on the button
  - [ ] ingredient search shows a small inline spinner
  - [ ] `pendingUpload` shows an overlay on the new photo tile
- [ ] Error handling: add `BrewingException` support and the `overrides` parameter to `errorMessage` in `ui/core/error_messages.dart`. Shared defaults:
  - [ ] `validation`: show `message`, which names the field
  - [ ] `notFound`: "Recipe not found"; the wizard then goes back to the list
  - [ ] `forbidden`: "You can't edit this recipe"
  - [ ] `uploadRejected`: "Photo could not be verified — try again or skip" (US-2.12)
  - [ ] The invite codes (`inviteExpired`, `inviteUsed`, `alreadyMember`) get their defaults in Feature 4.
  - [ ] Every failure keeps the wizard input unchanged.
- [ ] After `save` succeeds, call `context.read<RecipeListCubit>().load()` (the session-scoped instance) so the home list is current when the wizard closes.
- [ ] End-to-end check (`get_flutter_app_dtd` → `connect_dart_tooling_daemon` → `flutter_driver`). Set `enableTextEntryEmulation: true` in `lib/driver.dart` and `hot_restart`. Leave it on for the Feature 3–5 checks; the wrap-up turns it off.
  - [ ] Create a V60 recipe with a stopwatch time, 3 flavor tags, and 3 instructions including a duplicate; skip photos; the recipe shows up on the list.
  - [ ] Edit it: the instructions load in order; reorder and remove all of them; save; reopen and confirm there are none.
  - [ ] Add a photo larger than 512 KB, confirm it renders from `publicUrl`, then remove it. This checks the `maxRequestSize` change from Feature 0.
  - [ ] On Flutter web, confirm photos load. The dev app is on a different origin from the API server (`:8080`), and `Image.network` fetches need CORS there. If the browser console shows a CORS error, pass `webHtmlElementStrategy: WebHtmlElementStrategy.fallback` to `Image.network`.
- [ ] Run the post-phase checklist, and check both log tails.

---



## Feature 3 — Recipe Replay & Timer (Brew Mode)

**Stories:** US-3.1 through US-3.6. The timer and alarm run only in Flutter. The server already stores `extractionDuration` (Feature 2).

### 3.1 Backend Schemas & Database

- [ ] No schema changes. Confirm `recipe.extractionDuration` (`Duration?`) exists in `definition.sql` as a nullable `bigint`.
- [ ] No migration needed. Run `create_migration` (MCP) once and confirm it reports no changes.



### 3.2 Backend API Endpoints

- [ ] No new endpoints. Brew Mode reads `client.recipe.get` from Feature 2.
- [ ] Add server tests to `recipe_get_test.dart` covering the Brew Mode contracts:
  - [ ] A recipe saved with `extractionDuration: null` returns `null`, not zero (US-3.4).
  - [ ] A recipe with no instructions returns `instructions: []` (US-3.2).
  - [ ] A recipe with no photos returns `photos: []` (US-3.6).
  - [ ] Every photo has a non-null `publicUrl`.
- [ ] Run `dart test`.



### 3.3 Flutter UI & State Management

- [ ] Dependencies: `flutter pub add audioplayers`. Add `assets/sounds/brew_alarm.mp3` and list it under `flutter: assets:` in `pubspec.yaml`, next to the existing `assets/config.json` entry (do not replace it: the app reads its server URL from that file).
- [ ] `lib/data/services/alarm_player.dart`: abstract `AlarmPlayer` with `prepare()`, `play()`, and `stop()`; `AudioAlarmPlayer` on `audioplayers` (`AssetSource`, loop until `stop`); `FakeAlarmPlayer` that counts calls. Register the fake in `app_scope.dart`.
- [ ] `lib/ui/features/recipe_detail/cubit/`: `RecipeDetailCubit(RecipeRepository)` with `load(id)`, `delete()` (only when `access.canDelete`), and a status of `initial/loading/success/failure`.
- [ ] `lib/ui/features/brew_mode/cubit/`:
  - [ ] `BrewTimerState` with `mode`, `phase`, `target`, `elapsed`, `remaining`
  - [ ] `BrewTimerCubit(AlarmPlayer)`: `configure(Duration?)`, `setMode`, `start`, `pause`, `resume`, `stop`, `tick`
  - [ ] `tick` reads `stopwatch.elapsed`; at `elapsed >= target` it sets `phase = finished`, cancels the ticker, and calls `AlarmPlayer.play()` exactly once
  - [ ] `close()` cancels the ticker and calls `AlarmPlayer.stop()` (US-3.5)
- [ ] `lib/ui/features/brew_mode/view/brew_mode_screen.dart`:
  - [ ] `MultiBlocProvider` (`RecipeDetailCubit`, `BrewTimerCubit`); on detail success, call `configure(recipe.extractionDuration)`
  - [ ] Parameter block: ingredient, method, dose, temperature, grind, grinder, and a small `FlavorRadarChart` (US-3.1)
  - [ ] "Prep & extra steps" numbered list in `sortOrder`, left out entirely when empty (US-3.2)
  - [ ] Photo carousel from `publicUrl`, left out when empty; `errorBuilder` shows a neutral tile, never a broken-image icon (US-3.6)
  - [ ] Timer panel: large readout, a Count down / Count up toggle (only while idle), and Start/Pause/Resume/Stop. When `target == null`, hide the whole panel and show "No extraction time recorded" (US-3.4)
  - [ ] Finished state: a highlighted readout and a "Stop alarm" button (US-3.3)
  - [ ] `AppLifecycleListener(onHide: ...)`: call `pause()` while running, and `stop()` when `phase == finished`, so a ringing alarm does not keep playing in the background (US-3.5). The system design only calls `pause()` here; `stop()` closes the gap for an alarm that is already ringing.
  - [ ] `WakelockPlus` is optional; skip it for the MVP
  - [ ] App-bar actions: Edit (when `access.canEdit`), Share (Feature 5 placeholder), Delete (when `access.canDelete`, with a confirm dialog)
- [ ] Routes: `/recipes/:id` goes to Brew Mode. Tapping a recipe on the list now opens Brew Mode instead of the editor, and the Edit action pushes `/recipes/:id/edit`.
  - [ ] Declare the recipe routes as sub-routes of `/` (`recipes/new`, `recipes/:id`, `recipes/:id/edit`, and later `recipes/:id/share`), so a deep link opens on top of the home list and Back works.
  - [ ] Wizard Finish: for a new recipe, `context.pushReplacement('/recipes/$id')`; when editing, `context.pop()`. Brew Mode awaits its Edit push and calls `RecipeDetailCubit.load()` on return, so the edited values show without two Brew Mode pages on the stack.
- [ ] Cubit tests using `fake_async`:
  - [ ] `configure(null)` gives `mode idle`, `start()` does nothing, and the alarm is never prepared or played
  - [ ] `start()` with a target calls `prepare()` once
  - [ ] count-down to 3s: the alarm plays once at 3s, `remaining` is clamped at zero, and further ticks do not replay it
  - [ ] count-up to 3s also alarms at 3s
  - [ ] `pause` freezes `elapsed`; `resume` continues from it
  - [ ] `stop` resets to `idle` with `elapsed = 0` and `remaining = target`, and stops the alarm
  - [ ] `setMode` works only while `phase == idle` and does nothing while running
  - [ ] closing the cubit mid-run calls `stop()`, and advancing time afterwards never calls `play()`
- [ ] Widget tests: the instructions section is absent for `[]`, the photos section is absent for `[]`, and the timer panel is absent for a null target.
- [ ] Run the post-phase checklist, then `hot_restart` (new asset).



### 3.4 Integration Layer

- [ ] Register `AudioAlarmPlayer` in `app_scope.dart` in place of the fake. `RecipeDetailCubit` already gets `ServerpodRecipeRepository` from Feature 2's registration.
- [ ] Loading: a full-screen spinner while `RecipeDetailCubit` is loading; pull-to-refresh calls `load` again.
- [ ] Errors: `errorMessage(e, overrides: {notFound: 'Recipe not found or no longer shared with you'})` with a Back button; a connection error shows the shared message with Retry.
- [ ] Web: the first sound must come from a user gesture. `BrewTimerCubit.start()` calls `AlarmPlayer.prepare()` (`setSource` only) before starting the ticker. Because `start()` runs inside the Start button's tap, the later alarm is allowed to play.
- [ ] After `delete()` succeeds, call `context.read<RecipeListCubit>().load()` and pop to the list.
- [ ] End-to-end check (`flutter_driver`):
  - [ ] Open a recipe with a 5s duration, start the count-down, and confirm the finished state after 5s (check `tail_flutter_logs` for audio errors).
  - [ ] Open a recipe with no duration: there are no timer controls and parameters still render.
  - [ ] Start a timer, navigate back before it finishes, wait past the target, and confirm there is no sound or log output.
- [ ] Run the post-phase checklist, and check both log tails.

---



## Feature 4 — Collaborative Teams & RBAC

**Stories:** US-4.1 through US-4.6. Roles are rows in `team_membership`, checked inside endpoint methods. Serverpod scopes are not used.

### 4.1 Backend Schemas & Database

- [ ] **Enum** `lib/src/teams/team_role.spy.yaml`: `viewer, editor` (`serialized: byName`).
- [ ] **Table** `team` (`team.spy.yaml`): `owner` (Cascade), `name`, `createdAt`, `memberships` (`team_memberships`), `invites` (`team_invites`), `recipes` (`team_recipes`). Index `team_owner_idx` on `ownerId`.
- [ ] **Table** `team_membership`: `team` (Cascade, `team_memberships`), `member: module:serverpod_auth_core:AuthUser?` (Cascade), `role: TeamRole`, `createdAt`. Unique `team_membership_team_member_idx` (`teamId, memberId`), plus `team_membership_member_idx` (`memberId`).
- [ ] **Table** `team_invite`: `team` (Cascade, `team_invites`), `createdBy` (Cascade), `token`, `role`, `expiresAt`, `usedAt?`, `usedBy` (`optional, onDelete=SetNull`), `createdAt`. Unique `team_invite_token_idx` (`token`), plus `team_invite_team_idx` (`teamId, expiresAt`).
- [ ] **Extend** `recipe.spy.yaml`: add `team: Team?, relation(name=team_recipes, optional, onDelete=SetNull)` and the index `recipe_team_updated_idx` (`teamId, updatedAt`).
- [ ] **Extend DTOs**:
  - [ ] `recipe_draft.spy.yaml`: add `teamId: UuidValue?`
  - [ ] `recipe_access.spy.yaml`: add `role: TeamRole?`
- [ ] **New DTOs**: `invite_link.spy.yaml` (`token`, `role`, `expiresAt`, `url`) and `team_summary.spy.yaml` (`team`, `role`).
- [ ] Generate (automatic, or `serverpod generate`). Fix any call sites that no longer compile because `RecipeAccess` now has `role` (server and Flutter fakes).
- [ ] `create_migration` (MCP), or CLI `serverpod create-migration --tag teams`.
- [ ] Review `migration.sql`: 3 `CREATE TABLE` statements; `ALTER TABLE recipe ADD COLUMN "teamId" uuid` (nullable, no data loss), a foreign key with `ON DELETE SET NULL`, and the new index. It should need no `--force` and no hand edit.
- [ ] Diff the migration's `definition.sql` against the system design section 1: every table and index should match.
- [ ] `apply_migrations` (MCP), then `tail_server_logs`.



### 4.2 Backend API Endpoints

- [ ] `lib/src/teams/team_membership_lookup.dart`: `Future<TeamMembership?> membershipOf(session, teamId, memberId)` using the unique index.
- [ ] Extend `RecipeAccessPolicy.resolve` to match the authorization table:
  - [ ] owner: `canEdit = canDelete = true`, and `role` is the owner's membership role if the recipe is in a team
  - [ ] team editor who is not the owner: `canEdit = true`, `canDelete = false`
  - [ ] team viewer: `canEdit = false`, `canDelete = false`
  - [ ] a personal recipe of someone else, or a non-member: `notFound`
- [ ] Extend `RecipeEndpoint.save`:
  - [ ] on insert with `teamId`, the caller must be an editor of that team, else `forbidden`
  - [ ] on update, ignore `draft.teamId` and keep the stored `teamId`
  - [ ] step 2: on update, the ingredient may equal the recipe's current `ingredientId` even if another member owns it
  - [ ] a viewer calling `save` gets `forbidden` (US-4.4)
- [ ] Add to `RecipeEndpoint`:
  - [ ] `listForTeam(teamId, limit, offset)`: requires membership, else `notFound`; `orderBy updatedAt desc`
  - [ ] `assignToTeam(recipeId, teamId)`: the caller must own the recipe and be an editor of `teamId`; sets `teamId` and `updatedAt`
  - [ ] `removeFromTeam(recipeId)`: the caller must own the recipe or be an editor of its current team; sets `teamId = null`
- [ ] `RecipeMediaEndpoint`: no code change. It already uses `RecipeAccessPolicy`, so team editors can upload and viewers get `forbidden`.
- [ ] `lib/src/teams/invite_token.dart`: 32 bytes from `Random.secure()`, `base64Url.encode(...).replaceAll('=', '')`.
- [ ] `lib/src/teams/web_base_url.dart`: build `publicScheme://publicHost:publicPort` from `session.serverpod.config.webServer`, leaving out the default port (80/443). `webServer` is nullable; if it is missing, throw a `StateError` rather than issuing a broken link.
- [ ] `lib/src/teams/team_endpoint.dart`: `TeamEndpoint extends AuthenticatedEndpoint`:
  - [ ] `create(name)`: trim, 1..80; one transaction inserts the `team` and the creator's `editor` membership (US-4.1)
  - [ ] `listMine()`: memberships for `memberId == callerId`, `include: team`, mapped to `TeamSummary`
  - [ ] `createInvite(teamId, role, ttl)`: a non-member gets `notFound`, a member who is not the owner gets `forbidden`; clamp `ttl` to 15min..7d; insert a `team_invite`; return an `InviteLink` with `url = '$webBaseUrl/invite/$token'` (US-4.2, US-4.3)
  - [ ] `acceptInvite(token)`:
    - [ ] look up by token, unknown gives `notFound`
    - [ ] caller is already a member: `alreadyMember`, and the invite stays unused
    - [ ] in a transaction: `session.db.unsafeExecute('UPDATE team_invite SET "usedAt" = @now, "usedById" = @caller WHERE token = @token AND "usedAt" IS NULL AND "expiresAt" > @now', parameters: QueryParameters.named({...}), transaction: tx)`. Pass `now` as `DateTime.now().toUtc()`, not SQL `now()`: Serverpod stores `DateTime` as UTC `timestamp without time zone`, so SQL `now()` would compare in the database's time zone. The call returns the affected row count.
    - [ ] 1 row updated: insert a `team_membership` with the invite's role, return `TeamSummary`
    - [ ] 0 rows: re-read, then throw `inviteUsed` if `usedAt != null`, else `inviteExpired`; write nothing (US-4.5)
- [ ] Server tests in `test/integration/teams/` (users Owner, Editor, Viewer, Stranger):
  - [ ] `team_endpoint_test.dart`: `create` inserts an editor membership for the creator; `listMine` returns only the caller's teams; an editor calling `createInvite` gets `forbidden`; a stranger gets `notFound`; `ttl` is clamped
  - [ ] `accept_invite_test.dart`: success creates the membership with the right role; a second accept of the same token by another user gets `inviteUsed`; an expired token (seeded `expiresAt` in the past) gets `inviteExpired` with no membership; an existing editor opening a viewer link gets `alreadyMember`, keeps the editor role, and the token stays usable
  - [ ] `accept_invite_race_test.dart`: two `Future.wait` accepts on one token produce exactly one membership
  - [ ] `team_recipe_access_test.dart`: an editor can `get` and `save` a team recipe (instructions replaced in full); a viewer can `get` but `save` gives `forbidden` and `createUploadDescription` gives `forbidden`; an editor calling `delete` gets `forbidden`; a stranger calling `get` gets `notFound`
  - [ ] `last_writer_wins_test.dart`: the editor saves `['a','b']`, the owner saves `['c']`, and `get` returns exactly `['c']` (US-4.6)
  - [ ] `team_delete_test.dart`: deleting the team row sets `recipe.teamId` to null and the owner still reads the recipe
  - [ ] `team_assignment_test.dart`:
    - [ ] the owner, as an editor of the team, can `assignToTeam`; a viewer-member owner gets `forbidden`; a non-owner gets `notFound`
    - [ ] `removeFromTeam` works for the owner and for a team editor; a viewer gets `forbidden`
    - [ ] `listForTeam` by a non-member gives `notFound`
    - [ ] `save` on insert with a `teamId` where the caller is a viewer gives `forbidden`
    - [ ] an editor's update that sends a different `teamId` leaves the stored `teamId` unchanged
    - [ ] a viewer calling `recipeMedia.remove` gets `forbidden`
- [ ] Run the post-phase checklist, then `dart test`.



### 4.3 Flutter UI & State Management

- [ ] `TeamRepository` (abstract plus fake): `create`, `listMine`, `createInvite`, `acceptInvite`. Extend `RecipeRepository` with `listForTeam`, `assignToTeam`, `removeFromTeam`.
- [ ] Register the fake `TeamRepository` in `app_scope.dart`.
- [ ] `lib/ui/features/teams/cubit/`: `TeamsCubit` with `load()`, `reset()`, `create(name)`, `createInvite(teamId, role, ttl)`, and state `teams`, `status`, `lastInvite`, `error`. Add it to `app_scope.dart` as a session-scoped Cubit (loads on `authenticated`, resets on `unauthenticated`), so the teams list, team detail, invite screen, and Brew Mode's "Add to team" picker share one list.
- [ ] `lib/ui/features/invite/cubit/`: `InviteAcceptCubit` with `accept(token)` and state `status` (`accepting/success/failure`), `team`, `errorCode`.
- [ ] Extend `RecipeCreationCubit`:
  - [ ] `startNew({UuidValue? teamId})` stores `teamId`
  - [ ] `save()` sends `teamId` only when `recipeId == null`
  - [ ] `load` uses `access.canEdit`; the route shows Brew Mode instead of the wizard when it is false
- [ ] `RecipeListCubit(teamId: ...)` calls `listForTeam` instead of `listMine`. The team instance is route-scoped on `/teams/:id`; the personal instance stays session-scoped.
- [ ] Views:
  - [ ] `teams_screen.dart` (`/teams`): a list of teams with role badges, a Create team dialog (name, 1..80), and a "Join with invite" dialog that accepts a pasted invite URL or bare token, takes the last path segment, and opens `/invite/:token`. This is how native mobile users join, since the app does not receive the HTTPS link.
  - [ ] `team_detail_screen.dart` (`/teams/:id`): the team's recipes; a FAB that pushes `/recipes/new?teamId=` for editors only; an Invite button for the owner only. The caller's role comes from `TeamsCubit.state.teams`, and ownership from `team.ownerId == context.read<AuthRepository>().currentUserId`. Any push from this screen (wizard, Brew Mode) reloads the team list on return.
  - [ ] `/recipes/new` reads `teamId` from the query string and calls `startNew(teamId: ...)`.
  - [ ] `invite_sheet.dart`: role picker (Viewer/Editor), expiry picker (1h / 24h / 7d), Create, then the URL with a Copy button (`Clipboard.setData`) and a "Single use" note
  - [ ] `invite_accept_screen.dart` (`/invite/:token`): a spinner while accepting; on success, "You joined  as " with an Open team button; on failure, a message by code
  - [ ] Brew Mode app bar: "Add to team" (owner only, for a personal recipe, choosing from teams where they are an editor) and "Remove from team" (owner or team editor, for a team recipe)
  - [ ] Hide Edit and every editing control in Brew Mode when `access.canEdit == false` (US-4.4)
  - [ ] A bottom `NavigationBar` with My recipes and Teams
- [ ] Router:
  - [ ] Wrap `/` and `/teams` in a `StatefulShellRoute.indexedStack` with two branches, so the `NavigationBar` shows only on those two tabs and each tab keeps its scroll position.
  - [ ] `/teams/:id` is a sub-route of the Teams branch. `/invite/:token` is a top-level route on the root navigator, with no tab bar.
  - [ ] Give the Feature 3 recipe sub-routes (`recipes/new`, `recipes/:id`, `recipes/:id/edit`, `recipes/:id/share`) `parentNavigatorKey: rootNavigatorKey`. They then cover the tab bar, and pushing them from the Teams tab (for example `/recipes/new?teamId=`) does not switch the user to the My recipes tab.
  - [ ] Confirm the auth redirect keeps `from=/invite/<token>`, so a signed-out user who opens the link signs in and then lands back on it.
- [ ] Add `AuthRepository.currentUserId` (a `UuidValue?`) to the Feature 1 repository and its fake, for the ownership check above.
- [ ] Cubit tests:
  - [ ] `InviteAcceptCubit` maps each of `inviteExpired`, `inviteUsed`, `alreadyMember`, and `notFound` to failure with that code
  - [ ] `TeamsCubit.create` appends the team with role `editor`
  - [ ] `RecipeCreationCubit.save` sends `teamId` on insert and not on update
- [ ] Run the post-phase checklist, then `hot_restart`.



### 4.4 Integration Layer

- [ ] `ServerpodTeamRepository` on `client.team`; extend `ServerpodRecipeRepository` with the three team methods; implement `ServerpodAuthRepository.currentUserId` as `client.auth.authInfo?.authUserId`.
- [ ] Register `ServerpodTeamRepository` in `app_scope.dart` in place of the fake.
- [ ] Deep link on web. Invite URLs point at the web server (`http://localhost:8082` in development), which serves the app only after it has been built into `web/app`. Without a build, `:8082` shows the "build the Flutter app" page:
  - [ ] Run `serverpod run flutter_build` in `brewing_journal_server/`, then `hot_restart` (MCP) so `FlutterRoute` is registered (it is added only when `web/app` exists at startup).
  - [ ] Open `http://localhost:8082/invite/abc` and confirm the app loads and routes to the invite screen with "Invite not found". If `FlutterRoute` does not serve `index.html` for that path, add a fallback in `lib/server.dart` that serves the app's `index.html` for `/invite/**`.
  - [ ] For quick checks during development, the same path also works on the `flutter run` dev URL (`<dev-url>/invite/<token>`), because `go_router` uses path URLs.
- [ ] Native mobile: the invite is an HTTPS URL that opens in the browser (web app), or the recipient pastes it into "Join with invite". App and Universal Links are out of scope; record this in `AGENTS.md`.
- [ ] Error messages:
  - [ ] Shared defaults in `errorMessage`:
    - [ ] `inviteExpired`: "This invite has expired. Ask the team owner for a new one."
    - [ ] `inviteUsed`: "This invite has already been used."
    - [ ] `alreadyMember`: "You're already in this team."
  - [ ] Invite screen overrides `notFound` with "Invite not found." For `alreadyMember`, it also shows the Open team button.
  - [ ] Wizard and Brew Mode override `forbidden` with "Viewers can't change team recipes." when the recipe has a `teamId`, then call `getAccess` so the editing controls hide.
- [ ] Loading states: invite creation disables the Create button; accept shows a full-screen spinner; `assignToTeam` shows an inline progress indicator.
- [ ] After a successful accept, call `context.read<TeamsCubit>().load()` before Open team navigates to `/teams/:id`, so the new team and role are in state. After `assignToTeam` or `removeFromTeam`, call `context.read<RecipeListCubit>().load()` and `RecipeDetailCubit.load()`. If Brew Mode was opened from a team screen, that screen reloads its list when the push returns.
- [ ] End-to-end check with two accounts (two browser profiles, or sign out and sign in):
  - [ ] Owner creates the "Shop Recipes" team, adds a recipe, and creates a viewer invite.
  - [ ] User B opens the link signed out, signs in, returns to the invite, joins as viewer, sees the recipe, and has no Edit button.
  - [ ] User B opens the same link again: "You're already in this team" (the membership check runs before the claim).
  - [ ] User C opens B's used link: "This invite has already been used", and C does not join.
  - [ ] Owner creates an editor invite for user C. C edits the instructions, and the owner reloads to see C's list exactly.
- [ ] Run the post-phase checklist, and check both log tails.

---



## Feature 5 — Social Sharing (Image generation & `share_plus`)

**Stories:** US-5.1 through US-5.3. No server calls: the card is rendered from the `RecipeDetail` already loaded in Brew Mode.

### 5.1 Backend Schemas & Database

- [ ] No schema changes. The share card reads only `RecipeDetail` fields that already exist.
- [ ] No migration. Run `create_migration` (MCP) once and confirm it reports no changes.



### 5.2 Backend API Endpoints

- [ ] No new endpoints. Sharing writes nothing to the server and attaches no recipe link.
- [ ] Add a server test to `team_recipe_access_test.dart` confirming a team viewer's `recipe.get` returns the full `RecipeDetail` (instructions, tags, scores), which is everything the card needs.
- [ ] Run `dart test`.



### 5.3 Flutter UI & State Management

- [ ] Dependencies: `flutter pub add share_plus` (brings in `XFile` from `cross_file`; add `cross_file` explicitly if the analyzer asks for it).
- [ ] `lib/ui/features/share/share_card_layout.dart`: pure functions, unit-tested:
  - [ ] `visibleInstructions(List<String>)` returns `(rows, moreCount)`: 0 items gives `([], 0)`; 1..4 gives all rows and `0`; more than 4 gives the first 3 and `length - 3`
- [ ] `lib/ui/features/share/view/recipe_share_card.dart`: `RecipeShareCard(RecipeDetail)`:
  - [ ] Fixed `SizedBox(width: 360, height: 450)`, a `Column` with the content in `Expanded` + `ClipRect`, and a fixed 24px footer reading "Made with BrewSync", so content is cut above the footer
  - [ ] Content: title, ingredient name and kind, method, dose, temperature, grind, grinder, duration (only when non-null), `FlavorRadarChart` (from Feature 2), and flavor tags
  - [ ] Instruction rows with `maxLines: 2` and `TextOverflow.ellipsis`, plus a `+N more` line; the whole block is absent when there are no instructions (US-5.3)
  - [ ] No network images
- [ ] `lib/ui/features/share/cubit/`: `ShareCubit(ShareService)` with `status` (`idle/rendering/sharing/shared/unavailable/failure`) and `pngBytes`.
  - [ ] `beginRender()` sets `rendering`. The view calls it on tap before capturing the `RepaintBoundary`, because capture needs the widget tree and cannot run in the Cubit.
  - [ ] `share(Uint8List png, String title)` stores `pngBytes`, sets `sharing`, then: `dismissed` goes back to `idle` with no message; `unavailable` or an exception sets `unavailable`, which shows the download button
  - [ ] `download()` calls `ShareService.saveToDownloads(pngBytes)`; a failure sets `failure`
- [ ] `lib/data/services/share_service.dart`: abstract, plus a fake registered in `app_scope.dart`. The real one is added in 5.4.
- [ ] `lib/ui/features/share/view/share_screen.dart` (`/recipes/:id/share`, a sub-route next to `recipes/:id`):
  - [ ] Reads `RecipeDetail` from Brew Mode's `RecipeDetailCubit` (passed as `extra`, or loaded again by `id` on a web refresh)
  - [ ] Preview: the card inside a `RepaintBoundary(key: _cardKey)`, scaled to fit with `FittedBox`
  - [ ] A Share button that calls `ShareCubit.beginRender()`, then `await WidgetsBinding.instance.endOfFrame`, then `boundary.toImage(pixelRatio: 3)`, then `toByteData(format: png)`, then `ShareCubit.share`
  - [ ] A "Download image" button, shown only in the `unavailable` state
- [ ] Brew Mode: the Share action goes to `/recipes/:id/share` for anyone with read access, viewers included.
- [ ] Tests:
  - [ ] Unit: `visibleInstructions` for 0, 1, 4, 5, and 30 items
  - [ ] Widget: no instructions means no instruction block; 6 instructions show 3 rows plus "+3 more"; a 280-character instruction does not overflow (no `RenderFlex` error); the footer is always found
  - [ ] Golden (optional): `matchesGoldenFile('goldens/share_card_v60.png')` for a sample recipe
  - [ ] Cubit: `beginRender` goes to `rendering`; `dismissed` goes to `idle`; `unavailable` goes to `unavailable`; an exception goes to `unavailable`; a failed `download` goes to `failure`
- [ ] Run the post-phase checklist, then `hot_restart`.



### 5.4 Integration Layer

- [ ] `SharePlusShareService implements ShareService`:
  - [ ] `share(bytes, title)`: `SharePlus.instance.share(ShareParams(files: [XFile.fromData(bytes, mimeType: 'image/png', name: 'brewsync-recipe.png')], subject: title))`, returning `ShareResult.status`
  - [ ] No `text` or `uri` parameter, so only the image is shared
  - [ ] `saveToDownloads(bytes)`: `XFile.fromData(...).saveTo('brewsync-recipe.png')`, which triggers a browser download on web. On iOS and Android the share sheet is always available, so this fallback is expected only on web. On mobile, `saveTo` would need a real file path.
  - [ ] iPad: pass `sharePositionOrigin` from the Share button's `RenderBox`, or the share sheet throws
- [ ] Register `SharePlusShareService` in `app_scope.dart` in place of the fake.
- [ ] Loading: `rendering` or `sharing` disables the Share button and shows a spinner.
- [ ] Errors: `unavailable` shows "Sharing isn't supported here — download the image instead"; a failed download shows a snackbar with Retry.
- [ ] Platform checks:
  - [ ] Web (Chrome desktop, which has no file sharing): Share falls back to Download, and the downloaded PNG is 1080×1350
  - [ ] iOS or Android simulator: the share sheet opens with one PNG and no text
  - [ ] Team viewer account: Share is visible and works
- [ ] Run the post-phase checklist, and check both log tails.

---



## Wrap-up

- [ ] Full regression with `flutter_driver`: sign up, create a recipe (all 5 steps), open Brew Mode and let the timer finish, create a team and invite a viewer, accept as a second user, share from the viewer account.
- [ ] `dart test` in `brewing_journal_server/` and `flutter test` in `brewing_journal_flutter/` both pass.
- [ ] `dart analyze` is clean in all three packages; run `dart format .`.
- [ ] Confirm `migrations/migration_registry.txt` lists: initial, `recipes`, `teams`. `create_migration` reports no pending changes.
- [ ] Update `AGENTS.md` with a description of BrewSync (features, folder layout, `RecipeAccessPolicy`, the invite URL format, and the known limit that invites open in the web app). Keep the MCP section and the checklist, and remove the "After building the first version…" paragraph.
- [ ] Set `enableTextEntryEmulation` in `lib/driver.dart` back to `false`.