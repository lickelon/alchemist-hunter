import 'package:alchemist_hunter/features/battle/domain/models.dart';

import 'battle_catalog_dtos.dart';
import 'battle_stage_definitions.dart' as stage_catalog;
import 'encounters/battle_enemy_set_definitions.dart' as encounter_catalog;
import 'enemies/battle_enemy_definitions.dart' as enemy_catalog;

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

class BattleCatalogTables {
  BattleCatalogTables({
    required this.enemyDefinitions,
    required this.enemySetDefinitions,
    required this.stageDefinitions,
    required this.stageCatalog,
  }) {
    _validate();
  }

  factory BattleCatalogTables.fromDtos({
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
            MapEntry<String, BattleEnemySetDefinition>(
              id,
              definition.toDomain(),
            ),
      ),
      stageDefinitions: stageDtos.map(
        (String id, BattleStageDefinitionDto definition) =>
            MapEntry<String, BattleStageDefinition>(id, definition.toDomain()),
      ),
      stageCatalog: List<String>.unmodifiable(stageCatalog),
    );
  }

  final Map<String, BattleEnemyDefinition> enemyDefinitions;
  final Map<String, BattleEnemySetDefinition> enemySetDefinitions;
  final Map<String, BattleStageDefinition> stageDefinitions;
  final List<String> stageCatalog;

  BattleStageDefinition stageDefinition(String stageId) {
    final BattleStageDefinition? definition = stageDefinitions[stageId];
    if (definition == null) {
      throw StateError('Unknown stage: $stageId');
    }
    return definition;
  }

  BattleEnemySetDefinition enemySetDefinition(String enemySetId) {
    final BattleEnemySetDefinition? definition =
        enemySetDefinitions[enemySetId];
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
          final BattleEnemyDefinition? definition = enemyDefinitions[enemyId];
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
    final List<BattleEnemyDefinition> enemies = enemyDefinitionsForStage(
      stageId,
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

  void _validate() {
    for (final String stageId in stageCatalog) {
      if (!stageDefinitions.containsKey(stageId)) {
        throw StateError('Unknown stage in catalog order: $stageId');
      }
    }
    for (final BattleEnemySetDefinition enemySet
        in enemySetDefinitions.values) {
      for (final String enemyId in enemySet.enemyIds) {
        if (!enemyDefinitions.containsKey(enemyId)) {
          throw StateError('Unknown enemy in ${enemySet.id}: $enemyId');
        }
      }
    }
    for (final BattleStageDefinition stage in stageDefinitions.values) {
      if (stage.encounters.isEmpty) {
        throw StateError('Stage must define encounters: ${stage.id}');
      }
      if (stage.searchDuration <= Duration.zero) {
        throw StateError('Stage search duration must be positive: ${stage.id}');
      }
      if (stage.recoveryDuration <= Duration.zero) {
        throw StateError(
          'Stage recovery duration must be positive: ${stage.id}',
        );
      }
      if (stage.unlockCondition != null &&
          !stageDefinitions.containsKey(
            stage.unlockCondition!.requiredStageId,
          )) {
        throw StateError(
          'Unknown unlock stage for ${stage.id}: '
          '${stage.unlockCondition!.requiredStageId}',
        );
      }
      for (final BattleStageEncounterDefinition encounter in stage.encounters) {
        if (!enemySetDefinitions.containsKey(encounter.enemySetId)) {
          throw StateError(
            'Unknown enemy set in ${stage.id}: ${encounter.enemySetId}',
          );
        }
        if (encounter.chance <= 0) {
          throw StateError(
            'Encounter chance must be positive: ${encounter.id}',
          );
        }
      }
    }
  }
}

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
