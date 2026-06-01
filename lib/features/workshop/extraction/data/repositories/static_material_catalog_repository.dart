import 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';

class StaticMaterialCatalogRepository implements MaterialCatalogRepository {
  const StaticMaterialCatalogRepository({WorkshopCatalogAssets? catalog})
    : _catalog = catalog;

  final WorkshopCatalogAssets? _catalog;

  List<MaterialEntity> get _materials => _catalog?.materials ?? materialCatalog;

  List<TraitUnit> get _traits => _catalog?.traits ?? traitCatalog;

  @override
  MaterialEntity? findMaterialById(String materialId) {
    return _materials
        .where((MaterialEntity material) => material.id == materialId)
        .firstOrNull;
  }

  @override
  TraitUnit? findTraitById(String traitId) {
    return _traits.where((TraitUnit trait) => trait.id == traitId).firstOrNull;
  }

  @override
  String? materialName(String materialId) => findMaterialById(materialId)?.name;

  @override
  List<MaterialEntity> materials() => _materials;

  @override
  List<TraitUnit> traits() => _traits;
}
