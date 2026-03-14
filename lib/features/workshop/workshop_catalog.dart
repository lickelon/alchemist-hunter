import 'package:alchemist_hunter/features/workshop/data/repositories/static_extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final Provider<WorkshopSkillTreeRepository> workshopSkillTreeRepositoryProvider =
    Provider<WorkshopSkillTreeRepository>(
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
