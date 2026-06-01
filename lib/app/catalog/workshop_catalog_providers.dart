import 'package:alchemist_hunter/features/workshop/crafting/data/repositories/static_potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/data/repositories/static_workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_asset_loader.dart';
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

final Provider<MaterialCatalogRepository> materialCatalogRepositoryProvider =
    Provider<MaterialCatalogRepository>(
      (Ref ref) => StaticMaterialCatalogRepository(
        catalog: ref.watch(workshopCatalogAssetsProvider),
      ),
    );

final Provider<PotionCatalogRepository> potionCatalogRepositoryProvider =
    Provider<PotionCatalogRepository>(
      (Ref ref) => StaticPotionCatalogRepository(
        catalog: ref.watch(workshopCatalogAssetsProvider),
      ),
    );

final Provider<WorkshopCraftRecipeRepository>
workshopCraftRecipeRepositoryProvider = Provider<WorkshopCraftRecipeRepository>(
  (Ref ref) => StaticWorkshopCraftRecipeRepository(
    catalog: ref.watch(workshopCatalogAssetsProvider),
  ),
);

final Provider<ExtractionProfileRepository>
extractionProfileRepositoryProvider = Provider<ExtractionProfileRepository>(
  (Ref ref) => StaticExtractionProfileRepository(
    catalog: ref.watch(workshopCatalogAssetsProvider),
  ),
);

final Provider<WorkshopSkillTreeRepository>
workshopSkillTreeRepositoryProvider = Provider<WorkshopSkillTreeRepository>(
  (Ref ref) => StaticWorkshopSkillTreeRepository(
    catalog: ref.watch(workshopCatalogAssetsProvider),
  ),
);

final Provider<HomunculusHatchRepository> homunculusHatchRepositoryProvider =
    Provider<HomunculusHatchRepository>(
      (Ref ref) => StaticHomunculusHatchRepository(
        catalog: ref.watch(workshopCatalogAssetsProvider),
      ),
    );

final Provider<WorkshopCatalogAssets?> workshopCatalogAssetsProvider =
    Provider<WorkshopCatalogAssets?>((Ref ref) => null);

final Provider<List<MaterialEntity>> materialsProvider =
    Provider<List<MaterialEntity>>((Ref ref) {
      return ref.watch(materialCatalogRepositoryProvider).materials();
    });

final Provider<List<PotionBlueprint>> potionsProvider =
    Provider<List<PotionBlueprint>>((Ref ref) {
      return ref.watch(potionCatalogRepositoryProvider).potions();
    });

final Provider<List<WorkshopCraftRecipe>> workshopCraftRecipesProvider =
    Provider<List<WorkshopCraftRecipe>>((Ref ref) {
      return ref.watch(workshopCraftRecipeRepositoryProvider).recipes();
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
