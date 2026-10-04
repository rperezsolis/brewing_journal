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

Features are ordered so each one depends only on the features before it. The one deviation from the final schema in the system design is that **Feature 2 builds personal recipes only**. `Recipe.team`, `RecipeDraft.teamId`, `RecipeAccess.role`, and the `recipe_team_updated_idx` index are added in **Feature 4**. That migration creates the three team tables and adds one nullable column to `recipe`, so no existing data is lost. When Feature 4 is done, the recipe and team tables match the system design. **Feature 6** adds the `recipe_favorite` table afterward. `Recipe.isFavorite` is not stored, so that migration does not change `recipe`. **Feature 7** adds the `team_recipe_favorite` table. It leaves `recipe_favorite` and `recipe` unchanged.

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
- [x] Server test `test/integration/auth/require_login_test.dart` (`withServerpod`). This test depends on the first `AuthenticatedEndpoint` subclass, so write it now and run it after 2.2: written and passing since Feature 2.
  - [x] An unauthenticated `sessionBuilder` call to `endpoints.recipe.listMine` fails with `ServerpodUnauthenticatedException`.
  - [x] The same call with a `createTestUser` session builder succeeds and returns `[]`.
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

- [x] **Enums** (`serialized: byName`):
  - [x] `lib/src/brewing/beverage_kind.spy.yaml`: `coffee, tea, matcha`
  - [x] `lib/src/brewing/roast_level.spy.yaml`: `light, medium, mediumDark, dark`
  - [x] `lib/src/brewing/extraction_method.spy.yaml`: `v60, espresso, frenchPress, aeropress, chemex, coldBrew, matchaWhisk, other`
  - [x] `lib/src/brewing/brewing_error_code.spy.yaml`: `notFound, forbidden, validation, inviteExpired, inviteUsed, alreadyMember, uploadRejected` (all codes now, so the enum does not churn in Feature 4)
- [x] **Exception**: `lib/src/brewing/brewing_exception.spy.yaml` with `code: BrewingErrorCode` and `message: String`.
- [x] **Table** `ingredient` (`ingredient.spy.yaml`):
  - [x] Fields: `owner: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)`, `kind`, `name`, `nameKey`, `origin?`, `roaster?`, `roastLevel?`, `processing?`, `createdAt: DateTime, default=now`.
  - [x] Index `ingredient_owner_kind_name_idx` on `ownerId, kind, nameKey`.
- [x] **Table** `recipe` (`recipe.spy.yaml`), without `team`:
  - [x] `owner` (Cascade), `ingredient: Ingredient?, relation(onDelete=NoAction)`.
  - [x] `title`, `waterTempC: double`, `doseGrams: double`, `grindSize`, `grinderModel`, `extractionMethod`, `extractionMethodNote: String?`, `extractionDuration: Duration?`.
  - [x] `acidity`, `sweetness`, `body`, `bitterness: int`.
  - [x] `createdAt` and `updatedAt`, both `default=now`.
  - [x] Child lists: `instructions` (`recipe_instructions`), `photos` (`recipe_photos`), `flavorTags` (`recipe_flavor_tags`).
  - [x] Indexes `recipe_owner_updated_idx` (`ownerId, updatedAt`) and `recipe_ingredient_idx` (`ingredientId`).
- [x] **Table** `recipe_instruction`: `recipe` (Cascade, `recipe_instructions`), `sortOrder: int`, `text: String`. Unique index `recipe_instruction_order_idx` on `recipeId, sortOrder`.
- [x] **Table** `recipe_flavor_tag`: `recipe` (Cascade, `recipe_flavor_tags`), `tag`, `tagKey`. Unique `recipe_flavor_tag_recipe_idx` (`recipeId, tagKey`), plus `recipe_flavor_tag_key_idx` (`tagKey`).
- [x] **Table** `recipe_photo`: `recipe` (Cascade, `recipe_photos`), `storagePath`, `sortOrder`, `createdAt`, `publicUrl: Uri?, !persist`. Unique `recipe_photo_order_idx` (`recipeId, sortOrder`) and unique `recipe_photo_path_idx` (`storagePath`).
- [x] **DTOs** (no `table`):
  - [x] `ingredient_draft.spy.yaml`: `kind`, `name`, `origin?`, `roaster?`, `roastLevel?`, `processing?`
  - [x] `recipe_draft.spy.yaml`: every field in the system design except `teamId`: `id?`, `ingredientId`, the parameters, the scores, `flavorTags: List<String>`, `instructions: List<String>`
  - [x] `recipe_access.spy.yaml`: `canEdit: bool`, `canDelete: bool` (`role` comes in Feature 4)
  - [x] `recipe_detail.spy.yaml`: `recipe`, `ingredient`, `instructions`, `flavorTags`, `photos`, `access`
  - [x] `upload_ticket.spy.yaml`: `path`, `description`
- [x] Generate: save and watch `serverpod start` output, or run `serverpod generate`. Fix any YAML errors before continuing.
- [x] Confirm the generated `Recipe.ownerId`, `Recipe.ingredientId`, and `RecipeInstruction.recipeId` are `UuidValue`.
- [x] `create_migration` (MCP), or CLI `serverpod create-migration --tag recipes`. Created with the CLI: `20260925200116958-recipes`.
- [x] Review the new `migration.sql`: 5 `CREATE TABLE` statements, foreign keys to `serverpod_auth_core_user` with `ON DELETE CASCADE`, `recipe.ingredientId` with `NO ACTION`, and all 8 indexes.
- [x] `apply_migrations` (MCP), then `tail_server_logs` to confirm it applied. Applied in the running `serverpod start` session; the restart log reads "Latest database migration already applied."



### 2.2 Backend API Endpoints

- [x] `lib/src/brewing/recipe_limits.dart` with constants shared by the endpoints and tests: `kInstructionMaxLength = 280`, `kMaxInstructions = 30`, `kMaxTags = 12`, `kTagMaxLength = 40`, `kTitleMaxLength = 120`, `kGrindMaxLength = 80`, `kMaxPhotos = 6`.
- [x] `lib/src/brewing/recipe_validator.dart`: pure functions that throw `BrewingException(code: validation, message: '<field>: ...')`:
  - [x] title 1..120, grind size and grinder model 1..80 (after trim)
  - [x] `waterTempC` 1..100, `doseGrams` 0.1..500, `extractionDuration` null or 1s..2h
  - [x] each score 0..5
  - [x] `extractionMethod == other` requires a non-empty `extractionMethodNote`
  - [x] tags 1..40 after trim, at most 12; de-duplicate by `tagKey`
  - [x] instructions: trim each, reject blank or > 280, at most 30, keep duplicates and order (US-2.7, US-2.8, US-2.11)
- [x] `lib/src/brewing/recipe_access_policy.dart`: `RecipeAccessPolicy.resolve(session, recipe)`. For now, the owner gets `canEdit/canDelete = true` and anyone else gets `notFound`. Feature 4 adds the team branch. `resolve` is already async (Feature 4 needs a membership lookup), and `load` / `loadForEdit` wrap the find + resolve (+ `forbidden`) steps.
- [x] `lib/src/brewing/ingredient_endpoint.dart`: `IngredientEndpoint extends AuthenticatedEndpoint`:
  - [x] `search(kind, query, limit)`: clamp `limit` to 1..30, filter `ownerId == callerId`, `kind`, `nameKey.like('${key}%')`, order by `nameKey`
  - [x] `register(IngredientDraft)`: trim the name (1..120), compute `nameKey`, return the existing row on `(owner, kind, nameKey)`, otherwise insert
- [x] `lib/src/brewing/recipe_endpoint.dart`: `RecipeEndpoint extends AuthenticatedEndpoint`:
  - [x] `save(RecipeDraft)` inside `session.db.transaction`, following steps 1–6 of the system design: load and resolve access on update, check the ingredient, validate, insert or update (refresh `updatedAt`), delete and re-insert `recipe_instruction` (`sortOrder = index`) and `recipe_flavor_tag`, then return `get`
  - [x] `get(id)`: one query with `include` for ingredient, instructions (`orderBy sortOrder`), tags, and photos (`orderBy sortOrder`); fill `photos[].publicUrl` with `session.storage.publicDownloadUrl(storageId: 'public', path: ...)` and fill `access`
  - [x] `listMine(limit, offset)`: clamp to 1..50, `ownerId == callerId`, `orderBy updatedAt desc`
  - [x] `getAccess(id)`
  - [x] `delete(id)`: requires `canDelete`; reads the photo `storagePath`s first, deletes the row (children cascade), then calls `session.storage.deleteFile(storageId: 'public', path: ...)` for each path after commit, logging failures instead of throwing
