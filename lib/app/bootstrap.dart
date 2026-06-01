import 'package:alchemist_hunter/app/app.dart';
import 'package:alchemist_hunter/app/catalog/battle_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/town_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_providers.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/static_battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_asset_loader.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final battleCatalog = await const BattleCatalogAssetLoader().load(rootBundle);
  final townCatalog = await const TownCatalogAssetLoader().load(rootBundle);
  final workshopCatalog = await const WorkshopCatalogAssetLoader().load(
    rootBundle,
  );
  runApp(
    ProviderScope(
      overrides: <Override>[
        townCatalogAssetsProvider.overrideWithValue(townCatalog),
        workshopCatalogAssetsProvider.overrideWithValue(workshopCatalog),
        battleCatalogRepositoryProvider.overrideWithValue(
          StaticBattleCatalogRepository(catalog: battleCatalog),
        ),
      ],
      child: const App(),
    ),
  );
}
