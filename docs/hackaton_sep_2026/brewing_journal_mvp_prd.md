# Product Requirements Document (PRD)
**Project Name:** BrewSync (Hackathon MVP)
**Platform:** Flutter (iOS/Android/Web) & Serverpod 4 (Backend)
**Target Audience:** Coffee, Tea, and Matcha enthusiasts, home brewers, and professional baristas.

## 1. Introduction
BrewSync is a collaborative brewing journal application designed to help users track, perfect, and share their coffee, tea, and matcha extraction recipes. Built for a Serverpod hackathon, this MVP focuses on robust data modeling, email authentication, in-app brewing timers, team collaboration, favorites, and sharing from the device.

## 2. Technical Stack
*   **Frontend:** Flutter (Dart) with `serverpod_flutter` 4.0.2 and `serverpod_auth_idp_flutter` 4.0.2 (iOS, Android, and Web)
*   **Backend:** Serverpod 4.0.2 (Dart), PostgreSQL. The Flutter app calls the generated `brewing_journal_client` (`serverpod_client` and `serverpod_auth_idp_client`).
*   **Authentication:** `serverpod_auth_idp` — email and password, with JWT sessions (`JwtConfigFromPasswords`), already initialized in `brewing_journal_server/lib/server.dart`. Serverpod also ships Google, Apple, and other identity providers; this MVP uses the email provider only.
*   **File storage:** Serverpod uploads through `serverpod_cloud_storage`. `public` and `private` storages use Serverpod Cloud when deployed, and `DatabaseCloudStorage` for local development.
*   **Timers and alarms:** Implemented in the Flutter app. Serverpod does not send push notifications.

---

## 3. Core Features & Requirements

### Feature 1: Authentication System
**Description:** Sign-in with the email identity provider already configured on the server.
**Requirements:**
*   Email and password registration and login. Verification codes are written to the server log in development and sent through Serverpod Cloud email in staging and production.
*   Persistent sessions restored by `FlutterAuthSessionManager` (JWT access and refresh tokens) across app restarts.

### Feature 2: 5-Step Recipe Creation & Editing
**Description:** A guided wizard to log a new brewing session or edit an existing one.
**Requirements:**
*   **Step 1: Bean/Leaf Selection:** Search, select, or register a new coffee bean, matcha grade, or tea leaf (Origin, Roaster, Roast Level, Processing).
*   **Step 2: Extraction Parameters & Timer:** 
    *   Inputs: Recipe Title, Water Temperature, Coffee/Tea Dose (grams), Grind Size, Grinder Model, Extraction Method (e.g., V60, Espresso, French Press).
    *   Interactive Tool: A built-in stopwatch UI to measure and record the actual extraction time dynamically during the brew.
*   **Step 3: Flavor Map:** A visual UI (radar chart or flavor wheel) to input tasting notes (e.g., Acidity, Sweetness, Body, Bitterness, Specific flavor tags).
*   **Step 4: Additional Steps (Optional):** Add an ordered list of extra instructions that sit outside the extraction parameters. Each item is free text the user writes, for example "use 150ml of whole milk", "use 100g of ice", or "add cinnamon and stir". The user can add, edit, reorder, and remove items, and can skip this step. Leading and trailing spaces are trimmed. An item that is empty after trimming is refused. The same wording may appear more than once. Editing a recipe restores the list in its saved order. Removing every item leaves the recipe with no extra instructions.
*   **Step 5: Media Upload (Optional):** Upload photos of the final cup, the crema, or the bean packaging. The server issues an upload description for the `public` storage, the client uploads the file, and the server verifies it before saving the path on the recipe. A file that fails verification is not stored on the recipe, and the user can save the recipe with no photos.

### Feature 3: Replicate a Saved Recipe (Brew Mode)
**Description:** A focused "Brewing Mode" UI for replicating past successes.
**Requirements:**
*   Read-only view of all parameters, the ordered additional steps, and photos from a saved recipe. Extra instructions appear in the order they were saved, so the brewer can follow them during the session. When the recipe has none, including after every instruction was removed, that section is omitted. When the recipe has no photos, the photo section is omitted.
*   **Smart Timer:** A countdown or count-up timer in the Flutter UI, pre-set to the time saved in the recipe. If the recipe has no recorded extraction time, Brew Mode still opens and does not start a timer or fire an alarm.
*   **Alerts:** An in-app audio alarm when the target extraction time is reached while Brew Mode is open. Leaving Brew Mode or the app does not send a notification later.