- [x] `lib/src/brewing/recipe_media_endpoint.dart`: `RecipeMediaEndpoint extends AuthenticatedEndpoint`:
  - [x] `createUploadDescription(recipeId)`: requires `canEdit`, at most 6 photos, path `recipes/<recipeId>/<Uuid().v4()>.jpg`, returns `UploadTicket(path: path, description: await session.storage.createUploadDescription(storageId: 'public', path: path))`
  - [x] `confirmUpload(recipeId, path)`: requires `canEdit`; the path must match `^recipes/<recipeId>/[0-9a-f-]{36}\.jpg$`; return the existing row if one exists; `session.storage.verifyUpload(storageId: 'public', path: path)` false gives `uploadRejected` (US-2.12); insert with `sortOrder = max + 1` in a transaction and retry once on a unique conflict. `verifyUpload` returns false for a file that is already verified (a retried confirm, or `storeFile` in tests), so an existing verified file (`fileExists`) is accepted too
  - [x] `remove(photoId)`: requires `canEdit` on the parent recipe, deletes the row, then deletes the storage object best-effort
- [x] Server tests in `test/integration/brewing/` (`withServerpod`, users A and B from `createTestUser`):
  - [x] `ingredient_endpoint_test.dart`: prefix search is case-insensitive; `register` with the same name in different case returns the same id; an empty name gives `validation`; user B cannot see user A's ingredients
  - [x] `recipe_save_test.dart`:
    - [x] insert, then update; the update refreshes `updatedAt` and keeps `createdAt`
    - [x] instructions `['  stir ', 'stir']` are saved as `['stir', 'stir']` in order (US-2.7, US-2.8)
    - [x] `'use 150ml of whole milk'` round-trips unchanged (US-2.10)
    - [x] `''` or `'   '` gives `validation`; 281 characters gives `validation`; exactly 280 is accepted; 31 items gives `validation`
    - [x] saving `instructions: []` removes every row (US-2.4)
    - [x] tags `['Fruity', ' fruity ']` are stored once; a 41-character tag gives `validation`
    - [x] saving with user B's `ingredientId` gives `notFound`
  - [x] `recipe_get_test.dart`: instructions come back in `sortOrder`; user B calling `get` gives `notFound`; `access` is `canEdit/canDelete = true` for the owner
  - [x] `recipe_list_test.dart`: `listMine` is newest `updatedAt` first, pages with `limit`/`offset`, and never includes user B's recipes
  - [x] `recipe_validation_test.dart`: one case per boundary (temp 0/101, dose 0/501, duration 0s/2h1s, score -1/6, `other` with no note, 13 tags, title of 121 characters)
  - [x] `recipe_media_test.dart`:
    - [x] happy path: `createUploadDescription`, then `session.storage.storeFile(storageId: 'public', path: ticket.path, byteData: ...)`, then `confirmUpload` returns a row with a `publicUrl`; a second `confirmUpload` with the same path returns the same row
    - [x] a forged path gives `validation`; confirming without an upload gives `uploadRejected` and no row; the 7th upload description gives `validation`; `remove` by user B gives `notFound`
  - [x] `recipe_delete_test.dart`: owner delete cascades to instructions, tags, and photos; user B calling `delete` gives `notFound`
- [x] Run the post-phase checklist, then `dart test` in `brewing_journal_server/`.



### 2.3 Flutter UI & State Management

- [x] Dependencies: `flutter pub add image_picker image`.
- [x] iOS: add `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription` to `ios/Runner/Info.plist`, or the picker crashes. Android's photo picker needs no permission.
- [x] Abstract repositories in `lib/data/repositories/`, plus in-memory fakes:
  - [x] `IngredientRepository`: `search`, `register`
  - [x] `RecipeRepository`: `save`, `get`, `listMine`, `getAccess`, `delete`
  - [x] `RecipeMediaRepository`: `uploadPhoto(recipeId, ByteData)` returning `RecipePhoto`, and `remove(photoId)`
- [x] Mirror the server limits in `lib/ui/features/recipe_creation/recipe_limits.dart` (`kInstructionMaxLength = 280`, and so on).
- [x] `RecipeCreationState` (Equatable), with every field from the system design except `teamId` (Feature 4). Include `enum RecipeWizardStep` and `enum SaveStatus`.
- [x] `RecipeCreationCubit`:
  - [x] `startNew()`, `load(id)`
  - [x] `searchIngredients`, with a 250ms debounce in the view; `selectIngredient`, `registerIngredient`
  - [x] `setExtraction(...)`, `setExtractionDuration(Duration?)`. Implemented as one setter per field (`setTitle`, `setWaterTemp`, `setDose`, `setGrindSize`, `setGrinderModel`, `setExtractionMethod`, `setExtractionMethodNote`), so a nullable number can be cleared.
  - [x] `startStopwatch` / `stopStopwatch` / `resetStopwatch`: a `Stopwatch` plus a 100ms `Timer.periodic`; cancel it in `close()`
  - [x] `setFlavor({scores, tags})`
  - [x] `addInstruction` / `updateInstruction` / `removeInstruction` / `moveInstruction`: trim, reject blank or > 280 without changing the list, cap at 30, allow duplicates
  - [x] `skipInstructions()`, `next()` / `back()` with the per-step guards (`next` from extraction stops a running stopwatch)
  - [x] `save()`; `addPhoto(ByteData)`, which calls `save()` first when `recipeId == null`; `removePhoto(id)`
- [x] Views in `lib/ui/features/recipe_creation/view/`:
  - [x] `recipe_wizard_screen.dart`: `BlocProvider` at the route, a step indicator (1–5), Back/Next buttons, and a `BlocListener` for `error`, which shows a snackbar
  - [x] `step_ingredient.dart`: kind selector (`SegmentedButton<BeverageKind>`), search field, result list, and a "Register new" bottom sheet form (origin, roaster, roast level, processing)
  - [x] `step_extraction.dart`: title, temperature, dose, grind size, grinder model (US-2.1), method dropdown plus a note field when `other`; stopwatch card with Start/Stop/Reset and a live `mm:ss.t` readout (US-2.2); a manual duration field
  - [x] `step_flavor.dart`: 4 sliders (0..5) plus a live `FlavorRadarChart` (`CustomPainter` in `ui/core/widgets/flavor_radar_chart.dart`, reused by Feature 5) and a tag chip input (US-2.3)
  - [x] `step_instructions.dart`: a `ReorderableListView` of editable rows, an add field with a `maxLength: 280` counter, delete per row, and a Skip button (US-2.4, US-2.5)
  - [x] `step_media.dart`: photo grid, add via `ImagePicker().pickImage(maxWidth: 2048, maxHeight: 2048, imageQuality: 85)`, a progress overlay while `pendingUpload`, delete per photo, and a Finish button that works with 0 photos (US-2.6). Finish calls `save()` and returns to the list. The Add button is hidden once there are 6 photos.
  - [x] `lib/ui/features/recipe_creation/photo_encoder.dart`: turns the picked `XFile` into JPEG `ByteData`. If `mimeType` is not `image/jpeg` (web keeps PNG input as PNG), decode and re-encode with `package:image` (`encodeJpg(quality: 85)`), so the bytes match the server's `.jpg` path.
- [x] Register the three fake repositories in `app_scope.dart`.
- [x] `lib/ui/features/recipe_list/`: `RecipeListCubit({UuidValue? teamId})` with `load()`, `loadMore()`, and `reset()`, calling `listMine` for now. Feature 4 adds the `teamId` branch.
  - [x] Add the personal instance (no `teamId`) to `app_scope.dart` as a session-scoped Cubit that loads on `authenticated` and resets on `unauthenticated`.
  - [x] `RecipeListScreen` is the new `/` home and replaces the Feature 1 placeholder. Its app bar keeps the Sign out action, and a FAB goes to `/recipes/new`.
  - [x] An empty state ("No recipes yet") when the list is empty.
- [x] Routes: `/recipes/new` and `/recipes/:id/edit`. Declare `/recipes/new` before any `/recipes/:id` route, so `new` is not read as an id. Until Brew Mode exists (Feature 3), tapping a list item opens `/recipes/:id/edit`. Already declared as sub-routes of `/` (the Feature 3 layout).
- [x] Cubit tests (`bloc_test` with fakes):
  - [x] instruction add, edit, move, and remove, including removing the last item, which leaves `[]`
  - [x] blank or 281-character input sets `error` and leaves the list unchanged
  - [x] `next()` guards on each step
  - [x] the stopwatch writes `extractionDuration` on stop and clears it on reset
  - [x] `load` restores the instructions in order (US-2.9)
  - [x] `addPhoto` with no `recipeId` calls `save` first; an `uploadRejected` failure leaves `photos` unchanged
  - [x] `skipInstructions()` clears the list and advances to the media step
  - [x] a failed `save` keeps every field and sets `saveStatus = failure`
  - [x] `RecipeListCubit`: `loadMore` appends the next page; `reset` empties the list (sign-out)
- [x] Widget test: `step_instructions` reorders two rows by drag.
- [x] Run the post-phase checklist, then `hot_restart`.



### 2.4 Integration Layer

- [x] Serverpod-backed implementations:
  - [x] `ServerpodIngredientRepository` on `client.ingredient`
  - [x] `ServerpodRecipeRepository` on `client.recipe`
  - [x] `ServerpodRecipeMediaRepository`: `client.recipeMedia.createUploadDescription`, then `FileUploader(ticket.description).uploadByteData(bytes)`, then `client.recipeMedia.confirmUpload(recipeId, ticket.path)`. If the upload returns false, throw a local `uploadRejected` without calling confirm. A `FileUploader` can upload only once, so create a new one for each attempt.
