import 'package:alchemist_hunter/app/session/session_factory.dart';
import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/app/catalog/battle_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/town_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_providers.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_tables.dart';
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
import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_data.dart';
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

final BattleCatalogRepository testBattleCatalogRepository =
    StaticBattleCatalogRepository(catalog: battleCatalogTables);

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
    StaticMaterialCatalogRepository(catalog: testWorkshopCatalogAssets);

final ExtractionProfileRepository testExtractionProfileRepository =
    StaticExtractionProfileRepository(catalog: testWorkshopCatalogAssets);

final PotionCatalogRepository testPotionCatalogRepository =
    StaticPotionCatalogRepository(catalog: testWorkshopCatalogAssets);

final WorkshopCraftRecipeRepository testWorkshopCraftRecipeRepository =
    StaticWorkshopCraftRecipeRepository(catalog: testWorkshopCatalogAssets);

final WorkshopSkillTreeRepository testWorkshopSkillTreeRepository =
    StaticWorkshopSkillTreeRepository(catalog: testWorkshopCatalogAssets);

final HomunculusHatchRepository testHomunculusHatchRepository =
    StaticHomunculusHatchRepository(catalog: testWorkshopCatalogAssets);

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
