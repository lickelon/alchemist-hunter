part of 'battle_catalog_tables.dart';

BattleCatalogTables _battleCatalogTablesFromDtos({
  required Map<String, BattleEnemyDefinitionDto> enemyDtos,
  required Map<String, BattleEnemySetDefinitionDto> enemySetDtos,
  required Map<String, BattleStageDefinitionDto> stageDtos,
  required List<String> stageCatalog,
}) {
  return BattleCatalogTables(
    enemyDefinitions: enemyDtos.map(
      (String id, BattleEnemyDefinitionDto definition) =>
          MapEntry<String, BattleEnemyDefinition>(id, definition.toDomain()),
    ),
    enemySetDefinitions: enemySetDtos.map(
      (String id, BattleEnemySetDefinitionDto definition) =>
          MapEntry<String, BattleEnemySetDefinition>(id, definition.toDomain()),
    ),
    stageDefinitions: stageDtos.map(
      (String id, BattleStageDefinitionDto definition) =>
          MapEntry<String, BattleStageDefinition>(id, definition.toDomain()),
    ),
    stageCatalog: List<String>.unmodifiable(stageCatalog),
  );
}
