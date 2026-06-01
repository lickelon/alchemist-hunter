part of 'town_catalog_asset_loader.dart';

mixin _TownShopCatalogParserMixin {
  ShopCatalogData readShopCatalog(Map<String, Object?> json) {
    return ShopCatalogData(
      general: readShopDefinition(
        j.readObject(json, 'general'),
        ShopType.general,
      ),
      catalyst: readShopDefinition(
        j.readObject(json, 'catalyst'),
        ShopType.catalyst,
      ),
    );
  }

  ShopDefinitionData readShopDefinition(
    Map<String, Object?> json,
    ShopType shopType,
  ) {
    return ShopDefinitionData(
      shopType: shopType,
      seedItems: j
          .readObjectList(json, 'items')
          .map(readShopItem)
          .toList(growable: false),
      refreshInterval: Duration(
        seconds: j.readInt(json, 'refreshIntervalSeconds'),
      ),
      purchaseLimitPerItem: j.readInt(json, 'purchaseLimitPerItem'),
      baseRefreshCost: j.readInt(json, 'baseRefreshCost'),
      refreshCostStep: j.readInt(json, 'refreshCostStep'),
    );
  }

  ShopItem readShopItem(Map<String, Object?> json) {
    return ShopItem(
      materialId: j.readString(json, 'materialId'),
      name: j.readString(json, 'name'),
      price: j.readInt(json, 'price'),
      quantity: j.readInt(json, 'quantity'),
    );
  }
}
