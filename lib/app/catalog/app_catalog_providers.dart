import 'package:alchemist_hunter/features/battle/data/repositories/static_battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/equipment_blueprints.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_equipment_blueprint_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/equipment_blueprint_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/data/repositories/static_potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/repositories/static_extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/repositories/static_material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/data/repositories/static_homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/domain/repositories/homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/data/repositories/static_workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<BattleCatalogRepository> battleCatalogRepositoryProvider =
    Provider<BattleCatalogRepository>(
      (Ref ref) => const StaticBattleCatalogRepository(),
    );

final Provider<List<String>> stageCatalogProvider = Provider<List<String>>(
  (Ref ref) => ref.watch(battleCatalogRepositoryProvider).stageCatalog(),
);

final Provider<ShopCatalogRepository> shopCatalogRepositoryProvider =
    Provider<ShopCatalogRepository>(
      (Ref ref) => const StaticShopCatalogRepository(),
    );

final Provider<EquipmentBlueprintRepository>
equipmentBlueprintRepositoryProvider = Provider<EquipmentBlueprintRepository>(
  (Ref ref) => const StaticEquipmentBlueprintRepository(),
);

final Provider<MercenaryTemplateRepository>
mercenaryTemplateRepositoryProvider = Provider<MercenaryTemplateRepository>(
  (Ref ref) => const StaticMercenaryTemplateRepository(),
);

final Provider<TownSkillTreeRepository> townSkillTreeRepositoryProvider =
    Provider<TownSkillTreeRepository>(
      (Ref ref) => const StaticTownSkillTreeRepository(),
    );

final Provider<List<EquipmentBlueprint>> townEquipmentBlueprintsProvider =
    Provider<List<EquipmentBlueprint>>((Ref ref) {
      return ref.watch(equipmentBlueprintRepositoryProvider).blueprints();
    });

final Provider<Map<String, String>> townEquipmentMaterialNamesProvider =
    Provider<Map<String, String>>((Ref ref) => townEquipmentMaterialNames);

final Provider<List<TownSkillNode>> townSkillNodesProvider =
    Provider<List<TownSkillNode>>((Ref ref) {
      return ref.watch(townSkillTreeRepositoryProvider).nodes();
    });

final Provider<MaterialCatalogRepository> materialCatalogRepositoryProvider =
    Provider<MaterialCatalogRepository>(
      (Ref ref) => const StaticMaterialCatalogRepository(),
    );

final Provider<PotionCatalogRepository> potionCatalogRepositoryProvider =
    Provider<PotionCatalogRepository>(
      (Ref ref) => const StaticPotionCatalogRepository(),
    );

final Provider<ExtractionProfileRepository>
extractionProfileRepositoryProvider = Provider<ExtractionProfileRepository>(
  (Ref ref) => const StaticExtractionProfileRepository(),
);

final Provider<WorkshopSkillTreeRepository>
workshopSkillTreeRepositoryProvider = Provider<WorkshopSkillTreeRepository>(
  (Ref ref) => const StaticWorkshopSkillTreeRepository(),
);

final Provider<HomunculusHatchRepository> homunculusHatchRepositoryProvider =
    Provider<HomunculusHatchRepository>(
      (Ref ref) => const StaticHomunculusHatchRepository(),
    );

final Provider<List<MaterialEntity>> materialsProvider =
    Provider<List<MaterialEntity>>((Ref ref) {
      return ref.watch(materialCatalogRepositoryProvider).materials();
    });

final Provider<List<PotionBlueprint>> potionsProvider =
    Provider<List<PotionBlueprint>>((Ref ref) {
      return ref.watch(potionCatalogRepositoryProvider).potions();
    });

final Provider<List<TraitUnit>> traitsProvider = Provider<List<TraitUnit>>((
  Ref ref,
) {
  return ref.watch(materialCatalogRepositoryProvider).traits();
});

final Provider<List<ExtractionProfile>> extractionProfilesProvider =
    Provider<List<ExtractionProfile>>((Ref ref) {
      return ref.watch(extractionProfileRepositoryProvider).profiles();
    });

final Provider<List<WorkshopSkillNode>> workshopSkillNodesProvider =
    Provider<List<WorkshopSkillNode>>((Ref ref) {
      return ref.watch(workshopSkillTreeRepositoryProvider).nodes();
    });

final Provider<List<HomunculusHatchRecipe>> homunculusHatchRecipesProvider =
    Provider<List<HomunculusHatchRecipe>>((Ref ref) {
      return ref.watch(homunculusHatchRepositoryProvider).recipes();
    });
