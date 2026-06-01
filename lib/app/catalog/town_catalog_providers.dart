import 'package:alchemist_hunter/features/town/data/catalogs/equipment_blueprints.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_equipment_blueprint_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/equipment_blueprint_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<ShopCatalogRepository> shopCatalogRepositoryProvider =
    Provider<ShopCatalogRepository>(
      (Ref ref) => StaticShopCatalogRepository(
        catalog: ref.watch(townCatalogAssetsProvider)?.shopCatalog,
      ),
    );

final Provider<EquipmentBlueprintRepository>
equipmentBlueprintRepositoryProvider = Provider<EquipmentBlueprintRepository>(
  (Ref ref) => StaticEquipmentBlueprintRepository(
    blueprints: ref.watch(townCatalogAssetsProvider)?.equipmentBlueprints,
  ),
);

final Provider<MercenaryTemplateRepository>
mercenaryTemplateRepositoryProvider = Provider<MercenaryTemplateRepository>(
  (Ref ref) => StaticMercenaryTemplateRepository(
    templates: ref.watch(townCatalogAssetsProvider)?.mercenaryTemplates,
  ),
);

final Provider<TownSkillTreeRepository> townSkillTreeRepositoryProvider =
    Provider<TownSkillTreeRepository>(
      (Ref ref) => StaticTownSkillTreeRepository(
        nodes: ref.watch(townCatalogAssetsProvider)?.skillNodes,
      ),
    );

final Provider<List<EquipmentBlueprint>> townEquipmentBlueprintsProvider =
    Provider<List<EquipmentBlueprint>>((Ref ref) {
      return ref.watch(equipmentBlueprintRepositoryProvider).blueprints();
    });

final Provider<Map<String, String>> townEquipmentMaterialNamesProvider =
    Provider<Map<String, String>>(
      (Ref ref) =>
          ref.watch(townCatalogAssetsProvider)?.equipmentMaterialNames ??
          townEquipmentMaterialNames,
    );

final Provider<TownCatalogAssets?> townCatalogAssetsProvider =
    Provider<TownCatalogAssets?>((Ref ref) => null);

final Provider<List<TownSkillNode>> townSkillNodesProvider =
    Provider<List<TownSkillNode>>((Ref ref) {
      return ref.watch(townSkillTreeRepositoryProvider).nodes();
    });
