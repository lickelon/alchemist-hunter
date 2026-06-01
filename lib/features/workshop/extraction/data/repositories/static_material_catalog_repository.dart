import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';

class StaticMaterialCatalogRepository implements MaterialCatalogRepository {
  const StaticMaterialCatalogRepository({
    required List<MaterialEntity> materials,
    required List<TraitUnit> traits,
  }) : _materials = materials,
       _traits = traits;

  final List<MaterialEntity> _materials;
  final List<TraitUnit> _traits;

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
