import '../models.dart';

abstract interface class BattleCatalogRepository {
  List<String> stageCatalog();

  BattleStageDefinition stageDefinition(String stageId);

  List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
    String stageId,
  );

  List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId);

  List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId);

  BattleDropTable dropTable(String stageId);

  BattleDropTable dropTableForEnemySet({
    required String stageId,
    required String enemySetId,
  });
}
