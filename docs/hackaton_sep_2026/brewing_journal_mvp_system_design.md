# BrewSync MVP — Technical Architecture and Data Schema

**Stack:** Flutter + `flutter_bloc` Cubits, Serverpod 4.0.2, PostgreSQL, `serverpod_auth_idp` email JWT, `public` cloud storage (`ServerpodCloudProvider.public`, local fallback `DatabaseCloudStorage('public')`).

**Boundaries**

- Auth stays on `serverpod_auth_idp`. Domain endpoints set `requireLogin => true` and read `session.authenticated!.authUserId` (`UuidValue`). Account scopes are unused. Viewer vs editor is a row in `team_membership`, checked inside the method.
- Timers, alarms, and share-card rendering run only in the Flutter app; nothing about them is sent to Serverpod. The server stores `extractionDuration` only. The share image leaves the device only through the OS share sheet or a download.
- A recipe is owned by one `AuthUser`. `teamId` is null (personal) or one workspace. Adding an existing recipe sets `teamId`. Deleting the team nulls `teamId`; the recipe remains with the owner.
- A favorite is one row per user and recipe, not a column on `recipe`. `titleKey` is the trimmed lower-case title, and a user may have only one favorite per `titleKey`. Saving a second recipe with that name writes nothing until the caller passes `replace: true`, which deletes the previous row in the same transaction. Deleting the recipe or the account cascades the favorite away. `Recipe.isFavorite` is filled on read for the caller and is not stored. A new version is a new recipe row, so a stored `titleKey` does not drift from later edits.
- Extra instructions are child rows. A save deletes the previous rows for that recipe and inserts the submitted list in order. Empty-after-trim is rejected. Duplicate text is allowed. Max length is 280 characters after trim (`kInstructionMaxLength`), enforced by the server and mirrored in the wizard.
- Photos are rows written only after `session.storage.verifyUpload` on storage id `public`. The client never chooses the storage path. Public storage means a photo URL is readable by anyone holding it; paths contain a random UUID so they are not enumerable.
- Team invite links are HTTPS URLs on the Serverpod web server (`<webBaseUrl>/invite/<token>`), served by the Flutter web app through the existing `FlutterRoute` at `/`. Recipe sharing carries no link; only the image is shared. Custom schemes are not used because Flutter web cannot receive them. `webBaseUrl` is built on the server from `pod.config.webServer` (`publicScheme://publicHost:publicPort`).

Protocol files live under `brewing_journal_server/lib/src/`. Generated client code is not edited.

---

## 1. Serverpod Database Schemas (`.spy.yaml`)

Every table declares `id: UuidValue?, defaultPersist=random_v7`. Endpoints, DTOs, and links all pass `UuidValue` ids, and relations to these tables get `UuidValue` foreign keys. Without the explicit `id`, Serverpod would generate `int` serial ids and the contracts below would not match.

Foreign keys to the signed-in account use `module:serverpod_auth_core:AuthUser` (no nickname is set in `config/generator.yaml`). An object field named `owner` generates the `ownerId` (`UuidValue`) column; the index definitions below refer to those generated names.

`updatedAt` has `default=now` for inserts only. The endpoint sets `updatedAt = DateTime.now().toUtc()` on every update.

### `lib/src/brewing/beverage_kind.spy.yaml`

```yaml
enum: BeverageKind
serialized: byName
values:
  - coffee
  - tea
  - matcha
```

### `lib/src/brewing/roast_level.spy.yaml`

```yaml
enum: RoastLevel
serialized: byName
values:
  - light
  - medium
  - mediumDark
  - dark
```

### `lib/src/brewing/extraction_method.spy.yaml`

```yaml
enum: ExtractionMethod
serialized: byName
values:
  - v60
  - espresso
  - frenchPress
  - aeropress
  - chemex
  - coldBrew
  - matchaWhisk
  - other
```

### `lib/src/teams/team_role.spy.yaml`

```yaml
enum: TeamRole
serialized: byName
values:
  - viewer
  - editor
```

### `lib/src/brewing/brewing_exception.spy.yaml`

```yaml
exception: BrewingException
fields:
  code: BrewingErrorCode
  message: String
```

### `lib/src/brewing/brewing_error_code.spy.yaml`

```yaml
enum: BrewingErrorCode
serialized: byName
values:
  - notFound
  - forbidden
  - validation
  - inviteExpired
  - inviteUsed
  - alreadyMember
  - uploadRejected
```

`requireLogin` rejects unsigned calls before the method runs, so there is no `unauthenticated` code. `notFound` covers both a missing row and a row the caller cannot see, so ids of other users’ recipes are not confirmed. `forbidden` is used when the caller can read but not write (a viewer calling `save`, or a non-owner calling `createInvite`).

