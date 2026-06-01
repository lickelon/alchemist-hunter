import 'battle_stage_definitions.dart' as stage_catalog;
import 'encounters/battle_enemy_set_definitions.dart' as encounter_catalog;
import 'enemies/battle_enemy_definitions.dart' as enemy_catalog;
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';

final BattleCatalogTables battleCatalogTables = BattleCatalogTables.fromDtos(
  enemyDtos: enemy_catalog.battleEnemyDefinitionDtos,
  enemySetDtos: encounter_catalog.battleEnemySetDefinitionDtos,
  stageDtos: stage_catalog.battleStageDefinitionDtos,
  stageCatalog: stage_catalog.stageCatalog,
);

final Map<String, BattleEnemyDefinition> battleEnemyDefinitions =
    battleCatalogTables.enemyDefinitions;

final Map<String, BattleEnemySetDefinition> battleEnemySetDefinitions =
    battleCatalogTables.enemySetDefinitions;

final Map<String, BattleStageDefinition> battleStageDefinitions =
    battleCatalogTables.stageDefinitions;

List<String> get stageCatalog => battleCatalogTables.stageCatalog;

BattleStageDefinition stageDefinition(String stageId) {
  return battleCatalogTables.stageDefinition(stageId);
}

BattleEnemySetDefinition enemySetDefinition(String enemySetId) {
  return battleCatalogTables.enemySetDefinition(enemySetId);
}

List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
  String stageId,
) {
  return battleCatalogTables.encounterDefinitionsForStage(stageId);
}

List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId) {
  return battleCatalogTables.enemyDefinitionsForSet(enemySetId);
}

List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) {
  return battleCatalogTables.enemyDefinitionsForStage(stageId);
}

BattleDropTable dropTableForEnemySet({
  required String stageId,
  required String enemySetId,
}) {
  return battleCatalogTables.dropTableForEnemySet(
    stageId: stageId,
    enemySetId: enemySetId,
  );
}

BattleDropTable stageDropTable(String stageId) {
  return battleCatalogTables.stageDropTable(stageId);
}
