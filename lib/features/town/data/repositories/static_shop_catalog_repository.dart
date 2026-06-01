import 'package:alchemist_hunter/features/town/data/catalogs/shop_seed.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';

class StaticShopCatalogRepository implements ShopCatalogRepository {
  const StaticShopCatalogRepository({ShopCatalogData? catalog})
    : _catalog = catalog;

  final ShopCatalogData? _catalog;

  @override
  List<ShopItem> catalystSeedItems() =>
      _catalog?.catalyst.seedItems ?? buildCatalystShopSeedItems();

  @override
  ShopState createCatalystShopState(DateTime now) =>
      _catalog?.catalyst.createState(now) ?? buildCatalystShopState(now);

  @override
  List<ShopItem> generalSeedItems() =>
      _catalog?.general.seedItems ?? buildGeneralShopSeedItems();

  @override
  ShopState createGeneralShopState(DateTime now) =>
      _catalog?.general.createState(now) ?? buildGeneralShopState(now);
}