### `lib/src/brewing/ingredient.spy.yaml`

Search is `kind` + case-folded `name`. Origin, roaster, roast, and processing are attributes of the ingredient, not the brew.

```yaml
class: Ingredient
table: ingredient
fields:
  id: UuidValue?, defaultPersist=random_v7
  owner: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)
  kind: BeverageKind
  name: String
  nameKey: String
  origin: String?
  roaster: String?
  roastLevel: RoastLevel?
  processing: String?
  createdAt: DateTime, default=now

indexes:
  ingredient_owner_kind_name_idx:
    fields: ownerId, kind, nameKey
```

`nameKey` is `name.trim().toLowerCase()`, written only by the endpoint. Every lookup is scoped to `ownerId` + `kind`, so a standalone `nameKey` index would never be used. The prefix match (`nameKey LIKE 'q%'`) filters inside that owner/kind range; a single user’s ingredient list is small enough that this does not need a `text_pattern_ops` index.

### `lib/src/brewing/recipe.spy.yaml`

Flavor axes are integers `0..5` (Acidity, Sweetness, Body, Bitterness), validated in the endpoint. Tags are rows so a recipe can be filtered by tag without scanning a JSON list. `extractionDuration` is null when the user did not run the stopwatch.

```yaml
class: Recipe
table: recipe
fields:
  id: UuidValue?, defaultPersist=random_v7
  owner: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)
  team: Team?, relation(name=team_recipes, optional, onDelete=SetNull)
  ingredient: Ingredient?, relation(onDelete=NoAction)
  title: String
  waterTempC: double
  doseGrams: double
  grindSize: String
  grinderModel: String
  extractionMethod: ExtractionMethod
  extractionMethodNote: String?
  extractionDuration: Duration?
  acidity: int
  sweetness: int
  body: int
  bitterness: int
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
  ### Whether the caller has saved this recipe to favorites. Not stored.
  isFavorite: bool, default=false, !persist
  instructions: List<RecipeInstruction>?, relation(name=recipe_instructions)
  photos: List<RecipePhoto>?, relation(name=recipe_photos)
  flavorTags: List<RecipeFlavorTag>?, relation(name=recipe_flavor_tags)

indexes:
  recipe_owner_updated_idx:
    fields: ownerId, updatedAt
  recipe_team_updated_idx:
    fields: teamId, updatedAt
  recipe_ingredient_idx:
    fields: ingredientId
```

`onDelete=NoAction` on `ingredient` blocks deleting a bean that still has recipes. It is `NoAction` rather than `Restrict` because deleting an account cascades to both that user’s ingredients and recipes in one statement. `Restrict` is checked immediately and would fail partway through; `NoAction` is checked at the end of the statement, after the recipes are gone. Team delete uses `SetNull` so shared recipes fall back to the owner. `recipe_ingredient_idx` backs that foreign-key check.

The instruction, photo, and tag list fields on `Recipe` are left null in responses. `RecipeDetail` carries them as separate ordered lists. `isFavorite` defaults to false and is set by the endpoint for the caller on `get`, `listMine`, `listForTeam`, `listFavorites`, `assignToTeam`, and `removeFromTeam`.

### `lib/src/brewing/recipe_favorite.spy.yaml`

`serverOnly: true`, so the client never receives favorite rows. The client sees `Recipe.isFavorite` and `FavoriteSaveResult`.

```yaml
class: RecipeFavorite
table: recipe_favorite
serverOnly: true
fields:
  id: UuidValue?, defaultPersist=random_v7
  user: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)
  recipe: Recipe?, relation(onDelete=Cascade)
  ### Trimmed, lower-case title. One favorite per user per title.
  titleKey: String
  createdAt: DateTime, default=now

indexes:
  recipe_favorite_user_recipe_idx:
    fields: userId, recipeId
    unique: true
  recipe_favorite_user_title_idx:
    fields: userId, titleKey
    unique: true
```

`titleKey` is `title.trim().toLowerCase()`, the same folding as an ingredient `nameKey`. The unique `(userId, recipeId)` index makes a second save of the same recipe a no-op. The unique `(userId, titleKey)` index is what keeps a single winning version per name. Both foreign keys cascade, so deleting the account or the recipe removes the favorite.

### `lib/src/brewing/recipe_instruction.spy.yaml`

```yaml
class: RecipeInstruction
table: recipe_instruction
fields:
  id: UuidValue?, defaultPersist=random_v7
  recipe: Recipe?, relation(name=recipe_instructions, onDelete=Cascade)
  sortOrder: int
  text: String

indexes:
  recipe_instruction_order_idx:
    fields: recipeId, sortOrder
    unique: true
```

