import 'package:alchemist_hunter/features/battle/data/catalogs/battle_tables.dart'
    as tables;
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';

class StaticBattleCatalogRepository implements BattleCatalogRepository {
  const StaticBattleCatalogRepository();

  @override
  BattleDropTable dropTable(String stageId) => tables.stageDropTable(stageId);

  @override
  List<String> stageCatalog() => tables.stageCatalog;
}
