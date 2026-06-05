import 'dart:convert';
import 'dart:io';

import 'package:alchemist_hunter/app/session/session_factory.dart';
import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/app/catalog/battle_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/town_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_asset_loader.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_data.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_providers.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_enemy_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_stage_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_combat_job_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/combat_passive_effect_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/combat_skill_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/static_battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_equipment_blueprint_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_data.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/equipment_blueprint_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/data/repositories/static_potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/data/repositories/static_workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/repositories/static_extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/repositories/static_material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/data/repositories/static_homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/domain/repositories/homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/data/repositories/static_workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final TownCatalogAssets testTownCatalogAssets = TownCatalogAssets(
  shopCatalog: _readTownShopCatalog(),
  equipmentBlueprints: _readTownEquipmentBlueprints(),
  equipmentMaterialNames: _readTownEquipmentMaterialNames(),
  mercenaryTemplates: _readTownMercenaryTemplates(),
  skillNodes: _readTownSkillNodes(),
);

final WorkshopCatalogAssets testWorkshopCatalogAssets = WorkshopCatalogAssets(
  traits: traitCatalog,
  materials: materialCatalog,
  extractionProfiles: _readWorkshopExtractionProfiles(),
  potions: _readWorkshopPotions(),
  potionRecipeRules: _readWorkshopPotionRecipeRules(),
  potionQualityRule: _readWorkshopPotionQualityRule(),
  craftRecipes: _readWorkshopCraftRecipes(),
  hatchRecipes: _readWorkshopHatchRecipes(),
  skillNodes: _readWorkshopSkillNodes(),
);

final BattleCatalogTables testBattleCatalogTables =
    _loadBattleCatalogTablesFromAssets();

final BattleCatalogRepository testBattleCatalogRepository =
    StaticBattleCatalogRepository(catalog: testBattleCatalogTables);

final ShopCatalogRepository testShopCatalogRepository =
    StaticShopCatalogRepository(catalog: testTownCatalogAssets.shopCatalog);

final EquipmentBlueprintRepository testEquipmentBlueprintRepository =
    StaticEquipmentBlueprintRepository(
      blueprints: testTownCatalogAssets.equipmentBlueprints,
    );

final MercenaryTemplateRepository testMercenaryTemplateRepository =
    StaticMercenaryTemplateRepository(
      templates: testTownCatalogAssets.mercenaryTemplates,
    );

final TownSkillTreeRepository testTownSkillTreeRepository =
    StaticTownSkillTreeRepository(nodes: testTownCatalogAssets.skillNodes);

final MaterialCatalogRepository testMaterialCatalogRepository =
    StaticMaterialCatalogRepository(
      materials: testWorkshopCatalogAssets.materials,
      traits: testWorkshopCatalogAssets.traits,
    );

final ExtractionProfileRepository testExtractionProfileRepository =
    StaticExtractionProfileRepository(
      profiles: testWorkshopCatalogAssets.extractionProfiles,
    );

final PotionCatalogRepository testPotionCatalogRepository =
    StaticPotionCatalogRepository(
      potions: testWorkshopCatalogAssets.potions,
      recipeRules: testWorkshopCatalogAssets.potionRecipeRules,
      qualityRule: testWorkshopCatalogAssets.potionQualityRule,
    );

final WorkshopCraftRecipeRepository testWorkshopCraftRecipeRepository =
    StaticWorkshopCraftRecipeRepository(
      recipes: testWorkshopCatalogAssets.craftRecipes,
    );

final WorkshopSkillTreeRepository testWorkshopSkillTreeRepository =
    StaticWorkshopSkillTreeRepository(
      nodes: testWorkshopCatalogAssets.skillNodes,
    );

final HomunculusHatchRepository testHomunculusHatchRepository =
    StaticHomunculusHatchRepository(
      recipes: testWorkshopCatalogAssets.hatchRecipes,
    );