List reads: `where recipeId = ? orderBy sortOrder`. Replace-on-save is one transaction: delete by `recipeId`, insert `0..n-1`.

### `lib/src/brewing/recipe_flavor_tag.spy.yaml`

```yaml
class: RecipeFlavorTag
table: recipe_flavor_tag
fields:
  id: UuidValue?, defaultPersist=random_v7
  recipe: Recipe?, relation(name=recipe_flavor_tags, onDelete=Cascade)
  tag: String
  tagKey: String

indexes:
  recipe_flavor_tag_recipe_idx:
    fields: recipeId, tagKey
    unique: true
  recipe_flavor_tag_key_idx:
    fields: tagKey
```

`tagKey` is trimmed lower-case. A tag is 1..40 characters after trim, with at most 12 tags per recipe. Uniqueness is per recipe, so the same tag can appear on many recipes. `recipe_flavor_tag_key_idx` is there for a later tag filter; no MVP endpoint uses it yet.

### `lib/src/brewing/recipe_photo.spy.yaml`

```yaml
class: RecipePhoto
table: recipe_photo
fields:
  id: UuidValue?, defaultPersist=random_v7
  recipe: Recipe?, relation(name=recipe_photos, onDelete=Cascade)
  storagePath: String
  sortOrder: int
  createdAt: DateTime, default=now
  publicUrl: Uri?, !persist

indexes:
  recipe_photo_order_idx:
    fields: recipeId, sortOrder
    unique: true
  recipe_photo_path_idx:
    fields: storagePath
    unique: true
```

`publicUrl` is not stored. The endpoint fills it from `session.storage.publicDownloadUrl(storageId: 'public', path: storagePath)` on every read, so the client can render photos without a second call.

### `lib/src/teams/team.spy.yaml`

```yaml
class: Team
table: team
fields:
  id: UuidValue?, defaultPersist=random_v7
  owner: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)
  name: String
  createdAt: DateTime, default=now
  memberships: List<TeamMembership>?, relation(name=team_memberships)
  invites: List<TeamInvite>?, relation(name=team_invites)
  recipes: List<Recipe>?, relation(name=team_recipes)

indexes:
  team_owner_idx:
    fields: ownerId
```

Creating a team also inserts a `TeamMembership` for the creator with `role: editor`. The team owner is `team.ownerId`, and only the owner can create invites. This matches the PRD rule that the team creator assigns the role. Without it, an editor could mint editor invites.

### `lib/src/teams/team_membership.spy.yaml`

```yaml
class: TeamMembership
table: team_membership
fields:
  id: UuidValue?, defaultPersist=random_v7
  team: Team?, relation(name=team_memberships, onDelete=Cascade)
  member: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)
  role: TeamRole
  createdAt: DateTime, default=now

indexes:
  team_membership_team_member_idx:
    fields: teamId, memberId
    unique: true
  team_membership_member_idx:
    fields: memberId
```

A role check for one team uses the unique `(teamId, memberId)` index. `team.listMine` uses `team_membership_member_idx`. One membership per user per team.

### `lib/src/teams/team_invite.spy.yaml`

```yaml
class: TeamInvite
table: team_invite
fields:
  id: UuidValue?, defaultPersist=random_v7
  team: Team?, relation(name=team_invites, onDelete=Cascade)
  createdBy: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)
  token: String
  role: TeamRole
  expiresAt: DateTime
  usedAt: DateTime?
  usedBy: module:serverpod_auth_core:AuthUser?, relation(optional, onDelete=SetNull)
  createdAt: DateTime, default=now

indexes:
  team_invite_token_idx:
    fields: token
    unique: true
  team_invite_team_idx:
    fields: teamId, expiresAt
```

Accept runs in one transaction with a conditional update: `UPDATE team_invite SET usedAt = now, usedById = caller WHERE token = ? AND usedAt IS NULL AND expiresAt > now`. One affected row means the invite was claimed, so membership is inserted. Zero rows means the invite is re-read to choose `inviteUsed` or `inviteExpired`, and nothing is written. Two concurrent accepts cannot both claim the token.

If the caller is already a member, the method throws `alreadyMember` before claiming and does not consume the invite. An existing editor who opens a viewer link is therefore never demoted, and the link still works for the intended recipient.

### Protocol DTOs (no `table`)

`lib/src/brewing/recipe_draft.spy.yaml` — wizard payload. Instructions are ordered strings; the server assigns `sortOrder`.

