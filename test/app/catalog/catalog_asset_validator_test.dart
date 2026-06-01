import 'package:alchemist_hunter/app/catalog/catalog_asset_validator.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_data.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_asset_loader.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_data.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('runtime catalog assets load and pass validation', () async {
    final BattleCatalogTables battle = await const BattleCatalogAssetLoader()
        .load(rootBundle);
    final TownCatalogAssets town = await const TownCatalogAssetLoader().load(
      rootBundle,
    );
    final WorkshopCatalogAssets workshop =
        await const WorkshopCatalogAssetLoader().load(rootBundle);

    expect(
      () =>
          validateCatalogAssets(battle: battle, town: town, workshop: workshop),
      returnsNormally,
    );
  });
}