InitialSessionCatalogs createTestInitialSessionCatalogs() {
  return InitialSessionCatalogs(
    shopCatalogRepository: testShopCatalogRepository,
    mercenaryTemplateRepository: testMercenaryTemplateRepository,
    townSkillTreeRepository: testTownSkillTreeRepository,
  );
}

SessionState createTestInitialSessionState(DateTime now) {
  final SessionState state = createInitialSessionStateFromCatalogs(
    now,
    createTestInitialSessionCatalogs(),
  );
  return state.copyWith(
    battle: state.battle.copyWith(
      stageAssignments: const <String, List<String>>{
        'stage_1': <String>['merc_1', 'homo_1'],
      },
    ),
    characters: const CharactersState(
      mercenaries: <CharacterProgress>[
        CharacterProgress(
          id: 'merc_1',
          name: 'Rookie Swordsman',
          type: CharacterType.mercenary,
          combatJobId: CombatJobIds.mercenaryWarrior,
          level: 1,
          rank: 1,
          xp: 0,
          mercenaryTier: MercenaryTier.rookie,
        ),
      ],
      homunculi: <CharacterProgress>[
        CharacterProgress(
          id: 'homo_1',
          name: '마법사',
          type: CharacterType.homunculus,
          combatJobId: CombatJobIds.homunculusMage,
          level: 1,
          rank: 1,
          xp: 0,
          homunculusTier: HomunculusTier.nigredo,
        ),
      ],
    ),
  );
}

List<Override> testCatalogProviderOverrides() {
  return <Override>[
    townCatalogAssetsProvider.overrideWithValue(testTownCatalogAssets),
    workshopCatalogAssetsProvider.overrideWithValue(testWorkshopCatalogAssets),
    battleCatalogRepositoryProvider.overrideWithValue(
      testBattleCatalogRepository,
    ),
  ];
}

BattleCatalogTables _loadBattleCatalogTablesFromAssets() {
  return BattleCatalogTables.fromDtos(
    enemyDtos: _readBattleDtoMap(
      _readBattleObjectList('enemies.json'),
      BattleEnemyDefinitionDto.fromJson,
    ),
    enemySetDtos: _readBattleDtoMap(
      _readBattleObjectList('enemy_sets.json'),
      BattleEnemySetDefinitionDto.fromJson,
    ),
    stageDtos: _readBattleDtoMap(
      _readBattleObjectList('stages.json'),
      BattleStageDefinitionDto.fromJson,
    ),
    stageCatalog: _readBattleStringList('stage_catalog.json'),
    combatJobDtos: _readBattleDtoMap(
      _readBattleIndexedObjectList('combat_job_index.json'),
      BattleCombatJobDefinitionDto.fromJson,
    ),
    combatSkillDtos: _readBattleDtoMap(
      _readBattleObjectList('combat_skills.json'),
      BattleSkillDefinitionDto.fromJson,
    ),
    combatPassiveDtos: _readBattleDtoMap(
      _readBattleObjectList('combat_passives.json'),
      BattlePassiveEffectDto.fromJson,
    ),
  );
}

Map<String, T> _readBattleDtoMap<T>(
  List<Map<String, Object?>> entries,
  T Function(Map<String, Object?> json) convert,
) {
  return <String, T>{
    for (final Map<String, Object?> entry in entries)
      _readBattleId(entry): convert(entry),
  };
}

List<Map<String, Object?>> _readBattleIndexedObjectList(String indexFileName) {
  return _readBattleStringList(
    indexFileName,
  ).map(_readBattleObject).toList(growable: false);
}

Map<String, Object?> _readBattleObject(String fileName) {
  final Object? decoded = _readBattleJson(fileName);
  if (decoded is Map<String, Object?>) {
    return decoded;
  }
  throw FormatException('Battle catalog $fileName must be an object');
}

List<Map<String, Object?>> _readBattleObjectList(String fileName) {
  final Object? decoded = _readBattleJson(fileName);
  if (decoded is List<Object?>) {
    return decoded
        .map((Object? entry) {
          if (entry is Map<String, Object?>) {
            return entry;
          }
          throw FormatException(
            'Battle catalog $fileName entry must be object',
          );
        })
        .toList(growable: false);
  }
  throw FormatException('Battle catalog $fileName must be a list');
}