```yaml
class: RecipeDraft
fields:
  id: UuidValue?
  teamId: UuidValue?
  ingredientId: UuidValue
  title: String
  waterTempC: double
  doseGrams: double
  grindSize: String
  grinderModel: String
  extractionMethod: ExtractionMethod
  extractionMethodNote: String?
  extractionDuration: Duration?
  acidity: int
  sweetness: int
  body: int
  bitterness: int
  flavorTags: List<String>
  instructions: List<String>
```

`id` null inserts. Non-null updates that row and replaces instructions and tags in full. Photos are not on the draft. `teamId` is read only on insert. On update it is ignored, and team membership changes only through `assignToTeam` / `removeFromTeam`, so a team editor cannot move another owner’s recipe with a save.

`lib/src/brewing/ingredient_draft.spy.yaml`

```yaml
class: IngredientDraft
fields:
  kind: BeverageKind
  name: String
  origin: String?
  roaster: String?
  roastLevel: RoastLevel?
  processing: String?
```

`lib/src/brewing/recipe_detail.spy.yaml`

```yaml
class: RecipeDetail
fields:
  recipe: Recipe
  ingredient: Ingredient
  instructions: List<RecipeInstruction>
  flavorTags: List<RecipeFlavorTag>
  photos: List<RecipePhoto>
  access: RecipeAccess
```

`lib/src/brewing/recipe_access.spy.yaml`

```yaml
class: RecipeAccess
fields:
  role: TeamRole?
  canEdit: bool
  canDelete: bool
```

`role` is the caller’s team role, or null for a personal recipe or an owner who is not a team member. `canEdit = isOwner || role == editor`. `canDelete = isOwner`.

`lib/src/brewing/upload_ticket.spy.yaml`

```yaml
class: UploadTicket
fields:
  path: String
  description: String
```

`lib/src/teams/invite_link.spy.yaml`

```yaml
class: InviteLink
fields:
  token: String
  role: TeamRole
  expiresAt: DateTime
  url: String
```

`url` is `<webBaseUrl>/invite/<token>`. The Flutter router maps `/invite/:token` to a screen that signs the user in if needed, then calls `team.acceptInvite(token)`.

`lib/src/brewing/favorite_save_result.spy.yaml` — the result of `saveFavorite`. `saved` false means another favorite already uses that title and nothing was written. `replacedRecipeId` is set only when `replace` removed the previous favorite.

```yaml
class: FavoriteSaveResult
fields:
  saved: bool
  replacedRecipeId: UuidValue?
```

`lib/src/teams/team_summary.spy.yaml`

```yaml
class: TeamSummary
fields:
  team: Team
  role: TeamRole
```

---

## 2. Backend API Endpoints (Serverpod)

All classes extend `Endpoint`, `requireLogin => true`. Failures throw `BrewingException`. `Session` is the first parameter and is omitted from the client signature.

Authorization used by every recipe read/write:

| Caller | Personal recipe (`teamId == null`) | Team recipe |
| --- | --- | --- |
| Owner | read, update, delete | read, update, delete |
| Team editor (not owner) | `notFound` | read, update (instructions replaced in full) |
| Team viewer (not owner) | `notFound` | read; writes → `forbidden` |
| Anyone else | `notFound` | `notFound` |

A single helper, `RecipeAccessPolicy.resolve(session, recipe)`, returns `RecipeAccess` or throws `notFound`. Every recipe and media method uses it. Updating a team recipe does not require ownership. Only the owner can delete, so neither editors nor viewers can remove a recipe. Saving or removing a favorite uses the same read check: a viewer may favorite a team recipe, and a caller who cannot read it gets `notFound`.

### `IngredientEndpoint` → `client.ingredient`

| Method | Parameters | Returns | Contract |
| --- | --- | --- | --- |
| `search` | `BeverageKind kind`, `String query`, `int limit` | `List<Ingredient>` | `ownerId = caller`, `kind`, `nameKey` prefix of `query.trim().toLowerCase()`. `limit` clamped to 1..30. Index `ingredient_owner_kind_name_idx`. |
| `register` | `IngredientDraft draft` | `Ingredient` | Trim `name` (1..120). Empty name → `validation`. If `(owner, kind, nameKey)` already exists, return that row instead of inserting a duplicate. Otherwise insert with caller as `owner`. |

### `RecipeEndpoint` → `client.recipe`

