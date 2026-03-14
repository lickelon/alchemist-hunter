import 'package:alchemist_hunter/features/town/domain/models.dart';

const List<ShopItem> _generalShopSeedItems = <ShopItem>[
  ShopItem(materialId: 'm_1', name: 'Emberroot', price: 50, quantity: 20),
  ShopItem(materialId: 'm_2', name: 'Ironbloom Bark', price: 50, quantity: 20),
  ShopItem(materialId: 'm_3', name: 'Mossbone', price: 50, quantity: 20),
  ShopItem(materialId: 'm_4', name: 'Gale Petal', price: 50, quantity: 20),
  ShopItem(materialId: 'm_5', name: 'Sunleaf', price: 50, quantity: 20),
  ShopItem(materialId: 'm_6', name: 'Nightsap Resin', price: 50, quantity: 20),
  ShopItem(materialId: 'm_7', name: 'Thornspike Vine', price: 50, quantity: 20),
  ShopItem(materialId: 'm_8', name: 'Dewcap Mushroom', price: 50, quantity: 20),
];

const List<ShopItem> _catalystShopSeedItems = <ShopItem>[
  ShopItem(materialId: 'm_25', name: 'Aether Bloom', price: 180, quantity: 8),
  ShopItem(materialId: 'm_26', name: 'Void Thistle', price: 180, quantity: 8),
  ShopItem(
    materialId: 'm_27',
    name: 'Starfire Pollen',
    price: 180,
    quantity: 8,
  ),
  ShopItem(materialId: 'm_28', name: 'Phantom Moss', price: 180, quantity: 8),
  ShopItem(
    materialId: 'm_29',
    name: 'Dragonbone Shard',
    price: 180,
    quantity: 8,
  ),
  ShopItem(
    materialId: 'm_30',
    name: 'Moontear Crystal',
    price: 180,
    quantity: 8,
  ),
];

List<ShopItem> buildGeneralShopSeedItems() {
  return _generalShopSeedItems
      .map(
        (ShopItem item) => ShopItem(
          materialId: item.materialId,
          name: item.name,
          price: item.price,
          quantity: item.quantity,
        ),
      )
      .toList();
}

List<ShopItem> buildCatalystShopSeedItems() {
  return _catalystShopSeedItems
      .map(
        (ShopItem item) => ShopItem(
          materialId: item.materialId,
          name: item.name,
          price: item.price,
          quantity: item.quantity,
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
