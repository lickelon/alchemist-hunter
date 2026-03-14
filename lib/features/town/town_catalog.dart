import 'package:alchemist_hunter/features/town/data/catalogs/equipment_blueprints.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_equipment_blueprint_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/equipment_blueprint_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<ShopCatalogRepository> shopCatalogRepositoryProvider =
    Provider<ShopCatalogRepository>(
      (Ref ref) => const StaticShopCatalogRepository(),
    );

final Provider<EquipmentBlueprintRepository>
equipmentBlueprintRepositoryProvider = Provider<EquipmentBlueprintRepository>(
  (Ref ref) => const StaticEquipmentBlueprintRepository(),
);

final Provider<MercenaryTemplateRepository>
mercenaryTemplateRepositoryProvider = Provider<MercenaryTemplateRepository>(
  (Ref ref) => const StaticMercenaryTemplateRepository(),
);

final Provider<List<EquipmentBlueprint>> townEquipmentBlueprintsProvider =
    Provider<List<EquipmentBlueprint>>((Ref ref) {
      return ref.watch(equipmentBlueprintRepositoryProvider).blueprints();
    });

final Provider<Map<String, String>> townEquipmentMaterialNamesProvider =
    Provider<Map<String, String>>((Ref ref) => townEquipmentMaterialNames);
