/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:brewing_journal_server/src/generated/brewing/ingredient.dart'
    as _ijmrhoj0;
import 'package:brewing_journal_server/src/generated/brewing/recipe.dart'
    as _iazv39l2;
import 'package:brewing_journal_server/src/generated/teams/team_summary.dart'
    as _id1eflpk;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'brewing/beverage_kind.dart' as _ino7p0mu;
import 'brewing/brewing_error_code.dart' as _ioc3dgt7;
import 'brewing/brewing_exception.dart' as _iim692ik;
import 'brewing/extraction_method.dart' as _i54p6pxa;
import 'brewing/favorite_save_result.dart' as _i73spzup;
import 'brewing/ingredient.dart' as _ihnk7xbr;
import 'brewing/ingredient_draft.dart' as _idpdlwt4;
import 'brewing/recipe.dart' as _izkawori;
import 'brewing/recipe_access.dart' as _i99euqmx;
import 'brewing/recipe_detail.dart' as _ijpoq8bv;
import 'brewing/recipe_draft.dart' as _iy437pkv;
import 'brewing/recipe_favorite.dart' as _i76c0bzt;
import 'brewing/recipe_flavor_tag.dart' as _ij3iqvmk;
import 'brewing/recipe_instruction.dart' as _id0mij74;
import 'brewing/recipe_photo.dart' as _i9xtdqqg;
import 'brewing/roast_level.dart' as _ilmoykyi;
import 'brewing/team_recipe_favorite.dart' as _intarog7;
import 'brewing/upload_ticket.dart' as _ivpdymeq;
import 'teams/invite_link.dart' as _ih3460lx;
import 'teams/team.dart' as _im6wd3ml;
import 'teams/team_invite.dart' as _ixubbi3v;
import 'teams/team_membership.dart' as _it1ysroj;
import 'teams/team_role.dart' as _i8uq5mqx;
import 'teams/team_summary.dart' as _i5r78mbx;
export 'brewing/beverage_kind.dart';
export 'brewing/brewing_error_code.dart';
export 'brewing/brewing_exception.dart';
export 'brewing/extraction_method.dart';
export 'brewing/favorite_save_result.dart';
export 'brewing/ingredient.dart';
export 'brewing/ingredient_draft.dart';
export 'brewing/recipe.dart';
export 'brewing/recipe_access.dart';
export 'brewing/recipe_detail.dart';
export 'brewing/recipe_draft.dart';
export 'brewing/recipe_favorite.dart';
export 'brewing/recipe_flavor_tag.dart';
export 'brewing/recipe_instruction.dart';
export 'brewing/recipe_photo.dart';
export 'brewing/roast_level.dart';
export 'brewing/team_recipe_favorite.dart';
export 'brewing/upload_ticket.dart';
export 'teams/invite_link.dart';
export 'teams/team.dart';
export 'teams/team_invite.dart';
export 'teams/team_membership.dart';
export 'teams/team_role.dart';
export 'teams/team_summary.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'ingredient',
      dartName: 'Ingredient',
      schema: 'public',
      module: 'brewing_journal',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:BeverageKind',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'nameKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'roaster',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'roastLevel',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:RoastLevel?',
        ),
        _isp.ColumnDefinition(
          name: 'processing',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'ingredient_fk_0',
          columns: ['ownerId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'ingredient_owner_kind_name_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'kind',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nameKey',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'recipe',
      dartName: 'Recipe',
      schema: 'public',
      module: 'brewing_journal',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'teamId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'ingredientId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'waterTempC',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'doseGrams',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'grindSize',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'grinderModel',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'extractionMethod',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ExtractionMethod',
        ),
        _isp.ColumnDefinition(
          name: 'extractionMethodNote',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'extractionDuration',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'Duration?',
        ),
        _isp.ColumnDefinition(
          name: 'acidity',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sweetness',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'body',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'bitterness',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'recipe_fk_0',
          columns: ['ownerId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'recipe_fk_1',
          columns: ['teamId'],
          referenceTable: 'team',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'recipe_fk_2',
          columns: ['ingredientId'],
          referenceTable: 'ingredient',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'recipe_owner_updated_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'updatedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'recipe_team_updated_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'teamId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'updatedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'recipe_ingredient_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ingredientId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'recipe_favorite',
      dartName: 'RecipeFavorite',
      schema: 'public',
      module: 'brewing_journal',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'recipeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'titleKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'recipe_favorite_fk_0',
          columns: ['userId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'recipe_favorite_fk_1',
          columns: ['recipeId'],
          referenceTable: 'recipe',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'recipe_favorite_user_recipe_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipeId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'recipe_favorite_user_title_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'titleKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'recipe_flavor_tag',
      dartName: 'RecipeFlavorTag',
      schema: 'public',
      module: 'brewing_journal',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'recipeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'tag',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'tagKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'recipe_flavor_tag_fk_0',
          columns: ['recipeId'],
          referenceTable: 'recipe',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'recipe_flavor_tag_recipe_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipeId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tagKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'recipe_flavor_tag_key_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tagKey',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'recipe_instruction',
      dartName: 'RecipeInstruction',
      schema: 'public',
      module: 'brewing_journal',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'recipeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'text',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'recipe_instruction_fk_0',
          columns: ['recipeId'],
          referenceTable: 'recipe',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'recipe_instruction_order_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipeId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'recipe_photo',
      dartName: 'RecipePhoto',
      schema: 'public',
      module: 'brewing_journal',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'recipeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'storagePath',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'recipe_photo_fk_0',
          columns: ['recipeId'],
          referenceTable: 'recipe',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'recipe_photo_order_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipeId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'recipe_photo_path_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'storagePath',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'team',
      dartName: 'Team',
      schema: 'public',
      module: 'brewing_journal',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'team_fk_0',
          columns: ['ownerId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'team_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'team_invite',
      dartName: 'TeamInvite',
      schema: 'public',
      module: 'brewing_journal',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'teamId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'createdById',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'token',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TeamRole',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'usedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'usedById',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'team_invite_fk_0',
          columns: ['teamId'],
          referenceTable: 'team',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'team_invite_fk_1',
          columns: ['createdById'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'team_invite_fk_2',
          columns: ['usedById'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'team_invite_token_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'team_invite_team_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'teamId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'team_membership',
      dartName: 'TeamMembership',
      schema: 'public',
      module: 'brewing_journal',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'teamId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'memberId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TeamRole',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'team_membership_fk_0',
          columns: ['teamId'],
          referenceTable: 'team',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'team_membership_fk_1',
          columns: ['memberId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'team_membership_team_member_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'teamId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'memberId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'team_membership_member_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'memberId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'team_recipe_favorite',
      dartName: 'TeamRecipeFavorite',
      schema: 'public',
      module: 'brewing_journal',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'teamId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'recipeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'titleKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'team_recipe_favorite_fk_0',
          columns: ['teamId'],
          referenceTable: 'team',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'team_recipe_favorite_fk_1',
          columns: ['recipeId'],
          referenceTable: 'recipe',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'team_recipe_favorite_team_recipe_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'teamId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipeId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'team_recipe_favorite_team_title_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'teamId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'titleKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _ino7p0mu.BeverageKind) {
      return _ino7p0mu.BeverageKind.fromJson(data) as T;
    }
    if (t == _ioc3dgt7.BrewingErrorCode) {
      return _ioc3dgt7.BrewingErrorCode.fromJson(data) as T;
    }
    if (t == _iim692ik.BrewingException) {
      return _iim692ik.BrewingException.fromJson(data) as T;
    }
    if (t == _i54p6pxa.ExtractionMethod) {
      return _i54p6pxa.ExtractionMethod.fromJson(data) as T;
    }
    if (t == _i73spzup.FavoriteSaveResult) {
      return _i73spzup.FavoriteSaveResult.fromJson(data) as T;
    }
    if (t == _ihnk7xbr.Ingredient) {
      return _ihnk7xbr.Ingredient.fromJson(data) as T;
    }
    if (t == _idpdlwt4.IngredientDraft) {
      return _idpdlwt4.IngredientDraft.fromJson(data) as T;
    }
    if (t == _izkawori.Recipe) {
      return _izkawori.Recipe.fromJson(data) as T;
    }
    if (t == _i99euqmx.RecipeAccess) {
      return _i99euqmx.RecipeAccess.fromJson(data) as T;
    }
    if (t == _ijpoq8bv.RecipeDetail) {
      return _ijpoq8bv.RecipeDetail.fromJson(data) as T;
    }
    if (t == _iy437pkv.RecipeDraft) {
      return _iy437pkv.RecipeDraft.fromJson(data) as T;
    }
    if (t == _i76c0bzt.RecipeFavorite) {
      return _i76c0bzt.RecipeFavorite.fromJson(data) as T;
    }
    if (t == _ij3iqvmk.RecipeFlavorTag) {
      return _ij3iqvmk.RecipeFlavorTag.fromJson(data) as T;
    }
    if (t == _id0mij74.RecipeInstruction) {
      return _id0mij74.RecipeInstruction.fromJson(data) as T;
    }
    if (t == _i9xtdqqg.RecipePhoto) {
      return _i9xtdqqg.RecipePhoto.fromJson(data) as T;
    }
    if (t == _ilmoykyi.RoastLevel) {
      return _ilmoykyi.RoastLevel.fromJson(data) as T;
    }
    if (t == _intarog7.TeamRecipeFavorite) {
      return _intarog7.TeamRecipeFavorite.fromJson(data) as T;
    }
    if (t == _ivpdymeq.UploadTicket) {
      return _ivpdymeq.UploadTicket.fromJson(data) as T;
    }
    if (t == _ih3460lx.InviteLink) {
      return _ih3460lx.InviteLink.fromJson(data) as T;
    }
    if (t == _im6wd3ml.Team) {
      return _im6wd3ml.Team.fromJson(data) as T;
    }
    if (t == _ixubbi3v.TeamInvite) {
      return _ixubbi3v.TeamInvite.fromJson(data) as T;
    }
    if (t == _it1ysroj.TeamMembership) {
      return _it1ysroj.TeamMembership.fromJson(data) as T;
    }
    if (t == _i8uq5mqx.TeamRole) {
      return _i8uq5mqx.TeamRole.fromJson(data) as T;
    }
    if (t == _i5r78mbx.TeamSummary) {
      return _i5r78mbx.TeamSummary.fromJson(data) as T;
    }
    if (t == _is.getType<_ino7p0mu.BeverageKind?>()) {
      return (data != null ? _ino7p0mu.BeverageKind.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ioc3dgt7.BrewingErrorCode?>()) {
      return (data != null ? _ioc3dgt7.BrewingErrorCode.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iim692ik.BrewingException?>()) {
      return (data != null ? _iim692ik.BrewingException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i54p6pxa.ExtractionMethod?>()) {
      return (data != null ? _i54p6pxa.ExtractionMethod.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i73spzup.FavoriteSaveResult?>()) {
      return (data != null ? _i73spzup.FavoriteSaveResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ihnk7xbr.Ingredient?>()) {
      return (data != null ? _ihnk7xbr.Ingredient.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_idpdlwt4.IngredientDraft?>()) {
      return (data != null ? _idpdlwt4.IngredientDraft.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izkawori.Recipe?>()) {
      return (data != null ? _izkawori.Recipe.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i99euqmx.RecipeAccess?>()) {
      return (data != null ? _i99euqmx.RecipeAccess.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijpoq8bv.RecipeDetail?>()) {
      return (data != null ? _ijpoq8bv.RecipeDetail.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iy437pkv.RecipeDraft?>()) {
      return (data != null ? _iy437pkv.RecipeDraft.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i76c0bzt.RecipeFavorite?>()) {
      return (data != null ? _i76c0bzt.RecipeFavorite.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ij3iqvmk.RecipeFlavorTag?>()) {
      return (data != null ? _ij3iqvmk.RecipeFlavorTag.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_id0mij74.RecipeInstruction?>()) {
      return (data != null ? _id0mij74.RecipeInstruction.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i9xtdqqg.RecipePhoto?>()) {
      return (data != null ? _i9xtdqqg.RecipePhoto.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ilmoykyi.RoastLevel?>()) {
      return (data != null ? _ilmoykyi.RoastLevel.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_intarog7.TeamRecipeFavorite?>()) {
      return (data != null ? _intarog7.TeamRecipeFavorite.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ivpdymeq.UploadTicket?>()) {
      return (data != null ? _ivpdymeq.UploadTicket.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ih3460lx.InviteLink?>()) {
      return (data != null ? _ih3460lx.InviteLink.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_im6wd3ml.Team?>()) {
      return (data != null ? _im6wd3ml.Team.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ixubbi3v.TeamInvite?>()) {
      return (data != null ? _ixubbi3v.TeamInvite.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_it1ysroj.TeamMembership?>()) {
      return (data != null ? _it1ysroj.TeamMembership.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8uq5mqx.TeamRole?>()) {
      return (data != null ? _i8uq5mqx.TeamRole.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i5r78mbx.TeamSummary?>()) {
      return (data != null ? _i5r78mbx.TeamSummary.fromJson(data) : null) as T;
    }
    if (t == List<_id0mij74.RecipeInstruction>) {
      return (data as List)
              .map((e) => deserialize<_id0mij74.RecipeInstruction>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_id0mij74.RecipeInstruction>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_id0mij74.RecipeInstruction>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i9xtdqqg.RecipePhoto>) {
      return (data as List)
              .map((e) => deserialize<_i9xtdqqg.RecipePhoto>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_i9xtdqqg.RecipePhoto>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i9xtdqqg.RecipePhoto>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ij3iqvmk.RecipeFlavorTag>) {
      return (data as List)
              .map((e) => deserialize<_ij3iqvmk.RecipeFlavorTag>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_ij3iqvmk.RecipeFlavorTag>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ij3iqvmk.RecipeFlavorTag>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_it1ysroj.TeamMembership>) {
      return (data as List)
              .map((e) => deserialize<_it1ysroj.TeamMembership>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_it1ysroj.TeamMembership>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_it1ysroj.TeamMembership>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ixubbi3v.TeamInvite>) {
      return (data as List)
              .map((e) => deserialize<_ixubbi3v.TeamInvite>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_ixubbi3v.TeamInvite>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ixubbi3v.TeamInvite>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_izkawori.Recipe>) {
      return (data as List)
              .map((e) => deserialize<_izkawori.Recipe>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_izkawori.Recipe>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_izkawori.Recipe>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ijmrhoj0.Ingredient>) {
      return (data as List)
              .map((e) => deserialize<_ijmrhoj0.Ingredient>(e))
              .toList()
          as T;
    }
    if (t == List<_iazv39l2.Recipe>) {
      return (data as List)
              .map((e) => deserialize<_iazv39l2.Recipe>(e))
              .toList()
          as T;
    }
    if (t == List<_id1eflpk.TeamSummary>) {
      return (data as List)
              .map((e) => deserialize<_id1eflpk.TeamSummary>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _ino7p0mu.BeverageKind => 'BeverageKind',
      _ioc3dgt7.BrewingErrorCode => 'BrewingErrorCode',
      _iim692ik.BrewingException => 'BrewingException',
      _i54p6pxa.ExtractionMethod => 'ExtractionMethod',
      _i73spzup.FavoriteSaveResult => 'FavoriteSaveResult',
      _ihnk7xbr.Ingredient => 'Ingredient',
      _idpdlwt4.IngredientDraft => 'IngredientDraft',
      _izkawori.Recipe => 'Recipe',
      _i99euqmx.RecipeAccess => 'RecipeAccess',
      _ijpoq8bv.RecipeDetail => 'RecipeDetail',
      _iy437pkv.RecipeDraft => 'RecipeDraft',
      _i76c0bzt.RecipeFavorite => 'RecipeFavorite',
      _ij3iqvmk.RecipeFlavorTag => 'RecipeFlavorTag',
      _id0mij74.RecipeInstruction => 'RecipeInstruction',
      _i9xtdqqg.RecipePhoto => 'RecipePhoto',
      _ilmoykyi.RoastLevel => 'RoastLevel',
      _intarog7.TeamRecipeFavorite => 'TeamRecipeFavorite',
      _ivpdymeq.UploadTicket => 'UploadTicket',
      _ih3460lx.InviteLink => 'InviteLink',
      _im6wd3ml.Team => 'Team',
      _ixubbi3v.TeamInvite => 'TeamInvite',
      _it1ysroj.TeamMembership => 'TeamMembership',
      _i8uq5mqx.TeamRole => 'TeamRole',
      _i5r78mbx.TeamSummary => 'TeamSummary',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'brewing_journal.',
        '',
      );
    }

    switch (data) {
      case _ino7p0mu.BeverageKind():
        return 'BeverageKind';
      case _ioc3dgt7.BrewingErrorCode():
        return 'BrewingErrorCode';
      case _iim692ik.BrewingException():
        return 'BrewingException';
      case _i54p6pxa.ExtractionMethod():
        return 'ExtractionMethod';
      case _i73spzup.FavoriteSaveResult():
        return 'FavoriteSaveResult';
      case _ihnk7xbr.Ingredient():
        return 'Ingredient';
      case _idpdlwt4.IngredientDraft():
        return 'IngredientDraft';
      case _izkawori.Recipe():
        return 'Recipe';
      case _i99euqmx.RecipeAccess():
        return 'RecipeAccess';
      case _ijpoq8bv.RecipeDetail():
        return 'RecipeDetail';
      case _iy437pkv.RecipeDraft():
        return 'RecipeDraft';
      case _i76c0bzt.RecipeFavorite():
        return 'RecipeFavorite';
      case _ij3iqvmk.RecipeFlavorTag():
        return 'RecipeFlavorTag';
      case _id0mij74.RecipeInstruction():
        return 'RecipeInstruction';
      case _i9xtdqqg.RecipePhoto():
        return 'RecipePhoto';
      case _ilmoykyi.RoastLevel():
        return 'RoastLevel';
      case _intarog7.TeamRecipeFavorite():
        return 'TeamRecipeFavorite';
      case _ivpdymeq.UploadTicket():
        return 'UploadTicket';
      case _ih3460lx.InviteLink():
        return 'InviteLink';
      case _im6wd3ml.Team():
        return 'Team';
      case _ixubbi3v.TeamInvite():
        return 'TeamInvite';
      case _it1ysroj.TeamMembership():
        return 'TeamMembership';
      case _i8uq5mqx.TeamRole():
        return 'TeamRole';
      case _i5r78mbx.TeamSummary():
        return 'TeamSummary';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'BeverageKind') {
      return deserialize<_ino7p0mu.BeverageKind>(data['data']);
    }
    if (dataClassName == 'BrewingErrorCode') {
      return deserialize<_ioc3dgt7.BrewingErrorCode>(data['data']);
    }
    if (dataClassName == 'BrewingException') {
      return deserialize<_iim692ik.BrewingException>(data['data']);
    }
    if (dataClassName == 'ExtractionMethod') {
      return deserialize<_i54p6pxa.ExtractionMethod>(data['data']);
    }
    if (dataClassName == 'FavoriteSaveResult') {
      return deserialize<_i73spzup.FavoriteSaveResult>(data['data']);
    }
    if (dataClassName == 'Ingredient') {
      return deserialize<_ihnk7xbr.Ingredient>(data['data']);
    }
    if (dataClassName == 'IngredientDraft') {
      return deserialize<_idpdlwt4.IngredientDraft>(data['data']);
    }
    if (dataClassName == 'Recipe') {
      return deserialize<_izkawori.Recipe>(data['data']);
    }
    if (dataClassName == 'RecipeAccess') {
      return deserialize<_i99euqmx.RecipeAccess>(data['data']);
    }
    if (dataClassName == 'RecipeDetail') {
      return deserialize<_ijpoq8bv.RecipeDetail>(data['data']);
    }
    if (dataClassName == 'RecipeDraft') {
      return deserialize<_iy437pkv.RecipeDraft>(data['data']);
    }
    if (dataClassName == 'RecipeFavorite') {
      return deserialize<_i76c0bzt.RecipeFavorite>(data['data']);
    }
    if (dataClassName == 'RecipeFlavorTag') {
      return deserialize<_ij3iqvmk.RecipeFlavorTag>(data['data']);
    }
    if (dataClassName == 'RecipeInstruction') {
      return deserialize<_id0mij74.RecipeInstruction>(data['data']);
    }
    if (dataClassName == 'RecipePhoto') {
      return deserialize<_i9xtdqqg.RecipePhoto>(data['data']);
    }
    if (dataClassName == 'RoastLevel') {
      return deserialize<_ilmoykyi.RoastLevel>(data['data']);
    }
    if (dataClassName == 'TeamRecipeFavorite') {
      return deserialize<_intarog7.TeamRecipeFavorite>(data['data']);
    }
    if (dataClassName == 'UploadTicket') {
      return deserialize<_ivpdymeq.UploadTicket>(data['data']);
    }
    if (dataClassName == 'InviteLink') {
      return deserialize<_ih3460lx.InviteLink>(data['data']);
    }
    if (dataClassName == 'Team') {
      return deserialize<_im6wd3ml.Team>(data['data']);
    }
    if (dataClassName == 'TeamInvite') {
      return deserialize<_ixubbi3v.TeamInvite>(data['data']);
    }
    if (dataClassName == 'TeamMembership') {
      return deserialize<_it1ysroj.TeamMembership>(data['data']);
    }
    if (dataClassName == 'TeamRole') {
      return deserialize<_i8uq5mqx.TeamRole>(data['data']);
    }
    if (dataClassName == 'TeamSummary') {
      return deserialize<_i5r78mbx.TeamSummary>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('brewing_journal', this);
    _iacs.Protocol().registerHostProtocol('brewing_journal', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ihnk7xbr.Ingredient:
        return _ihnk7xbr.Ingredient.t;
      case _izkawori.Recipe:
        return _izkawori.Recipe.t;
      case _i76c0bzt.RecipeFavorite:
        return _i76c0bzt.RecipeFavorite.t;
      case _ij3iqvmk.RecipeFlavorTag:
        return _ij3iqvmk.RecipeFlavorTag.t;
      case _id0mij74.RecipeInstruction:
        return _id0mij74.RecipeInstruction.t;
      case _i9xtdqqg.RecipePhoto:
        return _i9xtdqqg.RecipePhoto.t;
      case _intarog7.TeamRecipeFavorite:
        return _intarog7.TeamRecipeFavorite.t;
      case _im6wd3ml.Team:
        return _im6wd3ml.Team.t;
      case _ixubbi3v.TeamInvite:
        return _ixubbi3v.TeamInvite.t;
      case _it1ysroj.TeamMembership:
        return _it1ysroj.TeamMembership.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'brewing_journal';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