| Method | Parameters | Returns | Contract |
| --- | --- | --- | --- |
| `save` | `RecipeDraft draft` | `RecipeDetail` | 5-step commit. See below. |
| `get` | `UuidValue id` | `RecipeDetail` | One query with includes: ingredient, instructions ordered by `sortOrder`, flavor tags, photos ordered by `sortOrder`. Fills `photos[].publicUrl`, `access`, and `recipe.isFavorite`. |
| `listMine` | `int limit`, `int offset` | `List<Recipe>` | `ownerId = caller` (personal and team recipes the caller owns), `orderBy updatedAt desc`. `limit` clamped to 1..50. Index `recipe_owner_updated_idx`. Each row has `isFavorite` for the caller. |
| `listFavorites` | `int limit`, `int offset` | `List<Recipe>` | The caller's favorites among recipes they own, same order and clamp as `listMine`. An empty favorite set returns `[]` without a recipe query. A favorited team recipe the caller does not own is excluded, so the home filter stays inside My recipes. |
| `listForTeam` | `UuidValue teamId`, `int limit`, `int offset` | `List<Recipe>` | Membership required (viewer or editor). `teamId` match, `orderBy updatedAt desc`. Index `recipe_team_updated_idx`. Viewer and editor receive the same rows; `RecipeAccess` is not on this list. Each row has that caller's `isFavorite`. |
| `saveFavorite` | `UuidValue recipeId`, `bool replace` | `FavoriteSaveResult` | See below. |
| `removeFavorite` | `UuidValue recipeId` | `void` | Read access required. Deletes the caller's row for that recipe. A missing row is a no-op. |
| `getAccess` | `UuidValue id` | `RecipeAccess` | Used by the client before opening the editor. |
| `delete` | `UuidValue id` | `void` | `canDelete` (owner only). Child rows cascade. Photo storage objects are deleted best-effort after commit. |
| `assignToTeam` | `UuidValue recipeId`, `UuidValue teamId` | `Recipe` | Caller is the recipe owner and an editor of `teamId`. Sets `teamId` and `updatedAt`. The returned recipe has `isFavorite`. |
| `removeFromTeam` | `UuidValue recipeId` | `Recipe` | Caller is the recipe owner, or an editor of the recipe’s current team. Sets `teamId` null. The returned recipe has `isFavorite`. |

`save` transaction (`session.db.transaction`):

1. On update, load the recipe and resolve access. No read access → `notFound`; read-only → `forbidden`.
2. Resolve ingredient. On insert, `ingredientId` must belong to the caller. On update, it must belong to the caller or equal the recipe’s current `ingredientId`, so a team editor can save another member’s recipe without re-picking the bean. Anything else → `notFound`.
3. Validate: title (1..120), grind size and grinder model (1..80) after trim; `waterTempC` in `1..100`; `doseGrams` in `0.1..500`; `extractionDuration` null or `1s..2h`; scores in `0..5`; `extractionMethod == other` requires a non-empty note; tags 1..40 characters, at most 12; each instruction `trim()` length in `1..280`, at most 30 items. Failures → `validation`, with the field name in `message`.
4. Insert or update the `recipe` row. On insert, `owner` is the caller, and `teamId` is set only when the caller is an editor of that team (else `forbidden`). On update, `updatedAt` is refreshed and `teamId` is untouched.
5. Delete `recipe_instruction` and `recipe_flavor_tag` rows for the recipe. Insert instructions with `sortOrder = index` of the trimmed list (possibly empty), and insert distinct `tagKey` rows.
6. After commit, return the same payload as `get`.

The delete-and-insert in step 5 is in the same transaction as step 4. Two editors saving at once therefore produce the last committer’s complete list, never a mix, which satisfies the “replaces in full” rule. Photos are not written here. A recipe with zero instructions and zero photos is valid.

`saveFavorite` runs in one transaction after `RecipeAccessPolicy.load` (no read access → `notFound`):

1. `titleKey = title.trim().toLowerCase()`.
2. If this user already has a favorite row for `recipeId`, return `saved: true` and write nothing.
3. If another of this user's favorites has the same `titleKey` and `replace` is false, return `saved: false` and write nothing.
4. If that conflict exists and `replace` is true, delete it, then insert the new row. The result is `saved: true` with `replacedRecipeId` set to the removed recipe.
5. A unique-index race (two saves of the same title) returns `saved: true` when this recipe is now the favorite, and `saved: false` otherwise, so the client can show the replace dialog.

`removeFavorite` uses the same read check and deletes the caller's `(userId, recipeId)` row when one exists.

### `RecipeMediaEndpoint` → `client.recipeMedia`