### Feature 4: Collaborative Teams & Workspaces
**Description:** A feature allowing users to group recipes into shared workspaces for cafes, roasting teams, or friend groups.
**Requirements:**
*   Create a "Team" or "Workspace".
*   Add existing or new recipes to the Team workspace.
*   **Invite Links:** A Serverpod endpoint creates a single-use or expiring invite token. The link carries that token. An expired or already-used token is rejected and does not change membership.
*   **Team roles:** The team creator assigns a role on the invite. Membership and role are stored in the database and checked inside endpoint methods (`requireLogin`, then viewer vs editor). Serverpod's built-in scopes stay reserved for account-level access such as admin.
    *   *Viewer:* Can only read recipes.
    *   *Editor:* Can read, create, and update recipes within the team, including the extra-instruction list. A save replaces that list in full, so the team sees the latest ordered list.

### Feature 5: Share a Recipe
**Description:** Let the user share a recipe from the device. Social network developer APIs are outside this Serverpod stack.
**Requirements:**
*   Generate a shareable graphic in the Flutter app (a summary card of the recipe parameters, flavor map, and extra instructions when the recipe has them). When there are no extra instructions, that block is omitted. When the list does not fit on the card, the card shows the leading instructions and notes that more exist. Every card ends with a "Made with BrewSync" line, so people who see a shared post know where it came from.
*   Open the platform share sheet with that image only, so the user can send it to whichever apps are installed (for example Instagram, X, Pinterest, or Messages). No link to the recipe is attached: recipes are private to their owner and team, so a link would not open for most recipients. Where the browser cannot share files, the user can download the image instead. Anyone who can read a recipe, including a team viewer, can share its image.

### Feature 6: Favorites
**Description:** Let the user mark the winning version of a recipe, then find it again among the trials that share its name.
**Requirements:**
*   A heart toggle on every recipe tile and on the Brew Mode app bar adds that recipe to the user's favorites or removes it. Any recipe the user can read can be saved, including a team recipe, and a viewer can save one. The favorite belongs to the signed-in user: another member starring the same shared recipe does not change this user's list.
*   A user may keep only one favorite per recipe name. The comparison trims the title and ignores capitalization, so "V60" and "v60" are the same name. Different names can all be favorites at once.
*   When the user tries to save a recipe whose name is already a favorite, a dialog says a recipe with that name is already in favorites and asks whether to replace it. A close icon in the top-right and a Cancel action dismiss the dialog and leave the existing favorite in place. Accept removes that favorite and saves the recipe the user just chose.
*   A heart toggle in the home recipe list's app bar filters that list. On, the list shows only the user's own recipes that are favorites. Off, it shows all of the user's recipes. A team recipe the user does not own can still be starred on the team list and in Brew Mode; the home filter does not pull it into My recipes.

---

## 4. User Stories

### Authentication
*   **US-1.1:** As a new user, I want to sign up with my email and password so that I can access the app on this Serverpod project.
*   **US-1.2:** As a returning user, I want my session to remain active across app restarts so I don't have to log in every time I want to brew a coffee.
*   **US-1.3:** As a user, I want a wrong password or an unknown email to keep me signed out and explain the failure, so I can try again without entering the app.
*   **US-1.4:** As a new user, I want an invalid or expired verification code to be rejected, so an old or mistyped code cannot finish registration.

