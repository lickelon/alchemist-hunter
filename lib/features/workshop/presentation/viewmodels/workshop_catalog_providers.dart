import 'package:alchemist_hunter/features/workshop/data/catalogs/extraction_profiles.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/potion_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<List<MaterialEntity>> materialsProvider =
    Provider<List<MaterialEntity>>((Ref ref) => materialCatalog);

final Provider<List<PotionBlueprint>> potionsProvider =
    Provider<List<PotionBlueprint>>((Ref ref) => potionCatalog);

final Provider<List<TraitUnit>> traitsProvider =
    Provider<List<TraitUnit>>((Ref ref) => traitCatalog);

final Provider<List<ExtractionProfile>> extractionProfilesProvider =
    Provider<List<ExtractionProfile>>((Ref ref) => extractionProfileCatalog);
