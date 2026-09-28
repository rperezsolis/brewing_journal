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
-- ACTION ALTER TABLE
--
ALTER TABLE "recipe" DROP CONSTRAINT IF EXISTS "recipe_fk_1";
ALTER TABLE "recipe" ADD COLUMN "teamId" uuid;
CREATE INDEX "recipe_team_updated_idx" ON "recipe" USING btree ("teamId", "updatedAt");
--
-- ACTION CREATE TABLE
--
CREATE TABLE "team" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "ownerId" uuid NOT NULL,
    "name" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "team_owner_idx" ON "team" USING btree ("ownerId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "team_invite" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "teamId" uuid NOT NULL,
    "createdById" uuid NOT NULL,
    "token" text NOT NULL,
    "role" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "usedAt" timestamp without time zone,
    "usedById" uuid,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "team_invite_token_idx" ON "team_invite" USING btree ("token");
CREATE INDEX "team_invite_team_idx" ON "team_invite" USING btree ("teamId", "expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "team_membership" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "teamId" uuid NOT NULL,
    "memberId" uuid NOT NULL,
    "role" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "team_membership_team_member_idx" ON "team_membership" USING btree ("teamId", "memberId");
CREATE INDEX "team_membership_member_idx" ON "team_membership" USING btree ("memberId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recipe"
    ADD CONSTRAINT "recipe_fk_2"
    FOREIGN KEY("ingredientId")
    REFERENCES "ingredient"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "recipe"
    ADD CONSTRAINT "recipe_fk_1"
    FOREIGN KEY("teamId")
    REFERENCES "team"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "team"
    ADD CONSTRAINT "team_fk_0"
    FOREIGN KEY("ownerId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "team_invite"
    ADD CONSTRAINT "team_invite_fk_0"
    FOREIGN KEY("teamId")
    REFERENCES "team"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "team_invite"
    ADD CONSTRAINT "team_invite_fk_1"
    FOREIGN KEY("createdById")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "team_invite"
    ADD CONSTRAINT "team_invite_fk_2"
    FOREIGN KEY("usedById")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "team_membership"
    ADD CONSTRAINT "team_membership_fk_0"
    FOREIGN KEY("teamId")
    REFERENCES "team"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "team_membership"
    ADD CONSTRAINT "team_membership_fk_1"
    FOREIGN KEY("memberId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR brewing_journal
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('brewing_journal', '20260925230319669-teams', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260925230319669-teams', "timestamp" = now();

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
