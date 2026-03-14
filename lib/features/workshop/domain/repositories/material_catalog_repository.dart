import '../models.dart';

abstract interface class MaterialCatalogRepository {
  List<MaterialEntity> materials();

  List<TraitUnit> traits();

  MaterialEntity? findMaterialById(String materialId);

  String? materialName(String materialId);

  TraitUnit? findTraitById(String traitId);
}
