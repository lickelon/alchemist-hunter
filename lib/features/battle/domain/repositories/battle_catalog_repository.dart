import '../models.dart';

abstract interface class BattleCatalogRepository {
  List<String> stageCatalog();

  BattleStageDefinition stageDefinition(String stageId);

  List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId);

  BattleDropTable dropTable(String stageId);
}
