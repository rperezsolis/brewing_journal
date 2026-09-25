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
CREATE TABLE "ingredient" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "ownerId" uuid NOT NULL,
    "kind" text NOT NULL,
    "name" text NOT NULL,
    "nameKey" text NOT NULL,
    "origin" text,
    "roaster" text,
    "roastLevel" text,
    "processing" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "ingredient_owner_kind_name_idx" ON "ingredient" USING btree ("ownerId", "kind", "nameKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recipe" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "ownerId" uuid NOT NULL,
    "ingredientId" uuid NOT NULL,
    "title" text NOT NULL,
    "waterTempC" double precision NOT NULL,
    "doseGrams" double precision NOT NULL,
    "grindSize" text NOT NULL,
    "grinderModel" text NOT NULL,
    "extractionMethod" text NOT NULL,
    "extractionMethodNote" text,
    "extractionDuration" bigint,
    "acidity" bigint NOT NULL,
    "sweetness" bigint NOT NULL,
    "body" bigint NOT NULL,
    "bitterness" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "recipe_owner_updated_idx" ON "recipe" USING btree ("ownerId", "updatedAt");
CREATE INDEX "recipe_ingredient_idx" ON "recipe" USING btree ("ingredientId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recipe_flavor_tag" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "recipeId" uuid NOT NULL,
    "tag" text NOT NULL,
    "tagKey" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "recipe_flavor_tag_recipe_idx" ON "recipe_flavor_tag" USING btree ("recipeId", "tagKey");
CREATE INDEX "recipe_flavor_tag_key_idx" ON "recipe_flavor_tag" USING btree ("tagKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recipe_instruction" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "recipeId" uuid NOT NULL,
    "sortOrder" bigint NOT NULL,
    "text" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "recipe_instruction_order_idx" ON "recipe_instruction" USING btree ("recipeId", "sortOrder");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recipe_photo" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "recipeId" uuid NOT NULL,
    "storagePath" text NOT NULL,
    "sortOrder" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "recipe_photo_order_idx" ON "recipe_photo" USING btree ("recipeId", "sortOrder");
CREATE UNIQUE INDEX "recipe_photo_path_idx" ON "recipe_photo" USING btree ("storagePath");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "ingredient"
    ADD CONSTRAINT "ingredient_fk_0"
    FOREIGN KEY("ownerId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recipe"
    ADD CONSTRAINT "recipe_fk_0"
    FOREIGN KEY("ownerId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "recipe"
    ADD CONSTRAINT "recipe_fk_1"
    FOREIGN KEY("ingredientId")
    REFERENCES "ingredient"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recipe_flavor_tag"
    ADD CONSTRAINT "recipe_flavor_tag_fk_0"
    FOREIGN KEY("recipeId")
    REFERENCES "recipe"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recipe_instruction"
    ADD CONSTRAINT "recipe_instruction_fk_0"
    FOREIGN KEY("recipeId")
    REFERENCES "recipe"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recipe_photo"
    ADD CONSTRAINT "recipe_photo_fk_0"
    FOREIGN KEY("recipeId")
    REFERENCES "recipe"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR brewing_journal
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('brewing_journal', '20260925200116958-recipes', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260925200116958-recipes', "timestamp" = now();

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
