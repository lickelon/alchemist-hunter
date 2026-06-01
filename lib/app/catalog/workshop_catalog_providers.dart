import 'package:alchemist_hunter/app/catalog/workshop_catalog_data.dart';
import 'package:alchemist_hunter/features/workshop/crafting/data/repositories/static_potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/data/repositories/static_workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
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
    Provider<MaterialCatalogRepository>((Ref ref) {
      final WorkshopCatalogAssets catalog = ref.watch(
        workshopCatalogAssetsProvider,
      );
      return StaticMaterialCatalogRepository(
        materials: catalog.materials,
        traits: catalog.traits,
      );
    });

final Provider<PotionCatalogRepository> potionCatalogRepositoryProvider =
    Provider<PotionCatalogRepository>((Ref ref) {
      final WorkshopCatalogAssets catalog = ref.watch(
        workshopCatalogAssetsProvider,
      );
      return StaticPotionCatalogRepository(
        potions: catalog.potions,
        recipeRules: catalog.potionRecipeRules,
        qualityRule: catalog.potionQualityRule,
      );
    });

final Provider<WorkshopCraftRecipeRepository>
workshopCraftRecipeRepositoryProvider = Provider<WorkshopCraftRecipeRepository>(
  (Ref ref) => StaticWorkshopCraftRecipeRepository(
    recipes: ref.watch(workshopCatalogAssetsProvider).craftRecipes,
  ),
);

final Provider<ExtractionProfileRepository>
extractionProfileRepositoryProvider = Provider<ExtractionProfileRepository>(
  (Ref ref) => StaticExtractionProfileRepository(
    profiles: ref.watch(workshopCatalogAssetsProvider).extractionProfiles,
  ),
);

final Provider<WorkshopSkillTreeRepository>
workshopSkillTreeRepositoryProvider = Provider<WorkshopSkillTreeRepository>(
  (Ref ref) => StaticWorkshopSkillTreeRepository(
    nodes: ref.watch(workshopCatalogAssetsProvider).skillNodes,
  ),
);

final Provider<HomunculusHatchRepository> homunculusHatchRepositoryProvider =
    Provider<HomunculusHatchRepository>(
      (Ref ref) => StaticHomunculusHatchRepository(
        recipes: ref.watch(workshopCatalogAssetsProvider).hatchRecipes,
      ),
    );

final Provider<WorkshopCatalogAssets> workshopCatalogAssetsProvider =
    Provider<WorkshopCatalogAssets>(
      (Ref ref) => throw StateError('Workshop catalog assets are not loaded'),
    );

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
