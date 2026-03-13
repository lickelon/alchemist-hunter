import 'package:alchemist_hunter/features/workshop/data/catalog/material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

List<ShopItem> buildGeneralShopSeedItems() {
  return materialCatalog
      .where((MaterialEntity material) => material.source == 'general_shop')
      .take(8)
      .map(
        (MaterialEntity material) => ShopItem(
          materialId: material.id,
          name: material.name,
          price: 50,
          quantity: 20,
        ),
      )
      .toList();
}

List<ShopItem> buildCatalystShopSeedItems() {
  return materialCatalog
      .skip(24)
      .take(6)
      .map(
        (MaterialEntity material) => ShopItem(
          materialId: material.id,
          name: material.name,
          price: 180,
          quantity: 8,
        ),
      )
      .toList();
}

ShopState buildGeneralShopState(DateTime now) {
  return ShopState(
    shopType: ShopType.general,
    items: buildGeneralShopSeedItems(),
    nextRefreshAt: now.add(const Duration(minutes: 15)),
    forcedRefreshCost: 25,
    baseRefreshCost: 25,
    refreshCostStep: 15,
    cycleRefreshCount: 0,
  );
}

ShopState buildCatalystShopState(DateTime now) {
  return ShopState(
    shopType: ShopType.catalyst,
    items: buildCatalystShopSeedItems(),
    nextRefreshAt: now.add(const Duration(minutes: 30)),
    forcedRefreshCost: 90,
    baseRefreshCost: 90,
    refreshCostStep: 45,
    cycleRefreshCount: 0,
  );
}
