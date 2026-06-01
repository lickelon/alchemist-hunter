import 'package:alchemist_hunter/features/battle/data/catalogs/battle_tables.dart'
    as tables;
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';

class StaticBattleCatalogRepository implements BattleCatalogRepository {
  const StaticBattleCatalogRepository({tables.BattleCatalogTables? catalog})
    : _catalog = catalog;

  final tables.BattleCatalogTables? _catalog;

  tables.BattleCatalogTables get _tables =>
      _catalog ?? tables.battleCatalogTables;

  @override
  List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
    String stageId,
  ) => _tables.encounterDefinitionsForStage(stageId);

  @override
  BattleDropTable dropTable(String stageId) => _tables.stageDropTable(stageId);

  @override
  BattleDropTable dropTableForEnemySet({
    required String stageId,
    required String enemySetId,
  }) => _tables.dropTableForEnemySet(stageId: stageId, enemySetId: enemySetId);

  @override
  List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) =>
      _tables.enemyDefinitionsForStage(stageId);

  @override
  List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId) =>
      _tables.enemyDefinitionsForSet(enemySetId);

  @override
  BattleStageDefinition stageDefinition(String stageId) =>
      _tables.stageDefinition(stageId);

  @override
  List<String> stageCatalog() => _tables.stageCatalog;
}
