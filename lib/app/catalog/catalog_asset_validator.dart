import 'package:alchemist_hunter/app/catalog/battle_catalog_validator.dart';
import 'package:alchemist_hunter/app/catalog/town_catalog_validator.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_data.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_validator.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_data.dart';

void validateCatalogAssets({
  required BattleCatalogTables battle,
  required TownCatalogAssets town,
  required WorkshopCatalogAssets workshop,
}) {
  validateBattleCatalog(battle);
  validateWorkshopCatalog(workshop);
  validateTownCatalog(town, workshop);
}
