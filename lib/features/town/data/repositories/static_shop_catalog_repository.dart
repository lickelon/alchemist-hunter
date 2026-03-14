import 'package:alchemist_hunter/features/town/data/catalogs/shop_seed.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';

class StaticShopCatalogRepository implements ShopCatalogRepository {
  const StaticShopCatalogRepository();

  @override
  List<ShopItem> catalystSeedItems() => buildCatalystShopSeedItems();

  @override
  ShopState createCatalystShopState(DateTime now) => buildCatalystShopState(now);

  @override
  List<ShopItem> generalSeedItems() => buildGeneralShopSeedItems();

  @override
  ShopState createGeneralShopState(DateTime now) => buildGeneralShopState(now);
}