List<String> _readBattleStringList(String fileName) {
  final Object? decoded = _readBattleJson(fileName);
  if (decoded is List<Object?>) {
    return decoded
        .map((Object? entry) {
          if (entry is String) {
            return entry;
          }
          throw FormatException(
            'Battle catalog $fileName entry must be a string',
          );
        })
        .toList(growable: false);
  }
  throw FormatException('Battle catalog $fileName must be a list');
}

Object? _readBattleJson(String fileName) {
  final String source = File('assets/data/battle/$fileName').readAsStringSync();
  return jsonDecode(source);
}

String _readBattleId(Map<String, Object?> json) {
  final Object? value = json['id'];
  if (value is String) {
    return value;
  }
  throw FormatException('Battle catalog entry must define an id: $json');
}

List<MercenaryTemplate> _readTownMercenaryTemplates() {
  return _readTownObjectList('mercenaries.json')
      .map((Map<String, Object?> json) {
        return MercenaryTemplate(
          id: _readString(json, 'id'),
          combatJobId: _readString(json, 'combatJobId'),
          hireCost: _readInt(json, 'hireCost'),
          tierIndex: _readInt(json, 'tierIndex'),
        );
      })
      .toList(growable: false);
}

List<TownSkillNode> _readTownSkillNodes() {
  final TownCatalogAssetLoader loader = TownCatalogAssetLoader();
  return _readTownObjectList(
    'skill_tree.json',
  ).map(loader.readTownSkillNode).toList(growable: false);
}

ShopCatalogData _readTownShopCatalog() {
  final TownCatalogAssetLoader loader = TownCatalogAssetLoader();
  return loader.readShopCatalog(_readTownObject('shops.json'));
}

List<EquipmentBlueprint> _readTownEquipmentBlueprints() {
  final TownCatalogAssetLoader loader = TownCatalogAssetLoader();
  final Map<String, Object?> equipment = _readTownObject('equipment.json');
  return _readObjectList(
    equipment,
    'equipmentBlueprints',
  ).map(loader.readEquipmentBlueprint).toList(growable: false);
}

Map<String, String> _readTownEquipmentMaterialNames() {
  final TownCatalogAssetLoader loader = TownCatalogAssetLoader();
  final Map<String, Object?> equipment = _readTownObject('equipment.json');
  return loader.readStringMap(equipment, 'equipmentMaterialNames');
}

List<HomunculusHatchRecipe> _readWorkshopHatchRecipes() {
  return _readWorkshopObjectList('hatch_recipes.json')
      .map((Map<String, Object?> json) {
        return HomunculusHatchRecipe(
          id: _readString(json, 'id'),
          combatJobId: _readString(json, 'combatJobId'),
          essenceCost: _readInt(json, 'essenceCost'),
          arcaneDustCost: _readInt(json, 'arcaneDustCost'),
          materialCosts: _readIntMap(json, 'materialCosts'),
          traitCosts: _readDoubleMap(json, 'traitCosts'),
          duration: Duration(seconds: _readInt(json, 'durationSeconds')),
        );
      })
      .toList(growable: false);
}

List<PotionBlueprint> _readWorkshopPotions() {
  final WorkshopCatalogAssetLoader loader = WorkshopCatalogAssetLoader();
  return _readWorkshopObjectList(
    'potions.json',
  ).map(loader.readPotion).toList(growable: false);
}

List<PotionRecipeRule> _readWorkshopPotionRecipeRules() {
  final WorkshopCatalogAssetLoader loader = WorkshopCatalogAssetLoader();
  return _readWorkshopObjectList(
    'potion_recipes.json',
  ).map(loader.readPotionRecipeRule).toList(growable: false);
}

PotionQualityRule _readWorkshopPotionQualityRule() {
  final WorkshopCatalogAssetLoader loader = WorkshopCatalogAssetLoader();
  return loader.readPotionQualityRule(
    _readWorkshopObject('potion_quality.json'),
  );
}

