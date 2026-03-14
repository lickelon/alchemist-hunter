import 'package:alchemist_hunter/features/workshop/data/repositories/static_extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';
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

final Provider<List<MaterialEntity>> materialsProvider =
    Provider<List<MaterialEntity>>((Ref ref) {
      return ref.watch(materialCatalogRepositoryProvider).materials();
    });

final Provider<List<PotionBlueprint>> potionsProvider =
    Provider<List<PotionBlueprint>>((Ref ref) {
      return ref.watch(potionCatalogRepositoryProvider).potions();
    });

final Provider<List<TraitUnit>> traitsProvider =
    Provider<List<TraitUnit>>((Ref ref) {
      return ref.watch(materialCatalogRepositoryProvider).traits();
    });

final Provider<List<ExtractionProfile>> extractionProfilesProvider =
    Provider<List<ExtractionProfile>>((Ref ref) {
      return ref.watch(extractionProfileRepositoryProvider).profiles();
    });