- [x] Register these in `app_scope.dart` in place of the fakes. Route `BlocProvider`s already read them with `context.read`, so no route changes.
- [x] Loading states:
  - [x] `saveStatus == saving` disables Next/Finish and shows a progress indicator on the button
  - [x] ingredient search shows a small inline spinner
  - [x] `pendingUpload` shows an overlay on the new photo tile
- [x] Error handling: add `BrewingException` support and the `overrides` parameter to `errorMessage` in `ui/core/error_messages.dart`. Shared defaults:
  - [x] `validation`: show `message`, which names the field
  - [x] `notFound`: "Recipe not found"; the wizard then goes back to the list
  - [x] `forbidden`: "You can't edit this recipe"
  - [x] `uploadRejected`: "Photo could not be verified — try again or skip" (US-2.12)
  - [x] The invite codes (`inviteExpired`, `inviteUsed`, `alreadyMember`) get their defaults in Feature 4.
  - [x] Every failure keeps the wizard input unchanged.
- [x] After `save` succeeds, call `context.read<RecipeListCubit>().load()` (the session-scoped instance) so the home list is current when the wizard closes.
- [ ] End-to-end check (`get_flutter_app_dtd` → `connect_dart_tooling_daemon` → `flutter_driver`). Set `enableTextEntryEmulation: true` in `lib/driver.dart` and `hot_restart`. Leave it on for the Feature 3–5 checks; the wrap-up turns it off. Blocked in this session: the `serverpod` and `dart` MCP tools are not connected, so the driver path cannot run. A Cursor-browser substitute never reached a Flutter frame (DDC debug load stayed on a blank page).
  - [ ] Create a V60 recipe with a stopwatch time, 3 flavor tags, and 3 instructions including a duplicate; skip photos; the recipe shows up on the list.
  - [ ] Edit it: the instructions load in order; reorder and remove all of them; save; reopen and confirm there are none.
  - [ ] Add a photo larger than 512 KB, confirm it renders from `publicUrl`, then remove it. This checks the `maxRequestSize` change from Feature 0. Confirmed in the running app after a cold start: add-photo works. Not separately measured as >512 KB.
  - [ ] On Flutter web, confirm photos load. The dev app is on a different origin from the API server (`:8080`), and `Image.network` fetches need CORS there. If the browser console shows a CORS error, pass `webHtmlElementStrategy: WebHtmlElementStrategy.fallback` to `Image.network`. `WebHtmlElementStrategy.fallback` is already set on the photo tile.
- [x] Run the post-phase checklist, and check both log tails. `dart analyze` / `dart format` / `dart test` (66) and `flutter analyze` / `flutter test` (70) are clean. Server logs after the migration restart show no pending migrations and no recipe/media errors.

---



## Feature 3 — Recipe Replay & Timer (Brew Mode)

**Stories:** US-3.1 through US-3.6. The timer and alarm run only in Flutter. The server already stores `extractionDuration` (Feature 2).

### 3.1 Backend Schemas & Database

- [x] No schema changes. Confirm `recipe.extractionDuration` (`Duration?`) exists in `definition.sql` as a nullable `bigint`.
- [x] No migration needed. Run `create_migration` (MCP) once and confirm it reports no changes. CLI `serverpod create-migration` reported "Server migration skipped. No changes detected."



### 3.2 Backend API Endpoints

- [x] No new endpoints. Brew Mode reads `client.recipe.get` from Feature 2.
- [x] Add server tests to `recipe_get_test.dart` covering the Brew Mode contracts:
  - [x] A recipe saved with `extractionDuration: null` returns `null`, not zero (US-3.4).
  - [x] A recipe with no instructions returns `instructions: []` (US-3.2).
  - [x] A recipe with no photos returns `photos: []` (US-3.6).
  - [x] Every photo has a non-null `publicUrl`.
- [x] Run `dart test`. Server suite: 70 passed.



### 3.3 Flutter UI & State Management

- [x] Dependencies: `flutter pub add audioplayers`. Add `assets/sounds/brew_alarm.mp3` and list it under `flutter: assets:` in `pubspec.yaml`, next to the existing `assets/config.json` entry (do not replace it: the app reads its server URL from that file).
- [x] `lib/data/services/alarm_player.dart`: abstract `AlarmPlayer` with `prepare()`, `play()`, and `stop()`; `AudioAlarmPlayer` on `audioplayers` (`AssetSource`, loop until `stop`); `FakeAlarmPlayer` that counts calls. Register the fake in `app_scope.dart`.
- [x] `lib/ui/features/recipe_detail/cubit/`: `RecipeDetailCubit(RecipeRepository)` with `load(id)`, `delete()` (only when `access.canDelete`), and a status of `initial/loading/success/failure`.
- [x] `lib/ui/features/brew_mode/cubit/`:
  - [x] `BrewTimerState` with `mode`, `phase`, `target`, `elapsed`, `remaining`
  - [x] `BrewTimerCubit(AlarmPlayer)`: `configure(Duration?)`, `setMode`, `start`, `pause`, `resume`, `stop`, `tick`
  - [x] `tick` reads `stopwatch.elapsed`; at `elapsed >= target` it sets `phase = finished`, cancels the ticker, and calls `AlarmPlayer.play()` exactly once
  - [x] `close()` cancels the ticker and calls `AlarmPlayer.stop()` (US-3.5)
- [x] `lib/ui/features/brew_mode/view/brew_mode_screen.dart`:
  - [x] `MultiBlocProvider` (`RecipeDetailCubit`, `BrewTimerCubit`); on detail success, call `configure(recipe.extractionDuration)`
  - [x] Parameter block: ingredient, method, dose, temperature, grind, grinder, and a small `FlavorRadarChart` (US-3.1)
  - [x] "Prep & extra steps" numbered list in `sortOrder`, left out entirely when empty (US-3.2)
  - [x] Photo carousel from `publicUrl`, left out when empty; `errorBuilder` shows a neutral tile, never a broken-image icon (US-3.6)
  - [x] Timer panel: large readout, a Count down / Count up toggle (only while idle), and Start/Pause/Resume/Stop. When `target == null`, hide the whole panel and show "No extraction time recorded" (US-3.4)
  - [x] Finished state: a highlighted readout and a "Stop alarm" button (US-3.3)
  - [x] `AppLifecycleListener(onHide: ...)`: call `pause()` while running, and `stop()` when `phase == finished`, so a ringing alarm does not keep playing in the background (US-3.5). The system design only calls `pause()` here; `stop()` closes the gap for an alarm that is already ringing.
  - [x] `WakelockPlus` is optional; skip it for the MVP
  - [x] App-bar actions: Edit (when `access.canEdit`), Share (Feature 5 placeholder), Delete (when `access.canDelete`, with a confirm dialog)
- [x] Routes: `/recipes/:id` goes to Brew Mode. Tapping a recipe on the list now opens Brew Mode instead of the editor, and the Edit action pushes `/recipes/:id/edit`.
  - [x] Declare the recipe routes as sub-routes of `/` (`recipes/new`, `recipes/:id`, `recipes/:id/edit`, and later `recipes/:id/share`), so a deep link opens on top of the home list and Back works.
  - [x] Wizard Finish: for a new recipe, `context.pushReplacement('/recipes/$id')`; when editing, `context.pop()`. Brew Mode awaits its Edit push and calls `RecipeDetailCubit.load()` on return, so the edited values show without two Brew Mode pages on the stack.
- [x] Cubit tests using `fake_async`:
  - [x] `configure(null)` gives `mode idle`, `start()` does nothing, and the alarm is never prepared or played
  - [x] `start()` with a target calls `prepare()` once
  - [x] count-down to 3s: the alarm plays once at 3s, `remaining` is clamped at zero, and further ticks do not replay it
  - [x] count-up to 3s also alarms at 3s
  - [x] `pause` freezes `elapsed`; `resume` continues from it
  - [x] `stop` resets to `idle` with `elapsed = 0` and `remaining = target`, and stops the alarm
  - [x] `setMode` works only while `phase == idle` and does nothing while running
  - [x] closing the cubit mid-run calls `stop()`, and advancing time afterwards never calls `play()`
- [x] Widget tests: the instructions section is absent for `[]`, the photos section is absent for `[]`, and the timer panel is absent for a null target.
- [x] Run the post-phase checklist, then `hot_restart` (new asset). `dart analyze` / `dart format` / `dart test` (70) and `flutter analyze` / `flutter test` (86) are clean. Hot restart applied; server log reads "Latest database migration already applied."



### 3.4 Integration Layer

- [x] Register `AudioAlarmPlayer` in `app_scope.dart` in place of the fake. `RecipeDetailCubit` already gets `ServerpodRecipeRepository` from Feature 2's registration.
- [x] Loading: a full-screen spinner while `RecipeDetailCubit` is loading; pull-to-refresh calls `load` again.
- [x] Errors: `errorMessage(e, overrides: {notFound: 'Recipe not found or no longer shared with you'})` with a Back button; a connection error shows the shared message with Retry.
- [x] Web: the first sound must come from a user gesture. `BrewTimerCubit.start()` calls `AlarmPlayer.prepare()` (`setSource` only) before starting the ticker. Because `start()` runs inside the Start button's tap, the later alarm is allowed to play.
- [x] After `delete()` succeeds, call `context.read<RecipeListCubit>().load()` and pop to the list.
- [x] End-to-end check (`flutter_driver`):
  - [x] Open a recipe with a 5s duration, start the count-down, and confirm the finished state after 5s (check `tail_flutter_logs` for audio errors).
  - [x] Open a recipe with no duration: there are no timer controls and parameters still render.
  - [x] Start a timer, navigate back before it finishes, wait past the target, and confirm there is no sound or log output.
