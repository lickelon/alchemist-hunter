part of 'battle_catalog_tables.dart';

extension _BattleCatalogTableValidation on BattleCatalogTables {
  void _validate() {
    _validateStageCatalogOrder();
    _validateEnemySets();
    _validateStages();
  }

  void _validateStageCatalogOrder() {
    for (final String stageId in stageCatalog) {
      if (!stageDefinitions.containsKey(stageId)) {
        throw StateError('Unknown stage in catalog order: $stageId');
      }
    }
  }

  void _validateEnemySets() {
    for (final BattleEnemySetDefinition enemySet
        in enemySetDefinitions.values) {
      for (final String enemyId in enemySet.enemyIds) {
        if (!enemyDefinitions.containsKey(enemyId)) {
          throw StateError('Unknown enemy in ${enemySet.id}: $enemyId');
        }
      }
    }
  }

  void _validateStages() {
    for (final BattleStageDefinition stage in stageDefinitions.values) {
      _validateStageTiming(stage);
      _validateStageUnlock(stage);
      _validateStageEncounters(stage);
    }
  }

  void _validateStageTiming(BattleStageDefinition stage) {
    if (stage.encounters.isEmpty) {
      throw StateError('Stage must define encounters: ${stage.id}');
    }
    if (stage.searchDuration <= Duration.zero) {
      throw StateError('Stage search duration must be positive: ${stage.id}');
    }
    if (stage.recoveryDuration <= Duration.zero) {
      throw StateError('Stage recovery duration must be positive: ${stage.id}');
    }
  }

  void _validateStageUnlock(BattleStageDefinition stage) {
    if (stage.unlockCondition != null &&
        !stageDefinitions.containsKey(stage.unlockCondition!.requiredStageId)) {
      throw StateError(
        'Unknown unlock stage for ${stage.id}: '
        '${stage.unlockCondition!.requiredStageId}',
      );
    }
  }

  void _validateStageEncounters(BattleStageDefinition stage) {
    for (final BattleStageEncounterDefinition encounter in stage.encounters) {
      if (!enemySetDefinitions.containsKey(encounter.enemySetId)) {
        throw StateError(
          'Unknown enemy set in ${stage.id}: ${encounter.enemySetId}',
        );
      }
      if (encounter.chance <= 0) {
        throw StateError('Encounter chance must be positive: ${encounter.id}');
      }
    }
  }
}
