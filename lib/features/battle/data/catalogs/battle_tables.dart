import 'package:alchemist_hunter/features/battle/domain/models.dart';

import 'battle_catalog_dtos.dart';
import 'battle_stage_definitions.dart' as stage_catalog;
import 'encounters/battle_enemy_set_definitions.dart' as encounter_catalog;
import 'enemies/battle_enemy_definitions.dart' as enemy_catalog;

final Map<String, BattleEnemyDefinition> battleEnemyDefinitions = enemy_catalog
    .battleEnemyDefinitionDtos
    .map(
      (String id, BattleEnemyDefinitionDto definition) =>
          MapEntry<String, BattleEnemyDefinition>(id, definition.toDomain()),
    );

final Map<String, BattleEnemySetDefinition> battleEnemySetDefinitions =
    encounter_catalog.battleEnemySetDefinitionDtos.map(
      (String id, BattleEnemySetDefinitionDto definition) =>
          MapEntry<String, BattleEnemySetDefinition>(id, definition.toDomain()),
    );

final Map<String, BattleStageDefinition> battleStageDefinitions = stage_catalog
    .battleStageDefinitionDtos
    .map(
      (String id, BattleStageDefinitionDto definition) =>
          MapEntry<String, BattleStageDefinition>(id, definition.toDomain()),
    );

const List<String> stageCatalog = stage_catalog.stageCatalog;

BattleStageDefinition stageDefinition(String stageId) {
  final BattleStageDefinition? definition = battleStageDefinitions[stageId];
  if (definition == null) {
    throw StateError('Unknown stage: $stageId');
  }
  return definition;
}

BattleEnemySetDefinition enemySetDefinition(String enemySetId) {
  final BattleEnemySetDefinition? definition =
      battleEnemySetDefinitions[enemySetId];
  if (definition == null) {
    throw StateError('Unknown enemy set: $enemySetId');
  }
  return definition;
}

List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
  String stageId,
) {
  return stageDefinition(stageId).encounters;
}

List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId) {
  final BattleEnemySetDefinition enemySet = enemySetDefinition(enemySetId);
  return enemySet.enemyIds
      .map((String enemyId) {
        final BattleEnemyDefinition? definition =
            battleEnemyDefinitions[enemyId];
        if (definition == null) {
          throw StateError('Unknown enemy: $enemyId');
        }
        return definition;
      })
      .toList(growable: false);
}

List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) {
  final Map<String, BattleEnemyDefinition> uniqueEnemies =
      <String, BattleEnemyDefinition>{};
  for (final BattleStageEncounterDefinition encounter
      in encounterDefinitionsForStage(stageId)) {
    for (final BattleEnemyDefinition enemy in enemyDefinitionsForSet(
      encounter.enemySetId,
    )) {
      uniqueEnemies[enemy.id] = enemy;
    }
  }
  return uniqueEnemies.values.toList(growable: false);
}

BattleDropTable dropTableForEnemySet({
  required String stageId,
  required String enemySetId,
}) {
  final List<BattleEnemyDefinition> enemies = enemyDefinitionsForSet(
    enemySetId,
  );
  return BattleDropTable(
    stageId: stageId,
    normalDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.normalDrops)
        .toList(growable: false),
    specialDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.specialDrops)
        .toList(growable: false),
  );
}

BattleDropTable stageDropTable(String stageId) {
  final List<BattleEnemyDefinition> enemies = enemyDefinitionsForStage(stageId);
  return BattleDropTable(
    stageId: stageId,
    normalDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.normalDrops)
        .toList(growable: false),
    specialDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.specialDrops)
        .toList(growable: false),
  );
}