- [x] Run the post-phase checklist, and check both log tails. Analyze/format/tests are clean. After hot restart the TUI shows the server and Flutter app restarted with no recipe/timer errors; MCP `tail_*_logs` was not available in this session.

---



## Feature 4 — Collaborative Teams & RBAC

**Stories:** US-4.1 through US-4.6. Roles are rows in `team_membership`, checked inside endpoint methods. Serverpod scopes are not used.

### 4.1 Backend Schemas & Database

- [x] **Enum** `lib/src/teams/team_role.spy.yaml`: `viewer, editor` (`serialized: byName`).
- [x] **Table** `team` (`team.spy.yaml`): `owner` (Cascade), `name`, `createdAt`, `memberships` (`team_memberships`), `invites` (`team_invites`), `recipes` (`team_recipes`). Index `team_owner_idx` on `ownerId`.
- [x] **Table** `team_membership`: `team` (Cascade, `team_memberships`), `member: module:serverpod_auth_core:AuthUser?` (Cascade), `role: TeamRole`, `createdAt`. Unique `team_membership_team_member_idx` (`teamId, memberId`), plus `team_membership_member_idx` (`memberId`).
- [x] **Table** `team_invite`: `team` (Cascade, `team_invites`), `createdBy` (Cascade), `token`, `role`, `expiresAt`, `usedAt?`, `usedBy` (`optional, onDelete=SetNull`), `createdAt`. Unique `team_invite_token_idx` (`token`), plus `team_invite_team_idx` (`teamId, expiresAt`).
- [x] **Extend** `recipe.spy.yaml`: add `team: Team?, relation(name=team_recipes, optional, onDelete=SetNull)` and the index `recipe_team_updated_idx` (`teamId, updatedAt`).
- [x] **Extend DTOs**:
  - [x] `recipe_draft.spy.yaml`: add `teamId: UuidValue?`
  - [x] `recipe_access.spy.yaml`: add `role: TeamRole?`
- [x] **New DTOs**: `invite_link.spy.yaml` (`token`, `role`, `expiresAt`, `url`) and `team_summary.spy.yaml` (`team`, `role`).
- [x] Generate (automatic, or `serverpod generate`). Fix any call sites that no longer compile because `RecipeAccess` now has `role` (server and Flutter fakes).
- [x] `create_migration` (MCP), or CLI `serverpod create-migration --tag teams`.
- [x] Review `migration.sql`: 3 `CREATE TABLE` statements; `ALTER TABLE recipe ADD COLUMN "teamId" uuid` (nullable, no data loss), a foreign key with `ON DELETE SET NULL`, and the new index. It should need no `--force` and no hand edit.
- [x] Diff the migration's `definition.sql` against the system design section 1: every table and index should match.
- [x] `apply_migrations` (MCP), then `tail_server_logs`.



### 4.2 Backend API Endpoints

- [x] `lib/src/teams/team_membership_lookup.dart`: `Future<TeamMembership?> membershipOf(session, teamId, memberId)` using the unique index.
- [x] Extend `RecipeAccessPolicy.resolve` to match the authorization table:
  - [x] owner: `canEdit = canDelete = true`, and `role` is the owner's membership role if the recipe is in a team
  - [x] team editor who is not the owner: `canEdit = true`, `canDelete = false`
  - [x] team viewer: `canEdit = false`, `canDelete = false`
  - [x] a personal recipe of someone else, or a non-member: `notFound`
- [x] Extend `RecipeEndpoint.save`:
  - [x] on insert with `teamId`, the caller must be an editor of that team, else `forbidden`
  - [x] on update, ignore `draft.teamId` and keep the stored `teamId`
  - [x] step 2: on update, the ingredient may equal the recipe's current `ingredientId` even if another member owns it
  - [x] a viewer calling `save` gets `forbidden` (US-4.4)
- [x] Add to `RecipeEndpoint`:
  - [x] `listForTeam(teamId, limit, offset)`: requires membership, else `notFound`; `orderBy updatedAt desc`
  - [x] `assignToTeam(recipeId, teamId)`: the caller must own the recipe and be an editor of `teamId`; sets `teamId` and `updatedAt`
  - [x] `removeFromTeam(recipeId)`: the caller must own the recipe or be an editor of its current team; sets `teamId = null`
- [x] `RecipeMediaEndpoint`: no code change. It already uses `RecipeAccessPolicy`, so team editors can upload and viewers get `forbidden`.
- [x] `lib/src/teams/invite_token.dart`: 32 bytes from `Random.secure()`, `base64Url.encode(...).replaceAll('=', '')`.
- [x] `lib/src/teams/web_base_url.dart`: build `publicScheme://publicHost:publicPort` from `session.serverpod.config.webServer`, leaving out the default port (80/443). `webServer` is nullable; if it is missing, throw a `StateError` rather than issuing a broken link.
- [x] `lib/src/teams/team_endpoint.dart`: `TeamEndpoint extends AuthenticatedEndpoint`:
  - [x] `create(name)`: trim, 1..80; one transaction inserts the `team` and the creator's `editor` membership (US-4.1)
  - [x] `listMine()`: memberships for `memberId == callerId`, `include: team`, mapped to `TeamSummary`
  - [x] `createInvite(teamId, role, ttl)`: a non-member gets `notFound`, a member who is not the owner gets `forbidden`; clamp `ttl` to 15min..7d; insert a `team_invite`; return an `InviteLink` with `url = '$webBaseUrl/invite/$token'` (US-4.2, US-4.3)
  - [x] `acceptInvite(token)`:
    - [x] look up by token, unknown gives `notFound`
    - [x] caller is already a member: `alreadyMember`, and the invite stays unused
    - [x] in a transaction: `session.db.unsafeExecute('UPDATE team_invite SET "usedAt" = @now, "usedById" = @caller WHERE token = @token AND "usedAt" IS NULL AND "expiresAt" > @now', parameters: QueryParameters.named({...}), transaction: tx)`. Pass `now` as `DateTime.now().toUtc()`, not SQL `now()`: Serverpod stores `DateTime` as UTC `timestamp without time zone`, so SQL `now()` would compare in the database's time zone. The call returns the affected row count.
    - [x] 1 row updated: insert a `team_membership` with the invite's role, return `TeamSummary`
    - [x] 0 rows: re-read, then throw `inviteUsed` if `usedAt != null`, else `inviteExpired`; write nothing (US-4.5)
- [x] Server tests in `test/integration/teams/` (users Owner, Editor, Viewer, Stranger):
  - [x] `team_endpoint_test.dart`: `create` inserts an editor membership for the creator; `listMine` returns only the caller's teams; an editor calling `createInvite` gets `forbidden`; a stranger gets `notFound`; `ttl` is clamped
  - [x] `accept_invite_test.dart`: success creates the membership with the right role; a second accept of the same token by another user gets `inviteUsed`; an expired token (seeded `expiresAt` in the past) gets `inviteExpired` with no membership; an existing editor opening a viewer link gets `alreadyMember`, keeps the editor role, and the token stays usable
  - [x] `accept_invite_race_test.dart`: two `Future.wait` accepts on one token produce exactly one membership
  - [x] `team_recipe_access_test.dart`: an editor can `get` and `save` a team recipe (instructions replaced in full); a viewer can `get` but `save` gives `forbidden` and `createUploadDescription` gives `forbidden`; an editor calling `delete` gets `forbidden`; a stranger calling `get` gets `notFound`
  - [x] `last_writer_wins_test.dart`: the editor saves `['a','b']`, the owner saves `['c']`, and `get` returns exactly `['c']` (US-4.6)
  - [x] `team_delete_test.dart`: deleting the team row sets `recipe.teamId` to null and the owner still reads the recipe
  - [x] `team_assignment_test.dart`:
    - [x] the owner, as an editor of the team, can `assignToTeam`; a viewer-member owner gets `forbidden`; a non-owner gets `notFound`
    - [x] `removeFromTeam` works for the owner and for a team editor; a viewer gets `forbidden`
    - [x] `listForTeam` by a non-member gives `notFound`
    - [x] `save` on insert with a `teamId` where the caller is a viewer gives `forbidden`
    - [x] an editor's update that sends a different `teamId` leaves the stored `teamId` unchanged
    - [x] a viewer calling `recipeMedia.remove` gets `forbidden`
- [x] Run the post-phase checklist, then `dart test`.



### 4.3 Flutter UI & State Management

