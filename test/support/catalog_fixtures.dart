import 'dart:convert';
import 'dart:io';

import 'package:alchemist_hunter/app/session/session_factory.dart';
import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/app/catalog/battle_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/town_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_data.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_providers.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_catalog_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/static_battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/equipment_blueprints.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/mercenary_templates.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/shop_seed.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/town_skill_nodes.dart';
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
import 'package:alchemist_hunter/features/workshop/crafting/data/catalogs/potion_catalog.dart';
import 'package:alchemist_hunter/features/workshop/crafting/data/catalogs/workshop_craft_recipes.dart';
import 'package:alchemist_hunter/features/workshop/crafting/data/repositories/static_potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/data/repositories/static_workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/extraction_profiles.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/repositories/static_extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/repositories/static_material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/data/catalogs/homunculus_hatch_recipes.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/data/repositories/static_homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/domain/repositories/homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/data/catalogs/workshop_skill_nodes.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/data/repositories/static_workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final TownCatalogAssets testTownCatalogAssets = TownCatalogAssets(
  shopCatalog: ShopCatalogData(
    general: _shopDefinition(buildGeneralShopState(DateTime(2026))),
    catalyst: _shopDefinition(buildCatalystShopState(DateTime(2026))),
  ),
  equipmentBlueprints: townEquipmentBlueprints,
  equipmentMaterialNames: townEquipmentMaterialNames,
  mercenaryTemplates: mercenaryTemplates,
  skillNodes: townSkillNodes,
);

final WorkshopCatalogAssets testWorkshopCatalogAssets = WorkshopCatalogAssets(
  traits: traitCatalog,
  materials: materialCatalog,
  extractionProfiles: extractionProfileCatalog,
  potions: potionCatalog,
  potionRecipeRules: potionRecipeCatalog,
  potionQualityRule: potionQualityCatalog,
  craftRecipes: workshopCraftRecipes,
  hatchRecipes: homunculusHatchRecipes,
  skillNodes: workshopSkillNodes,
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
  return createInitialSessionStateFromCatalogs(
    now,
    createTestInitialSessionCatalogs(),
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

ShopDefinitionData _shopDefinition(ShopState state) {
  return ShopDefinitionData(
    shopType: state.shopType,
    seedItems: state.items,
    refreshInterval: state.refreshInterval,
    purchaseLimitPerItem: state.purchaseLimitPerItem,
    baseRefreshCost: state.baseRefreshCost,
    refreshCostStep: state.refreshCostStep,
  );
}
