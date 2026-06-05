part of 'battle_catalog_tables.dart';

BattleCatalogTables _battleCatalogTablesFromDtos({
  required Map<String, BattleEnemyDefinitionDto> enemyDtos,
  required Map<String, BattleEnemySetDefinitionDto> enemySetDtos,
  required Map<String, BattleStageDefinitionDto> stageDtos,
  required List<String> stageCatalog,
  required Map<String, BattleCombatJobDefinitionDto> combatJobDtos,
  required Map<String, BattleSkillDefinitionDto> combatSkillDtos,
  required Map<String, BattlePassiveEffectDto> combatPassiveDtos,
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
    combatJobDefinitions: combatJobDtos.map(
      (String id, BattleCombatJobDefinitionDto definition) =>
          MapEntry<String, BattleCombatJobDefinition>(
            id,
            definition.toDomain(),
          ),
    ),
    combatSkillDefinitions: combatSkillDtos.map(
      (String id, BattleSkillDefinitionDto definition) =>
          MapEntry<String, BattleSkillDefinition>(id, definition.toDomain()),
    ),
    combatPassiveEffects: combatPassiveDtos.map(
      (String id, BattlePassiveEffectDto definition) =>
          MapEntry<String, BattlePassiveEffect>(id, definition.toDomain()),
    ),
  );
}