### Recipe Creation
*   **US-2.1:** As a coffee enthusiast, I want to record the specific grinder model and grind size I used so that I can track how equipment impacts my extraction.
*   **US-2.2:** As a barista, I want to use a built-in stopwatch while creating my recipe so that the exact extraction time is automatically saved to my parameters without relying on my phone's clock app.
*   **US-2.3:** As a user, I want to visually map the flavor profile of my brew on a chart so that I can easily compare the taste differences between different variables over time.
*   **US-2.4:** As a home brewer, I want to optionally add an ordered list of my own extra instructions, such as "use 150ml of whole milk", "use 100g of ice", or "add cinnamon and stir", and edit, reorder, or remove them — including removing the last one — so that steps outside the extraction parameters are saved with the recipe.
*   **US-2.5:** As a home brewer, I want to skip the extra-instructions step when a recipe does not need any, so that creating a straightforward brew stays short.
*   **US-2.6:** As a visual learner, I want to attach photos of my espresso shot's crema so I can document the visual quality of the extraction.
*   **US-2.7:** As a home brewer, I want leading and trailing spaces trimmed from an instruction, and a blank item refused, so the saved list never contains an empty step.
*   **US-2.8:** As a home brewer, I want two instructions with the same wording to both be kept in the order I arranged them, so a repeated action such as "stir" can appear more than once.
*   **US-2.9:** As a home brewer editing a saved recipe, I want the extra instructions to load in their saved order, so I can change, reorder, or remove them without typing the list again.
*   **US-2.10:** As a home brewer, I want each instruction stored as the text I wrote, including amounts such as "150ml" or "100g", so I am not asked to split a step into separate quantity and unit fields.
*   **US-2.11:** As a home brewer, I want an overly long instruction to be rejected until I shorten it, so one step stays readable in the wizard, in Brew Mode, and on a share card.
*   **US-2.12:** As a visual learner, I want a photo that fails verification to be rejected with a clear error, and I want to save the recipe with no photos, so a failed upload is not stored on the recipe.

### Recipe Replication (Brew Mode)
*   **US-3.1:** As a user, I want to open a past favorite recipe and see a clean overview of the doses, temperatures, and any extra instructions needed to prep my workstation.
*   **US-3.2:** As a brewer, I want those extra instructions shown in the order I saved them, and omitted when the recipe has none — including after every instruction was removed — so I can follow them during the session without an empty section.
*   **US-3.3:** As a busy brewer, I want to start a timer that matches my saved recipe and hear an in-app alarm when the time is up while Brew Mode stays open, so I don't over-extract my coffee if I look away.
*   **US-3.4:** As a brewer, I want Brew Mode to open when a recipe has no recorded extraction time, without starting a timer or an alarm, so I can still follow the parameters and extra instructions.
*   **US-3.5:** As a brewer, I want the alarm to stay inside the app and not arrive after I leave Brew Mode, so closing the screen does not notify me later.
*   **US-3.6:** As a brewer, I want the photo section hidden when a recipe has no photos, so Brew Mode does not show an empty or broken image.

### Collaborative Teams
*   **US-4.1:** As a cafe manager, I want to create a "Shop Recipes" team and add our standard espresso parameters so that all my staff have a single source of truth.
*   **US-4.2:** As a cafe manager, I want to generate a "read-only" invite link for new baristas so they can view the recipes but not accidentally modify or delete them.
*   **US-4.3:** As a head roaster, I want to give "editor" permissions via an invite link to my quality control team so we can collaboratively tweak a recipe, including its extra instructions, during a tasting session.
*   **US-4.4:** As a viewer, I want to read a team recipe's extra instructions but be blocked from adding, editing, reordering, or removing them, so a read-only invite cannot change the method.
*   **US-4.5:** As someone opening an invite, I want an expired or already-used link to fail with a clear message and leave my membership unchanged.
*   **US-4.6:** As an editor, I want my save of a recipe's extra instructions to replace the previous list in full, so after two people edit the same recipe the team sees one ordered list.

### Social Sharing
*   **US-5.1:** As a coffee influencer, I want to generate a summary image of my V60 recipe and send it through the device share sheet so I can post it from whichever app I choose.
*   **US-5.2:** As a creator, I want to share an image of my matcha recipe through the device share sheet so I can pass it to X, Pinterest, or another installed app.
*   **US-5.3:** As a creator, I want the summary card to include extra instructions when the recipe has them, to leave that block off when it has none, and to show the leading instructions plus a note when the list does not fit, so the shared image matches the recipe and still fits on one card.

### Favorites
*   **US-6.1:** As a brewer refining a recipe, I want to save one version as a favorite so I can tell the winning parameters apart from the trials that share its name.
*   **US-6.2:** As a brewer, I want a heart on the recipe tile and in Brew Mode so I can add or remove that recipe from favorites without leaving the list or the brew screen.
*   **US-6.3:** As a brewer, I want a dialog when a favorite already uses that name, with Accept to replace it and with Cancel or close to keep the existing favorite.
*   **US-6.4:** As a brewer, I want the home list to show only my favorite recipes when the app-bar heart is on, and all of my recipes when it is off.
*   **US-6.5:** As a team member, including a viewer, I want to favorite a shared recipe I can read, and I want that choice to be mine alone so another member's favorite does not change my list.