List<WorkshopCraftRecipe> _readWorkshopCraftRecipes() {
  final WorkshopCatalogAssetLoader loader = WorkshopCatalogAssetLoader();
  return _readWorkshopObjectList(
    'craft_recipes.json',
  ).map(loader.readCraftRecipe).toList(growable: false);
}

List<ExtractionProfile> _readWorkshopExtractionProfiles() {
  final WorkshopCatalogAssetLoader loader = WorkshopCatalogAssetLoader();
  return _readWorkshopObjectList(
    'extraction_profiles.json',
  ).map(loader.readExtractionProfile).toList(growable: false);
}

List<WorkshopSkillNode> _readWorkshopSkillNodes() {
  final WorkshopCatalogAssetLoader loader = WorkshopCatalogAssetLoader();
  return _readWorkshopObjectList(
    'skill_tree.json',
  ).map(loader.readWorkshopSkillNode).toList(growable: false);
}

Map<String, Object?> _readTownObject(String fileName) {
  final Object? decoded = _readTownJson(fileName);
  if (decoded is Map<String, Object?>) {
    return decoded;
  }
  throw FormatException('Town catalog $fileName must be an object');
}

List<Map<String, Object?>> _readObjectList(
  Map<String, Object?> json,
  String key,
) {
  final Object? value = json[key];
  if (value is List<Object?>) {
    return value
        .map((Object? entry) {
          if (entry is Map<String, Object?>) {
            return entry;
          }
          throw FormatException('Catalog $key entry must be object');
        })
        .toList(growable: false);
  }
  throw FormatException('Catalog $key must be a list');
}

List<Map<String, Object?>> _readTownObjectList(String fileName) {
  final Object? decoded = _readTownJson(fileName);
  if (decoded is List<Object?>) {
    return decoded
        .map((Object? entry) {
          if (entry is Map<String, Object?>) {
            return entry;
          }
          throw FormatException('Town catalog $fileName entry must be object');
        })
        .toList(growable: false);
  }
  throw FormatException('Town catalog $fileName must be a list');
}

Object? _readTownJson(String fileName) {
  final String source = File('assets/data/town/$fileName').readAsStringSync();
  return jsonDecode(source);
}

List<Map<String, Object?>> _readWorkshopObjectList(String fileName) {
  final Object? decoded = _readWorkshopJson(fileName);
  if (decoded is List<Object?>) {
    return decoded
        .map((Object? entry) {
          if (entry is Map<String, Object?>) {
            return entry;
          }
          throw FormatException(
            'Workshop catalog $fileName entry must be object',
          );
        })
        .toList(growable: false);
  }
  throw FormatException('Workshop catalog $fileName must be a list');
}

Map<String, Object?> _readWorkshopObject(String fileName) {
  final Object? decoded = _readWorkshopJson(fileName);
  if (decoded is Map<String, Object?>) {
    return decoded;
  }
  throw FormatException('Workshop catalog $fileName must be an object');
}

Object? _readWorkshopJson(String fileName) {
  final String source = File(
    'assets/data/workshop/$fileName',
  ).readAsStringSync();
  return jsonDecode(source);
}

String _readString(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Expected string $key in $json');
}

int _readInt(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is int) {
    return value;
  }
  throw FormatException('Expected int $key in $json');
}

Map<String, int> _readIntMap(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is Map<String, Object?>) {
    return value.map((String entryKey, Object? entryValue) {
      if (entryValue is int) {
        return MapEntry<String, int>(entryKey, entryValue);
      }
      throw FormatException('Expected int value for $key.$entryKey in $json');
    });
  }
  throw FormatException('Expected int map $key in $json');
}

Map<String, double> _readDoubleMap(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is Map<String, Object?>) {
    return value.map((String entryKey, Object? entryValue) {
      if (entryValue is num) {
        return MapEntry<String, double>(entryKey, entryValue.toDouble());
      }
      throw FormatException(
        'Expected numeric value for $key.$entryKey in $json',
      );
    });
  }
  throw FormatException('Expected double map $key in $json');
}
