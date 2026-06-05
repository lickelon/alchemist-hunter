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
  final Map<String, BattleSkillDefinition> combatSkillDefinitions =
      combatSkillDtos.map(
        (String id, BattleSkillDefinitionDto definition) =>
            MapEntry<String, BattleSkillDefinition>(id, definition.toDomain()),
      );
  return BattleCatalogTables(
    enemyDefinitions: enemyDtos.map((
      String id,
      BattleEnemyDefinitionDto definition,
    ) {
      final List<BattleSkillDefinition> referencedSkills = definition.skillIds
          .map((String skillId) {
            final BattleSkillDefinition? skill =
                combatSkillDefinitions[skillId];
            if (skill == null) {
              throw StateError('Unknown enemy combat skill in $id: $skillId');
            }
            return skill;
          })
          .toList(growable: false);
      return MapEntry<String, BattleEnemyDefinition>(
        id,
        definition.toDomain(referencedSkills: referencedSkills),
      );
    }),
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
    combatSkillDefinitions: combatSkillDefinitions,
    combatPassiveEffects: combatPassiveDtos.map(
      (String id, BattlePassiveEffectDto definition) =>
          MapEntry<String, BattlePassiveEffect>(id, definition.toDomain()),
    ),
  );
}