| Method | Parameters | Returns | Contract |
| --- | --- | --- | --- |
| `createUploadDescription` | `UuidValue recipeId` | `UploadTicket` | `canEdit`, else `forbidden`. At most 6 photos per recipe, else `validation`. Path is `recipes/<recipeId>/<random v4 UUID>.jpg`, generated by the server. Returns `session.storage.createUploadDescription(storageId: 'public', path: path)`. No DB row yet. |
| `confirmUpload` | `UuidValue recipeId`, `String path` | `RecipePhoto` | `canEdit`. Path must match `recipes/<recipeId>/<uuid>.jpg` exactly, else `validation`. If a row with that `storagePath` already exists, return it (idempotent retry). `verifyUpload` false → `uploadRejected`, no row. On success, in a transaction, insert `recipe_photo` with `sortOrder = max + 1`, retrying once on a unique-index conflict from a parallel upload. |
| `remove` | `UuidValue photoId` | `void` | `canEdit` on the parent recipe. Delete the row. Storage object deletion is best-effort after the row commit. |

The path uses a random v4 UUID instead of v7, so public photo URLs carry no timestamp and are not guessable. The client encodes photos as JPEG and resizes them to 2048px on the long edge before upload.

A new recipe needs an id before photos can attach. The wizard therefore calls `save` before the first upload (step 5 can be skipped entirely). Upload runs only after an id exists.

### `TeamEndpoint` → `client.team`

| Method | Parameters | Returns | Contract |
| --- | --- | --- | --- |
| `create` | `String name` | `TeamSummary` | Trimmed name, 1..80 characters. In one transaction, insert `team` with caller as `owner` plus the creator’s `editor` membership. |
| `listMine` | — | `List<TeamSummary>` | Memberships for `memberId = caller`, include team. Index `team_membership_member_idx`. |
| `createInvite` | `UuidValue teamId`, `TeamRole role`, `Duration ttl` | `InviteLink` | Caller must be `team.ownerId`, else `forbidden` (or `notFound` if not a member). `ttl` clamped to 15 minutes..7 days. `token` is 32 bytes from `Random.secure()`, base64url without padding. `expiresAt = now + ttl`. `url = '<webBaseUrl>/invite/' + token`. Each invite is a single row and can be used once. |
| `acceptInvite` | `String token` | `TeamSummary` | Unknown token → `notFound`. Caller already a member → `alreadyMember`, invite not consumed. Otherwise the conditional claim from the `team_invite` section runs; losing the claim → `inviteUsed` or `inviteExpired`, with no membership write. Winning inserts a membership with the invite’s `role`. |

Invite acceptance does not use Serverpod scopes. The link is the token only; the role is the column on `team_invite`, copied onto `team_membership`.

---

## 3. Flutter State Management Strategy (Bloc/Cubit)

Presentation state is `Cubit` + one immutable `Equatable` state per feature. Widgets call intent methods and rebuild with `BlocBuilder`. Repositories wrap `brewing_journal_client`. No `BuildContext` on a Cubit.

Feature boundary: `BlocProvider` on the route. `RecipeCreationCubit` and `BrewTimerCubit` are not app-scoped.

### `RecipeCreationCubit` / `RecipeCreationState`

Holds the wizard across all five steps. Step widgets only edit this state. The repository is called from `save`.

```text
enum RecipeWizardStep { ingredient, extraction, flavor, instructions, media }
enum SaveStatus { idle, saving, success, failure }

RecipeCreationState
  step: RecipeWizardStep
  saveStatus: SaveStatus
  error: BrewingException?
  recipeId: UuidValue?          // null until first successful save; set when editing
  teamId: UuidValue?
  ingredientQuery: String
  ingredientResults: List<Ingredient>
  selectedIngredient: Ingredient?
  ingredientDraft: IngredientDraft?
  title: String
  waterTempC: double?
  doseGrams: double?
  grindSize: String
  grinderModel: String
  extractionMethod: ExtractionMethod?
  extractionMethodNote: String
  extractionDuration: Duration? // last stopwatch reading; null if never started
  stopwatchRunning: bool
  stopwatchElapsed: Duration    // live reading while running, for the UI
  acidity, sweetness, body, bitterness: int   // default 0
  flavorTags: List<String>
  instructions: List<String>    // display order; duplicates kept
  photos: List<RecipePhoto>     // confirmed rows only; publicUrl for previews
  pendingUpload: bool
  canEdit: bool                 // from RecipeDetail.access; true for a new recipe
```

Intent methods:

| Method | Effect |
| --- | --- |
| `startNew({UuidValue? teamId})` | Empty state, `canEdit = true`, `teamId` as given (from a team screen). |
| `load(UuidValue id)` | `recipe.get`. Copies fields, instructions in `sortOrder`, tags, photos, `access.canEdit`. `step = ingredient`. When `canEdit` is false, the route shows Brew Mode instead of the wizard. |
| `searchIngredients(BeverageKind, String)` | `ingredient.search`. |
| `selectIngredient(Ingredient)` / `registerIngredient(IngredientDraft)` | Sets `selectedIngredient`. Register calls `ingredient.register`. |
| `setExtraction(...)` | Field updates only. |
| `startStopwatch()` / `stopStopwatch()` / `resetStopwatch()` | Internal `Stopwatch` plus a 100ms `Timer.periodic` that emits `stopwatchElapsed`. `stop` cancels the timer and writes `extractionDuration = stopwatch.elapsed`. `reset` sets `extractionDuration = null`. `close()` cancels the timer. This is separate from `BrewTimerCubit`. |
| `setExtractionDuration(Duration?)` | Manual entry or clearing, for a user who timed the brew elsewhere. |
| `setFlavor({scores, tags})` | Replaces tag list. |
| `addInstruction(String)` / `updateInstruction(int, String)` / `removeInstruction(int)` / `moveInstruction(int from, int to)` | Trim. An item that is empty after trim or longer than 280 characters sets a validation `error` and leaves the list unchanged; the field keeps the user’s text so it can be shortened. At most 30 items. No uniqueness check. |
| `skipInstructions()` | `instructions = const []`, advance step. |
| `next()` / `back()` | Step index ± 1. `next` from ingredient requires `selectedIngredient`. `next` from extraction requires title, dose, temp, grind, grinder, and method (plus a note when the method is `other`), and stops a running stopwatch first. |
| `save()` | Builds `RecipeDraft` from state (`instructions` already trimmed; `teamId` only when `recipeId` is null). Calls `recipe.save`. On success stores `recipeId` and the returned photos, `saveStatus = success`. A `BrewingException` sets `saveStatus = failure` and `error`, and keeps all input. |
| `addPhoto(ByteData bytes)` | Requires `recipeId` (calls `save` first if null). `pendingUpload = true` → `createUploadDescription` → `FileUploader(ticket.description).upload(bytes)` → `confirmUpload(recipeId, ticket.path)`. The row is appended only when confirm returns. `uploadRejected` sets `error` and leaves `photos` unchanged. |
| `removePhoto(UuidValue photoId)` | `recipeMedia.remove`, then drops the row from `photos`. |

Editing restores order because `load` sorts by `sortOrder` and `save` sends that list. Removing the last instruction sends `instructions: []`, and the endpoint deletes all child rows.

### `BrewTimerCubit` / `BrewTimerState`

Created when Brew Mode opens. `close()` stops the ticker and does not schedule anything. No notification plugin.

```text
enum BrewTimerMode { idle, countUp, countDown }
enum BrewTimerPhase { idle, running, paused, finished }

BrewTimerState
  mode: BrewTimerMode
  phase: BrewTimerPhase
  target: Duration?       // recipe.extractionDuration
  elapsed: Duration
  remaining: Duration?
```

| Method | Effect |
| --- | --- |
| `configure(Duration? target)` | `target == null` → `mode = idle`, `phase = idle`, no controls shown, no ticker. Otherwise `mode = countDown`, `remaining = target`, `elapsed = Duration.zero`, `phase = idle`. |
| `setMode(BrewTimerMode mode)` | Switch between `countDown` and `countUp`. Allowed only while `phase == idle` and `target != null`. |
| `start()` | No-op when `mode == idle`. Else start an internal `Stopwatch` and a 100ms `Timer.periodic` calling `tick`, `phase = running`. |
| `pause()` / `resume()` | Pause or resume the `Stopwatch` and ticker. `elapsed` is frozen while paused. |
| `stop()` | Cancel the ticker, reset the `Stopwatch`, `AlarmPlayer.stop()`, `phase = idle`, `elapsed = Duration.zero`, `remaining = target`. |
| `tick()` | `elapsed = stopwatch.elapsed`, which does not drift with timer jitter. `remaining = target - elapsed`, clamped at zero. When `elapsed >= target` in either mode, set `phase = finished`, cancel the ticker, and call `AlarmPlayer.play()` once. |

Both modes alarm at `target`. Count-down shows `remaining`, and count-up shows `elapsed` against the target.

`AlarmPlayer` is a thin wrapper over an in-app audio asset. It is invoked only from `tick` while the cubit is open. `close()` calls `stop()`, so leaving the route ends the sound and does not arm a later alarm. When the app goes to the background, the route’s `AppLifecycleListener` calls `pause()`. The ticker does not run in the background, so no alarm fires outside Brew Mode.

Brew Mode reads `RecipeDetail` through a separate `RecipeDetailCubit` (`get` once), then calls `BrewTimerCubit.configure(recipe.extractionDuration)`. It does not change the recipe's parameters. The favorite heart calls `saveFavorite` or `removeFavorite`. Instructions render from `instructions` ordered by `sortOrder`; an empty list omits the section. Photos render from `publicUrl`; an empty `photos` list omits the section. The same `RecipeDetail` feeds the share card.

