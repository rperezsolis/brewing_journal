BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recipe_favorite" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "recipeId" uuid NOT NULL,
    "titleKey" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "recipe_favorite_user_recipe_idx" ON "recipe_favorite" USING btree ("userId", "recipeId");
CREATE UNIQUE INDEX "recipe_favorite_user_title_idx" ON "recipe_favorite" USING btree ("userId", "titleKey");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recipe_favorite"
    ADD CONSTRAINT "recipe_favorite_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "recipe_favorite"
    ADD CONSTRAINT "recipe_favorite_fk_1"
    FOREIGN KEY("recipeId")
    REFERENCES "recipe"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR brewing_journal
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('brewing_journal', '20261003044223103-favorites', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261003044223103-favorites', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();


COMMIT;
