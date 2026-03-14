import '../models.dart';

abstract interface class ShopCatalogRepository {
  List<ShopItem> generalSeedItems();

  List<ShopItem> catalystSeedItems();

  ShopState createGeneralShopState(DateTime now);

  ShopState createCatalystShopState(DateTime now);
}