- [x] `TeamRepository` (abstract plus fake): `create`, `listMine`, `createInvite`, `acceptInvite`. Extend `RecipeRepository` with `listForTeam`, `assignToTeam`, `removeFromTeam`.
- [x] Register the fake `TeamRepository` in `app_scope.dart`.
- [x] `lib/ui/features/teams/cubit/`: `TeamsCubit` with `load()`, `reset()`, `create(name)`, `createInvite(teamId, role, ttl)`, and state `teams`, `status`, `lastInvite`, `error`. Add it to `app_scope.dart` as a session-scoped Cubit (loads on `authenticated`, resets on `unauthenticated`), so the teams list, team detail, invite screen, and Brew Mode's "Add to team" picker share one list.
- [x] `lib/ui/features/invite/cubit/`: `InviteAcceptCubit` with `accept(token)` and state `status` (`accepting/success/failure`), `team`, `errorCode`.
- [x] Extend `RecipeCreationCubit`:
  - [x] `startNew({UuidValue? teamId})` stores `teamId`
  - [x] `save()` sends `teamId` only when `recipeId == null`
  - [x] `load` uses `access.canEdit`; the route shows Brew Mode instead of the wizard when it is false
- [x] `RecipeListCubit(teamId: ...)` calls `listForTeam` instead of `listMine`. The team instance is route-scoped on `/teams/:id`; the personal instance stays session-scoped.
- [x] Views:
  - [x] `teams_screen.dart` (`/teams`): a list of teams with role badges, a Create team dialog (name, 1..80), and a "Join with invite" dialog that accepts a pasted invite URL or bare token, takes the last path segment, and opens `/invite/:token`. This is how native mobile users join, since the app does not receive the HTTPS link.
  - [x] `team_detail_screen.dart` (`/teams/:id`): the team's recipes; a FAB that pushes `/recipes/new?teamId=` for editors only; an Invite button for the owner only. The caller's role comes from `TeamsCubit.state.teams`, and ownership from `team.ownerId == context.read<AuthRepository>().currentUserId`. Any push from this screen (wizard, Brew Mode) reloads the team list on return.
  - [x] `/recipes/new` reads `teamId` from the query string and calls `startNew(teamId: ...)`.
  - [x] `invite_sheet.dart`: role picker (Viewer/Editor), expiry picker (1h / 24h / 7d), Create, then the URL with a Copy button (`Clipboard.setData`) and a "Single use" note
  - [x] `invite_accept_screen.dart` (`/invite/:token`): a spinner while accepting; on success, "You joined  as " with an Open team button; on failure, a message by code
  - [x] Brew Mode app bar: "Add to team" (owner only, for a personal recipe, choosing from teams where they are an editor) and "Remove from team" (owner or team editor, for a team recipe)
  - [x] Hide Edit and every editing control in Brew Mode when `access.canEdit == false` (US-4.4)
  - [x] A bottom `NavigationBar` with My recipes and Teams
- [x] Router:
  - [x] Wrap `/` and `/teams` in a `StatefulShellRoute.indexedStack` with two branches, so the `NavigationBar` shows only on those two tabs and each tab keeps its scroll position.
  - [x] `/teams/:id` is a sub-route of the Teams branch. `/invite/:token` is a top-level route on the root navigator, with no tab bar.
  - [x] Give the Feature 3 recipe sub-routes (`recipes/new`, `recipes/:id`, `recipes/:id/edit`, `recipes/:id/share`) `parentNavigatorKey: rootNavigatorKey`. They then cover the tab bar, and pushing them from the Teams tab (for example `/recipes/new?teamId=`) does not switch the user to the My recipes tab.
  - [x] Confirm the auth redirect keeps `from=/invite/<token>`, so a signed-out user who opens the link signs in and then lands back on it.
- [x] Add `AuthRepository.currentUserId` (a `UuidValue?`) to the Feature 1 repository and its fake, for the ownership check above.
- [x] Cubit tests:
  - [x] `InviteAcceptCubit` maps each of `inviteExpired`, `inviteUsed`, `alreadyMember`, and `notFound` to failure with that code
  - [x] `TeamsCubit.create` appends the team with role `editor`
  - [x] `RecipeCreationCubit.save` sends `teamId` on insert and not on update
- [x] Run the post-phase checklist, then `hot_restart`.



### 4.4 Integration Layer

- [x] `ServerpodTeamRepository` on `client.team`; extend `ServerpodRecipeRepository` with the three team methods; implement `ServerpodAuthRepository.currentUserId` as `client.auth.authInfo?.authUserId`.
- [x] Register `ServerpodTeamRepository` in `app_scope.dart` in place of the fake.
- [x] Deep link on web. Invite URLs point at the web server (`http://localhost:8082` in development), which serves the app only after it has been built into `web/app`. Without a build, `:8082` shows the "build the Flutter app" page:
  - [x] Run `serverpod run flutter_build` in `brewing_journal_server/`, then `hot_restart` (MCP) so `FlutterRoute` is registered (it is added only when `web/app` exists at startup).
  - [ ] Open `http://localhost:8082/invite/abc` and confirm the app loads and routes to the invite screen with "Invite not found". If `FlutterRoute` does not serve `index.html` for that path, add a fallback in `lib/server.dart` that serves the app's `index.html` for `/invite/**`.
  - [x] For quick checks during development, the same path also works on the `flutter run` dev URL (`<dev-url>/invite/<token>`), because `go_router` uses path URLs.
- [x] Native mobile: the invite is an HTTPS URL that opens in the browser (web app), or the recipient pastes it into "Join with invite". App and Universal Links are out of scope; record this in `AGENTS.md`.
- [x] Error messages:
  - [x] Shared defaults in `errorMessage`:
    - [x] `inviteExpired`: "This invite has expired. Ask the team owner for a new one."
    - [x] `inviteUsed`: "This invite has already been used."
    - [x] `alreadyMember`: "You're already in this team."
  - [x] Invite screen overrides `notFound` with "Invite not found." For `alreadyMember`, it also shows the Open team button.
  - [x] Wizard and Brew Mode override `forbidden` with "Viewers can't change team recipes." when the recipe has a `teamId`, then call `getAccess` so the editing controls hide.
- [x] Loading states: invite creation disables the Create button; accept shows a full-screen spinner; `assignToTeam` shows an inline progress indicator.
- [x] After a successful accept, call `context.read<TeamsCubit>().load()` before Open team navigates to `/teams/:id`, so the new team and role are in state. After `assignToTeam` or `removeFromTeam`, call `context.read<RecipeListCubit>().load()` and `RecipeDetailCubit.load()`. If Brew Mode was opened from a team screen, that screen reloads its list when the push returns.
- [x] End-to-end check with two accounts (two browser profiles, or sign out and sign in):
  - [x] Owner creates the "Shop Recipes" team, adds a recipe, and creates a viewer invite.
  - [x] User B opens the link signed out, signs in, returns to the invite, joins as viewer, sees the recipe, and has no Edit button.
  - [x] User B opens the same link again: "You're already in this team" (the membership check runs before the claim).
  - [x] User C opens B's used link: "This invite has already been used", and C does not join.
  - [x] Owner creates an editor invite for user C. C edits the instructions, and the owner reloads to see C's list exactly.
- [x] Run the post-phase checklist, and check both log tails.

---



## Feature 5 — Social Sharing (Image generation & `share_plus`)

**Stories:** US-5.1 through US-5.3. No server calls: the card is rendered from the `RecipeDetail` already loaded in Brew Mode.

### 5.1 Backend Schemas & Database

- [x] No schema changes. The share card reads only `RecipeDetail` fields that already exist.
- [x] No migration. Run `create_migration` (MCP) once and confirm it reports no changes. MCP was not connected; CLI `serverpod create-migration` reported "Server migration skipped. No changes detected."



### 5.2 Backend API Endpoints

- [x] No new endpoints. Sharing writes nothing to the server and attaches no recipe link.
- [x] Add a server test to `team_recipe_access_test.dart` confirming a team viewer's `recipe.get` returns the full `RecipeDetail` (instructions, tags, scores), which is everything the card needs.
- [x] Run `dart test`. Server suite passed.



### 5.3 Flutter UI & State Management

- [x] Dependencies: `flutter pub add share_plus` (brings in `XFile` from `cross_file`; add `cross_file` explicitly if the analyzer asks for it).
- [x] `lib/ui/features/share/share_card_layout.dart`: pure functions, unit-tested:
  - [x] `visibleInstructions(List<String>)` returns `(rows, moreCount)`: 0 items gives `([], 0)`; 1..4 gives all rows and `0`; more than 4 gives the first 3 and `length - 3`
- [x] `lib/ui/features/share/view/recipe_share_card.dart`: `RecipeShareCard(RecipeDetail)`:
  - [x] Fixed `SizedBox(width: 360, height: 450)`, a `Column` with the content in `Expanded` + `ClipRect`, and a fixed 24px footer reading "Made with BrewSync", so content is cut above the footer
  - [x] Content: title, ingredient name and kind, method, dose, temperature, grind, grinder, duration (only when non-null), `FlavorRadarChart` (from Feature 2), and flavor tags
  - [x] Instruction rows with `maxLines: 2` and `TextOverflow.ellipsis`, plus a `+N more` line; the whole block is absent when there are no instructions (US-5.3)
  - [x] No network images
