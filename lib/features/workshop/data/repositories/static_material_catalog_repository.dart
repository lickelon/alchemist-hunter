import 'package:alchemist_hunter/features/workshop/data/catalogs/material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/material_catalog_repository.dart';

class StaticMaterialCatalogRepository implements MaterialCatalogRepository {
  const StaticMaterialCatalogRepository();

  @override
  MaterialEntity? findMaterialById(String materialId) {
    return materialCatalog
        .where((MaterialEntity material) => material.id == materialId)
        .firstOrNull;
  }

  @override
  TraitUnit? findTraitById(String traitId) {
    return traitCatalog
        .where((TraitUnit trait) => trait.id == traitId)
        .firstOrNull;
  }

  @override
  String? materialName(String materialId) => findMaterialById(materialId)?.name;

  @override
  List<MaterialEntity> materials() => materialCatalog;

  @override
  List<TraitUnit> traits() => traitCatalog;
}
