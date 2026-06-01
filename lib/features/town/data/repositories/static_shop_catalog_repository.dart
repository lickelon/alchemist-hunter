import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_data.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';

class StaticShopCatalogRepository implements ShopCatalogRepository {
  const StaticShopCatalogRepository({required ShopCatalogData catalog})
    : _catalog = catalog;

  final ShopCatalogData _catalog;

  @override
  List<ShopItem> catalystSeedItems() => _catalog.catalyst.seedItems;

  @override
  ShopState createCatalystShopState(DateTime now) =>
      _catalog.catalyst.createState(now);

  @override
  List<ShopItem> generalSeedItems() => _catalog.general.seedItems;

  @override
  ShopState createGeneralShopState(DateTime now) =>
      _catalog.general.createState(now);
}