- [x] `lib/ui/features/share/cubit/`: `ShareCubit(ShareService)` with `status` (`idle/rendering/sharing/shared/unavailable/failure`) and `pngBytes`.
  - [x] `beginRender()` sets `rendering`. The view calls it on tap before capturing the `RepaintBoundary`, because capture needs the widget tree and cannot run in the Cubit.
  - [x] `share(Uint8List png, String title)` stores `pngBytes`, sets `sharing`, then: `dismissed` goes back to `idle` with no message; `unavailable` or an exception sets `unavailable`, which shows the download button
  - [x] `download()` calls `ShareService.saveToDownloads(pngBytes)`; a failure sets `failure`
- [x] `lib/data/services/share_service.dart`: abstract, plus a fake registered in `app_scope.dart`. The real one is added in 5.4.
- [x] `lib/ui/features/share/view/share_screen.dart` (`/recipes/:id/share`, a sub-route next to `recipes/:id`):
  - [x] Reads `RecipeDetail` from Brew Mode's `RecipeDetailCubit` (passed as `extra`, or loaded again by `id` on a web refresh)
  - [x] Preview: the card inside a `RepaintBoundary(key: _cardKey)`, scaled to fit with `FittedBox`
  - [x] A Share button that calls `ShareCubit.beginRender()`, then `await WidgetsBinding.instance.endOfFrame`, then `boundary.toImage(pixelRatio: 3)`, then `toByteData(format: png)`, then `ShareCubit.share`
  - [x] A "Download image" button, shown only in the `unavailable` state
- [x] Brew Mode: the Share action goes to `/recipes/:id/share` for anyone with read access, viewers included.
- [x] Tests:
  - [x] Unit: `visibleInstructions` for 0, 1, 4, 5, and 30 items
  - [x] Widget: no instructions means no instruction block; 6 instructions show 3 rows plus "+3 more"; a 280-character instruction does not overflow (no `RenderFlex` error); the footer is always found
  - [ ] Golden (optional): `matchesGoldenFile('goldens/share_card_v60.png')` for a sample recipe
  - [x] Cubit: `beginRender` goes to `rendering`; `dismissed` goes to `idle`; `unavailable` goes to `unavailable`; an exception goes to `unavailable`; a failed `download` goes to `failure`
- [x] Run the post-phase checklist, then `hot_restart`. Analyze, format, and `flutter test` (115) are clean. The running `serverpod start` hot reloaded; press R so the new `share_plus` plugin is registered. MCP `hot_restart` was not available.



### 5.4 Integration Layer

- [x] `SharePlusShareService implements ShareService`:
  - [x] `share(bytes, title)`: `SharePlus.instance.share(ShareParams(files: [XFile.fromData(bytes, mimeType: 'image/png', name: 'brewsync-recipe.png')], subject: title))`, returning `ShareResult.status`
  - [x] No `text` or `uri` parameter, so only the image is shared
  - [x] `saveToDownloads(bytes)`: `XFile.fromData(...).saveTo('brewsync-recipe.png')`, which triggers a browser download on web. On iOS and Android the share sheet is always available, so this fallback is expected only on web. On mobile, `saveTo` would need a real file path.
  - [x] iPad: pass `sharePositionOrigin` from the Share button's `RenderBox`, or the share sheet throws
- [x] Register `SharePlusShareService` in `app_scope.dart` in place of the fake.
- [x] Loading: `rendering` or `sharing` disables the Share button and shows a spinner.
- [x] Errors: `unavailable` shows "Sharing isn't supported here — download the image instead"; a failed download shows a snackbar with Retry.
- [ ] Platform checks:
  - [ ] Web (Chrome desktop, which has no file sharing): Share falls back to Download, and the downloaded PNG is 1080×1350
  - [ ] iOS or Android simulator: the share sheet opens with one PNG and no text
  - [ ] Team viewer account: Share is visible and works
- [x] Run the post-phase checklist, and check both log tails. Analyze, format, server tests, and Flutter tests are clean. `serverpod start` reloaded with no compile errors. MCP `tail_*_logs` was not available. The platform checks above still need a hot restart (press R) so `share_plus` is registered.

---



## Feature 6 — Favorites

**Stories:** US-6.1 through US-6.4, as first shipped. A favorite is a row per signed-in user and recipe, not a column on `recipe`. The home filter shows the caller's own favorite recipes. Feature 7 replaces the team-screen behavior from US-6.5: a heart on the team list becomes the team's favorite, and a viewer can no longer save a personal favorite from that screen.



### 6.1 Backend Schemas & Database

- [x] `lib/src/brewing/recipe.spy.yaml`: add `isFavorite: bool, default=false, !persist` after `updatedAt`. Reads fill it for the caller. It is not a database column.
- [x] `lib/src/brewing/recipe_favorite.spy.yaml`: `serverOnly: true` table `recipe_favorite`:
  - [x] `user` and `recipe` relations, both `onDelete=Cascade`
  - [x] `titleKey: String` — `title.trim().toLowerCase()`, the same folding as an ingredient `nameKey`
  - [x] `createdAt: DateTime, default=now`
  - [x] Unique indexes `recipe_favorite_user_recipe_idx` (`userId`, `recipeId`) and `recipe_favorite_user_title_idx` (`userId`, `titleKey`)
- [x] `lib/src/brewing/favorite_save_result.spy.yaml` (no table): `saved: bool` and `replacedRecipeId: UuidValue?`. `saved` false means another favorite already uses that title and nothing was written.
- [x] No reverse relation on `Recipe`. The client never sees `RecipeFavorite` rows.
- [x] Code generation ran from the watching `serverpod start`. Do not edit `lib/src/generated/` or `brewing_journal_client`.
- [x] Migration. MCP `create_migration` was not in the tool catalog, so the CLI wrote it: `serverpod create-migration --tag favorites` in `brewing_journal_server/`.
  - [x] Review `migrations/20261003044223103-favorites/migration.sql`: one `CREATE TABLE recipe_favorite`, the two unique indexes, and foreign keys `ON DELETE CASCADE` to `serverpod_auth_core_user` and `recipe`. No change to `recipe`.
  - [x] Applied through the running server's MCP `apply_migrations`, then `hot_restart`. The restart log says "Latest database migration already applied." `migrations/migration_registry.txt` lists `20261003044223103-favorites`.
- [x] Run the post-phase checklist. `dart analyze` in the server package is clean.



### 6.2 Backend API Endpoints

- [x] `lib/src/brewing/recipe_favorites.dart`:
  - [x] `recipeTitleKey`
  - [x] `withFavoriteFlags` loads the caller's rows for the recipe ids on the page and sets `isFavorite`. An empty page returns immediately.
  - [x] `saveRecipeFavorite` follows the system-design transaction: already saved returns `saved: true`; the same `titleKey` with `replace: false` returns `saved: false` and writes nothing; `replace: true` deletes the conflicting row and inserts the new one, setting `replacedRecipeId`. A `DatabaseUniqueViolationException` returns `saved: true` when this recipe is now the favorite, and `saved: false` otherwise.
  - [x] `removeRecipeFavorite` deletes the caller's row. A missing row is a no-op.
  - [x] Both methods call `RecipeAccessPolicy.load`. Read access is enough, so a viewer can favorite. No read access throws `notFound`.
- [x] `RecipeEndpoint`: `get`, `listMine`, `listForTeam`, `assignToTeam`, and `removeFromTeam` set `isFavorite` after author names. Add `listFavorites`, `saveFavorite`, and `removeFavorite`.
  - [x] `listFavorites(limit, offset)`: the caller's favorites among recipes they own (`ownerId = caller`), `orderBy updatedAt desc, id desc`, `limit` clamped to 1..50. An empty favorite set returns `[]` without a recipe query.
- [x] Server tests in `test/integration/brewing/recipe_favorite_test.dart` (9 tests, all passed):
  - [x] Saving a recipe sets `isFavorite` on `get` and `listMine`
  - [x] A second recipe titled `  v60 ` does not replace a favorite titled `V60` when `replace` is false
  - [x] `replace: true` swaps them, and `listFavorites` returns only the new one
  - [x] Different titles are both kept, newest `updatedAt` first
  - [x] `removeFavorite` clears the flag, and `listFavorites` is empty
  - [x] Two users can each favorite a recipe with the same title
  - [x] Saving a recipe the caller cannot read throws `BrewingErrorCode.notFound`
  - [x] A team viewer can favorite a shared recipe; only that viewer's `listForTeam` row has `isFavorite`, and their `listFavorites` is empty because they do not own it
  - [x] `listFavorites` honors `limit` and `offset`
- [x] Run the post-phase checklist, then `dart test` for `recipe_favorite_test.dart`.



### 6.3 Flutter UI & State Management

- [x] `RecipeRepository.listMine` takes `favoritesOnly`. Add `saveFavorite(id, {replace})` and `removeFavorite(id)`. The fake applies the same title-key rule as the server.
- [x] `RecipeListCubit` / `RecipeListState`:
  - [x] `favoritesOnly` and `favoriteBusyIds`
  - [x] `setFavoritesOnly` clears the loaded page and reloads
  - [x] `saveFavorite` applies the flag only when `saved` is true, and clears `isFavorite` on `replacedRecipeId`
  - [x] `removeFavorite`
  - [x] `noteFavorite` updates rows already in memory. While the filter is on, unfavoriting drops the row, and favoriting a recipe that is not in the loaded page reloads
