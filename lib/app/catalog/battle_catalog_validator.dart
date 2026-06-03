import 'package:alchemist_hunter/app/catalog/catalog_validation_helpers.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';

void validateBattleCatalog(BattleCatalogTables catalog) {
  requireUnique('battle stage catalog order', catalog.stageCatalog);
  requireNonEmpty('battle stage catalog order', catalog.stageCatalog);
}