### Other Cubits

| Cubit | Scope | Calls |
| --- | --- | --- |
| `RecipeListCubit` | Home and team screens | `recipe.listMine`, `recipe.listFavorites` when the home filter is on, or `recipe.listForTeam`, paged by `limit`/`offset`. `saveFavorite` / `removeFavorite` update the visible rows. |
| `RecipeDetailCubit` | Brew Mode and share | `recipe.get`, `recipe.delete` when `access.canDelete`, `saveFavorite`, `removeFavorite` |
| `TeamsCubit` | Teams screen | `team.listMine`, `team.create`, `team.createInvite` (owner only) |
| `InviteAcceptCubit` | `/invite/:token` route | `team.acceptInvite`; maps `inviteExpired`, `inviteUsed`, `alreadyMember`, and `notFound` to messages |

### Favorites

`Recipe.isFavorite` drives a heart `IconButton` (`isSelected`, outline heart when off and filled heart when on). The same button is the trailing control on `RecipeTile` and the first action in the Brew Mode app bar. The home app bar uses it as a filter: selected calls `RecipeListCubit.setFavoritesOnly(true)`, which reloads through `listFavorites`; clearing it reloads `listMine`. The team list has no filter. An empty filtered home list says there are no favorite recipes.

`toggleRecipeFavorite` is the shared tap handler. A filled heart calls `removeFavorite`. An outline heart calls `saveFavorite(replace: false)`. `saved: false` opens `ReplaceFavoriteDialog`: the close icon and Cancel pop false, and Accept calls `saveFavorite(replace: true)`. A failure shows the usual error snackbar. While a request for that recipe is in flight, its heart is disabled (`favoriteBusyIds` on the list, `favoriteBusy` on the detail).

The list cubit that owns the tile applies the new flags itself. Brew Mode's detail cubit does the server call, then `noteFavorite` on the session `RecipeListCubit` so the home heart matches without a second request. A team tile does the same for the personal list, which sits above the team screen's own cubit. When the home filter is on and the saved recipe is not in the loaded page, `noteFavorite` reloads. Unfavoriting while the filter is on drops that row. Replacing a favorite clears `isFavorite` on `replacedRecipeId` and, while the filter is on, removes that row.

---

## 4. Integration and Social Sharing Strategy

Sharing makes no extra Serverpod call. The card is a Flutter widget painted to an image from the `RecipeDetail` already loaded, then handed to the OS share sheet.

1. `RecipeShareCard` is a fixed 360×450 logical-pixel widget (4:5, rendered at `pixelRatio: 3` to 1080×1350 px). It shows the title, ingredient name and kind, method, dose, temperature, grind size, grinder, duration when non-null, the four flavor scores as a small radar chart (`CustomPainter`), flavor tags, and instructions. Photos are not drawn, so rendering never waits on a network image. A fixed 24-logical-pixel footer at the bottom reads "Made with BrewSync". Its height is reserved before the other content is laid out, so long content is cut above the footer and never covers it.
2. Instructions: length 0 → the block is absent. Length 1..4 → all rows in `sortOrder`. Length > 4 → rows `0..2` plus a trailing line `+N more` where `N = length - 3`. Each row is `maxLines: 2` with ellipsis, so a 280-character instruction cannot push the card past its fixed height.
3. The share screen builds the card inside a `RepaintBoundary` with a `GlobalKey`, visible as the preview. After `WidgetsBinding.instance.endOfFrame`, call `(key.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage(pixelRatio: 3)`, then `image.toByteData(format: ImageByteFormat.png)`.
4. `SharePlus.instance.share(ShareParams(files: [XFile.fromData(pngBytes, mimeType: 'image/png', name: 'brewsync-recipe.png')], subject: recipe.title))`. `XFile.fromData` avoids a temp file, so the same path works on iOS, Android, and web (Web Share API).
5. No link or caption text is attached. The image is the whole shared payload, so the post never points to a recipe the recipient cannot open.
6. `share_plus` has no "can share files" check, so the fallback is driven by the result. If `share` throws, or returns `ShareResultStatus.unavailable`, the share screen shows a "Download image" button that saves the same PNG with `XFile.saveTo`. `ShareResultStatus.dismissed` is a user cancel and shows nothing.
7. Anyone with read access can share, including a team viewer. The card only shows what that user can already read in Brew Mode, and sharing writes nothing to the server.

`share_plus` is the only new integration dependency. The share screen owns the `RepaintBoundary`, which is disposed with that route and never sits in the wizard tree.