- [x] `RecipeDetailCubit`: `saveFavorite({replace})`, `removeFavorite`, and `favoriteBusy`. A blocked save leaves the loaded recipe unchanged.
- [x] `lib/ui/core/widgets/favorite_icon_button.dart`: an `IconButton.isSelected` heart (`Icons.favorite` / `Icons.favorite_border`). Tooltips come from `addToFavorites` and `removeFromFavorites`, unless the caller passes one.
- [x] `lib/ui/features/recipe_list/view/replace_favorite_dialog.dart`: title "Already in favorites", body "A recipe with this name is already in your favorites. Replace it with this one?" Close (`favorite-conflict-close`) and Cancel (`favorite-conflict-cancel`) pop false. Accept (`favorite-conflict-accept`) pops true.
- [x] `lib/ui/features/recipe_list/favorite_actions.dart`: `toggleRecipeFavorite` coordinates the save, the dialog, an optional `onChanged` for the other list cubit, and the error snackbar.
- [x] `RecipeTile`: trailing heart with `ValueKey('recipe-favorite-${id}')`, then the chevron. The heart does not open the recipe.
- [x] Home `RecipeListScreen` app bar: heart with `Key('recipe-list-favorites')`. On calls `setFavoritesOnly(true)` and the empty state uses `noFavoriteRecipes` / `noFavoriteRecipesDetail`. Off shows every recipe the user owns. The team list has no filter.
- [x] Brew Mode app bar: the favorite heart (`Key('brew-favorite')`) is the first action. It calls the detail cubit, then `noteFavorite` on the session `RecipeListCubit`.
- [x] `TeamDetailScreen` captures the session `RecipeListCubit` above its nested provider and calls `noteFavorite` after the team cubit writes. Returning from Brew Mode still reloads the team list.
- [x] Localization in `app_en.arb`, `app_es.arb`, `app_es_419.arb`, `app_pt.arb`, and `app_pt_BR.arb`: `accept`, `addToFavorites`, `removeFromFavorites`, `showFavorites`, `showAllRecipes`, `favoriteNameTakenTitle`, `favoriteNameTakenBody`, `noFavoriteRecipes`, `noFavoriteRecipesDetail`. Then `flutter gen-l10n`.
- [x] Tests:
  - [x] `recipe_list_cubit_test.dart`: the filter reloads through `listMine(favoritesOnly: true)`; a same-name save is blocked until `replace: true`; `noteFavorite` updates the home rows
  - [x] `recipe_list_screen_test.dart`: the app-bar heart shows only favorites; Accept replaces; Cancel leaves the existing favorite
  - [x] `recipe_tile_test.dart`: the heart toggles and does not open the recipe
  - [x] `replace_favorite_dialog_test.dart`: close, Cancel, and Accept
  - [x] `recipe_detail_cubit_test.dart`: save, a blocked same-name save, and replace
  - [x] `brew_mode_screen_test.dart`: the `brew-favorite` heart is present
  - [x] `team_detail_screen_test.dart`: the screen is wrapped in a parent `RecipeListCubit`, because `build` reads that cubit before creating the team one
- [x] Run the post-phase checklist, then `hot_restart`. `dart analyze` and `flutter test` for the files above are clean.



### 6.4 Integration Layer

- [x] `ServerpodRecipeRepository.listMine`: `favoritesOnly` calls `client.recipe.listFavorites(limit, offset)`; otherwise `listMine`. `saveFavorite(id, replace)` and `removeFavorite(id)` are positional client calls.
- [x] The existing `ServerpodRecipeRepository` in `app_scope.dart` already wraps `client.recipe`, so these methods need no extra registration.
- [x] A failed save or remove uses the existing `errorMessage` snackbar. `favoriteBusy` / `favoriteBusyIds` disable that heart while the request is in flight.
- [x] End-to-end check (`integration_test/favorites_test.dart`, `flutter test integration_test/favorites_test.dart -d macos` against `serverpod start`):
  - [x] Save two recipes with the same name, star the first from the tile, and confirm the second opens the dialog. Close leaves the first heart filled.
  - [x] Cancel leaves the first heart filled. Accept fills the second and clears the first.
  - [x] The home app-bar heart shows only the winning recipe, and turning it off shows both. With nothing starred, it shows "No favorite recipes".
  - [x] The Brew Mode heart removes and adds that same recipe, and the journal tile follows.
  - [x] A team viewer sees the team's filled heart and cannot change it. The owner's team list shows that same heart, and the viewer's home filter stays empty. Feature 7 replaced the older case where the viewer starred a personal favorite from the team list.
- [x] Run the post-phase checklist for the code that landed. Server `recipe_favorite_test.dart` passed, and the Flutter tests listed in 6.3 passed. `favorites_test.dart` passed (2). `dart analyze` is clean in the server and Flutter packages.

---



## Feature 7 — Team favorites

**Stories:** US-6.5 through US-6.9. Depends on Feature 4 (teams and editor vs viewer) and Feature 6 (personal favorites, the heart, and the replace dialog). A team favorite is a row in `team_recipe_favorite`, separate from `recipe_favorite`. Hearts on the Team detail screen and in Brew Mode opened from that screen write the team's list. Only an editor membership can add or remove one. `canEdit` is not the check, because a recipe owner who is a viewer still has `canEdit`.

Do Feature 7.1 before 7.2, then 7.3, then 7.4.



### 7.1 Backend Schemas & Database

- [x] `lib/src/brewing/team_recipe_favorite.spy.yaml`: `serverOnly: true` table `team_recipe_favorite`:
  - [x] `team: Team?` and `recipe: Recipe?`, both `relation(onDelete=Cascade)`
  - [x] `titleKey: String` — `title.trim().toLowerCase()`, the same folding as `recipe_favorite.titleKey`
  - [x] `createdAt: DateTime, default=now`
  - [x] Unique indexes `team_recipe_favorite_team_recipe_idx` (`teamId`, `recipeId`) and `team_recipe_favorite_team_title_idx` (`teamId`, `titleKey`)
- [x] No reverse relation on `Team` or `Recipe`. Leave `recipe_favorite.spy.yaml` and `Recipe.isFavorite` as they are. Reuse `FavoriteSaveResult`.
- [x] Let `serverpod start` generate. Do not edit `lib/src/generated/` or `brewing_journal_client`.
- [x] Migration: `create_migration` with tag `team-favorites` (MCP, or `serverpod create-migration --tag team-favorites` if the MCP tool is not connected).
  - [x] Review `migration.sql`: one `CREATE TABLE team_recipe_favorite`, the two unique indexes, and foreign keys `ON DELETE CASCADE` to `team` and `recipe`. No change to `recipe` or `recipe_favorite`. Do not copy existing personal rows onto the team.
  - [x] `apply_migrations`, then `hot_restart`. Confirm `migrations/migration_registry.txt` lists the new migration.
- [x] Run the post-phase checklist. `dart analyze` in the server package is clean.



### 7.2 Backend API Endpoints

- [x] `lib/src/brewing/team_recipe_favorites.dart`, using `membershipOf` from `lib/src/teams/team_membership_lookup.dart`:
  - [x] `withTeamFavoriteFlags(session, teamId, recipes)` sets `isFavorite` from `team_recipe_favorite` for that team. An empty page returns immediately.
  - [x] `saveTeamRecipeFavorite(session, teamId, recipeId, replace)` follows the system-design transaction. No read access, a missing membership, or `recipe.teamId != teamId` throws `notFound`. A membership other than `editor` throws `forbidden`, including a viewer who owns the recipe. Already saved returns `saved: true`. The same `titleKey` with `replace: false` returns `saved: false` and writes nothing. `replace: true` deletes the conflicting team row and inserts the new one, setting `replacedRecipeId`. A `DatabaseUniqueViolationException` returns `saved: true` when this recipe is now the team's favorite, and `saved: false` otherwise. The transaction does not read or write `recipe_favorite`.
  - [x] `removeTeamRecipeFavorite` uses the same checks and deletes the team's row. A missing row is a no-op.
- [x] `RecipeEndpoint`:
  - [x] `listForTeam` fills `isFavorite` through `withTeamFavoriteFlags`, so every member sees the same hearts. It no longer fills the caller's personal flag.
  - [x] `listTeamFavorites(teamId, limit, offset)`: membership required (viewer or editor). Recipes with `recipe.teamId == teamId` and a `team_recipe_favorite` row for that team, `orderBy updatedAt desc, id desc`, `limit` clamped to 1..50. An empty set returns `[]` without a recipe query.
  - [x] `saveTeamFavorite(teamId, recipeId, replace)` and `removeTeamFavorite(teamId, recipeId)`.
  - [x] `get(id, {UuidValue? teamId})` adds an optional named argument, so existing `get(id)` calls and `save`'s return value stay personal. A set `teamId` requires membership and `recipe.teamId == teamId` (else `notFound`) and fills `isFavorite` from the team's rows. Viewers can still read. A non-member gets `notFound` from `listForTeam` and `listTeamFavorites` too.
  - [x] `assignToTeam` and `removeFromTeam` delete every `team_recipe_favorite` row for that recipe in the same transaction that changes `recipe.teamId`. The returned `isFavorite` stays the caller's personal flag. Personal `saveFavorite` / `removeFavorite` stay unchanged.
