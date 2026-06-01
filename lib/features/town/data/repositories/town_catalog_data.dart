import 'package:alchemist_hunter/features/town/domain/models.dart';

class TownCatalogAssets {
  const TownCatalogAssets({
    required this.shopCatalog,
    required this.equipmentBlueprints,
    required this.equipmentMaterialNames,
    required this.mercenaryTemplates,
    required this.skillNodes,
  });

  final ShopCatalogData shopCatalog;
  final List<EquipmentBlueprint> equipmentBlueprints;
  final Map<String, String> equipmentMaterialNames;
  final List<MercenaryTemplate> mercenaryTemplates;
  final List<TownSkillNode> skillNodes;
}

class ShopCatalogData {
  const ShopCatalogData({required this.general, required this.catalyst});

  final ShopDefinitionData general;
  final ShopDefinitionData catalyst;
}

class ShopDefinitionData {
  const ShopDefinitionData({
    required this.shopType,
    required this.seedItems,
    required this.refreshInterval,
    required this.purchaseLimitPerItem,
    required this.baseRefreshCost,
    required this.refreshCostStep,
  });

  final ShopType shopType;
  final List<ShopItem> seedItems;
  final Duration refreshInterval;
  final int purchaseLimitPerItem;
  final int baseRefreshCost;
  final int refreshCostStep;

  ShopState createState(DateTime now) {
    return ShopState(
      shopType: shopType,
      items: seedItems
          .map(
            (ShopItem item) => ShopItem(
              materialId: item.materialId,
              name: item.name,
              price: item.price,
              quantity: item.quantity,
            ),
          )
          .toList(growable: false),
      nextRefreshAt: now.add(refreshInterval),
      refreshInterval: refreshInterval,
      purchaseLimitPerItem: purchaseLimitPerItem,
      forcedRefreshCost: baseRefreshCost,
      baseRefreshCost: baseRefreshCost,
      refreshCostStep: refreshCostStep,
      cycleRefreshCount: 0,
    );
  }
}
