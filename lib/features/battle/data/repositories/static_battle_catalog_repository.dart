import 'package:alchemist_hunter/features/battle/data/catalogs/battle_tables.dart'
    as tables;
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';

class StaticBattleCatalogRepository implements BattleCatalogRepository {
  const StaticBattleCatalogRepository();

  @override
  List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
    String stageId,
  ) => tables.encounterDefinitionsForStage(stageId);

  @override
  BattleDropTable dropTable(String stageId) => tables.stageDropTable(stageId);

  @override
  BattleDropTable dropTableForEnemySet({
    required String stageId,
    required String enemySetId,
  }) => tables.dropTableForEnemySet(stageId: stageId, enemySetId: enemySetId);

  @override
  List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) =>
      tables.enemyDefinitionsForStage(stageId);

  @override
  List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId) =>
      tables.enemyDefinitionsForSet(enemySetId);

  @override
  BattleStageDefinition stageDefinition(String stageId) =>
      tables.stageDefinition(stageId);

  @override
  List<String> stageCatalog() => tables.stageCatalog;
}