- [x] Server tests in `test/integration/brewing/recipe_team_favorite_test.dart`:
  - [x] An editor's `saveTeamFavorite` sets `isFavorite` on `listForTeam` for the editor and for a viewer, and the viewer's `listFavorites` stays empty
  - [x] The editor's personal `listMine` / `listFavorites` stay unchanged, and a personal `saveFavorite` of the same recipe does not fill the team heart
  - [x] A second team recipe titled `  v60 ` does not replace a team favorite titled `V60` when `replace` is false; `replace: true` swaps them and `listTeamFavorites` returns only the new one
  - [x] A different title can be a second team favorite. Another team's favorite with the same title is kept. Two members' personal favorites of that title are kept
  - [x] `removeTeamFavorite` clears the flag for every member, and a second remove is a no-op
  - [x] A viewer gets `BrewingErrorCode.forbidden` from `saveTeamFavorite` and `removeTeamFavorite`. Also seed an owner whose `team_membership.role` is `viewer` (the invite API never demotes an editor) and expect `forbidden` even though `canEdit` is true. `removeFromTeam` by that owner still succeeds and deletes the team favorite.
  - [x] A non-member, a recipe on another team, and a personal recipe get `notFound`
  - [x] `listTeamFavorites` honors `limit` and `offset`. `removeFromTeam` drops the recipe from that list and leaves a personal favorite in place. `assignToTeam` of a personally favorited recipe leaves the team heart empty and the personal heart filled.
  - [x] Saving a new version of a team favorite leaves the source row starred. `saveTeamFavorite` of the new row, same title, returns `saved: false` until `replace: true`.
  - [x] Deleting the team row cascades `team_recipe_favorite`, sets `recipe.teamId` null, and leaves a personal favorite in place.
  - [x] `get(id, teamId: teamId)` reports the team flag; `get(id)` for the owner still reports the personal flag
- [x] Update `recipe_favorite_test.dart`: the case that lets a viewer save a personal favorite and then expects that flag on `listForTeam` now expects the team flag to stay false. The viewer's personal row can still exist if they save through `saveFavorite` directly.
- [x] Run the post-phase checklist, then `dart test` for `recipe_team_favorite_test.dart` and `recipe_favorite_test.dart`.



### 7.3 Flutter UI & State Management

- [x] `RecipeRepository`: `listForTeam` stays. Add `listTeamFavorites(teamId, limit, offset)`, `saveTeamFavorite(teamId, id, {replace})`, and `removeTeamFavorite(teamId, id)`. `get` takes an optional `teamId`. The fake keeps a team title-key map separate from the personal one, and rejects a non-editor team write.
- [x] `RecipeListCubit` for a `teamId`:
  - [x] `setFavoritesOnly(true)` reloads through `listTeamFavorites`; `false` reloads through `listForTeam`
  - [x] `saveFavorite` / `removeFavorite` call the team repository methods and pass `teamId`
  - [x] `noteFavorite` still updates only that cubit's rows
- [x] The home `RecipeListCubit` (`teamId` null) keeps calling `listMine`, `listFavorites`, `saveFavorite`, and `removeFavorite`.
- [x] `RecipeDetailCubit` takes an optional `teamId`. Set: `get(id, teamId)`, `saveTeamFavorite`, `removeTeamFavorite`. Unset: today's personal calls. A blocked team save leaves the loaded recipe unchanged.
- [x] `RecipeTile` gains `favoriteEnabled`. When false, the heart keeps `isSelected` and its `onPressed` is null. Tooltip for a disabled team heart: viewers can't change team favorites.
- [x] `ReplaceFavoriteDialog` takes the team copy when the save is a team save. Title and body say the name is already in the team's favorites. Keys stay `favorite-conflict-close`, `favorite-conflict-cancel`, and `favorite-conflict-accept`.
- [x] `TeamDetailScreen`:
  - [x] App-bar heart `Key('team-list-favorites')`, shown to viewers and editors. On uses the empty team-favorites copy. Off shows every recipe on the team. An unfiltered empty team still uses `noRecipesOnTeam`.
  - [x] Tile hearts call the team cubit only. Remove the `personalList` capture and the `noteFavorite` call, so `build` no longer reads the session cubit. Hearts stay disabled until the team summary has loaded, and stay disabled unless `role == editor`. The team owner is an editor.
  - [x] Opening a recipe pushes `/recipes/:id?teamId=<uuid>` (`Routes.recipe(id, teamId: teamId)`).
- [x] Brew Mode reads `teamId` from that query. With it, the heart writes the team favorite and does not call `noteFavorite` on the session `RecipeListCubit`. The heart is disabled when `access.role != editor`, including when `canEdit` is true. Without the query, the heart stays personal and still updates the home cubit. Returning from Brew Mode still reloads the team list.
- [x] After the wizard saves a team recipe, `pushReplacement` keeps `teamId` on the Brew Mode route. `assignToTeam` reloads Brew Mode with that team's query. `removeFromTeam` drops the query and reloads the personal heart.
- [x] Localization in `app_en.arb`, `app_es.arb`, `app_es_419.arb`, `app_pt.arb`, and `app_pt_BR.arb`: `showTeamFavorites`, `showAllTeamRecipes`, `favoriteNameTakenTitleTeam`, `favoriteNameTakenBodyTeam`, `noTeamFavoriteRecipes`, `noTeamFavoriteRecipesDetail`, `viewersCantChangeTeamFavorites`. Then `flutter gen-l10n`.
- [x] Tests:
  - [x] `recipe_list_cubit_test.dart`: a team cubit's filter calls `listTeamFavorites`; a team save does not change the fake's personal favorites; a personal save does not change the team flag
  - [x] Team screen widget test: the app-bar heart shows only team favorites; an editor's Accept replaces the team favorite; Cancel leaves it; a viewer heart does not open the dialog
  - [x] `recipe_detail_cubit_test.dart`: with `teamId`, save and replace call the team methods and leave personal favorites untouched; a viewer-shaped fake failure leaves the recipe unchanged
  - [x] `brew_mode_screen_test.dart`: with `teamId`, the heart is present; with `access.role == viewer` and `canEdit == true`, the heart is disabled
  - [x] `team_detail_screen_test.dart`: the screen builds without a parent `RecipeListCubit`, a viewer heart does not call save, and an editor heart does not require the home cubit
- [x] Run the post-phase checklist, then `hot_restart`.



### 7.4 Integration Layer

- [x] `ServerpodRecipeRepository` passes `teamId` through to `client.recipe.listTeamFavorites`, `saveTeamFavorite`, `removeTeamFavorite`, and `get`. Personal methods stay positional and omit `teamId`.
- [x] The existing repository registration in `app_scope.dart` picks up the new methods.
- [x] A failed team save or remove uses the existing snackbar. Map `forbidden` on these actions to "Viewers can't change team favorites." `favoriteBusy` / `favoriteBusyIds` disable that heart while the request is in flight.
- [x] Update `integration_test/favorites_test.dart` and extend `integration_test/support/recipe_harness.dart`. The old viewer case starred a personal favorite from the team list; replace it with the team list:
  - [x] An editor saves two team recipes with the same name, stars the first from the team tile, and the second opens the team dialog. Close and Cancel leave the first heart filled. Accept fills the second and clears the first.
  - [x] The team app-bar heart shows only the winning recipe. Turning it off shows both. With nothing starred, it shows the empty team-favorites message.
  - [x] Brew Mode opened from the team list removes and adds that team favorite, and the team tile follows. The editor's home filter does not list it.
  - [x] A viewer sees the filled team heart, the heart does not accept a tap, and the viewer's home filter stays empty. The owner's team list shows the same filled heart.
  - [x] The editor stars a recipe from My recipes. The team heart stays empty. Removing that recipe from the team clears the team favorite and leaves the personal one on My recipes.
- [x] Run `flutter test integration_test/favorites_test.dart -d macos` while `serverpod start` is up.
- [x] Run the post-phase checklist. `dart analyze` is clean in the server and Flutter packages, and the server tests from 7.2 pass.

---



## Wrap-up

- [ ] Full regression with `flutter_driver`: sign up, create a recipe (all 5 steps), open Brew Mode and let the timer finish, star that recipe, create a team and invite a viewer, accept as a second user, have an editor star a team recipe, confirm the viewer can see that heart and cannot change it, share from the viewer account.
- [ ] `dart test` in `brewing_journal_server/` and `flutter test` in `brewing_journal_flutter/` both pass.
- [ ] `dart analyze` is clean in all three packages; run `dart format .`.
- [ ] Confirm `migrations/migration_registry.txt` lists: initial, `recipes`, `teams`, `favorites`, `team-favorites`. `create_migration` reports no pending changes.
- [ ] Update `AGENTS.md` with a description of BrewSync (features, folder layout, `RecipeAccessPolicy`, the invite URL format, and the known limit that invites open in the web app). Keep the MCP section and the checklist, and remove the "After building the first version…" paragraph.
- [ ] Set `enableTextEntryEmulation` in `lib/driver.dart` back to `false`.