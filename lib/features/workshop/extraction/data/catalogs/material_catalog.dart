import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/promotion_material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/source_material_catalog.dart';

export 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/trait_catalog.dart';

final List<MaterialEntity> materialCatalog = <MaterialEntity>[
  ...sourceMaterialCatalog,
  ...promotionMaterialCatalog,
];
