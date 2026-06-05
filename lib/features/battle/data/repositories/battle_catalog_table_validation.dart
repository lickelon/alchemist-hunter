part of 'battle_catalog_tables.dart';

extension _BattleCatalogTableValidation on BattleCatalogTables {
  void _validate() {
    _validateStageCatalogOrder();
    _validateCombatCatalogs();
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
      if (!RegExp(r'^enemy_set_\d{2}_\d{3}$').hasMatch(enemySet.id)) {
        throw StateError('Invalid enemy set id format: ${enemySet.id}');
      }
      for (final String enemyId in enemySet.enemyIds) {
        if (!enemyDefinitions.containsKey(enemyId)) {
          throw StateError('Unknown enemy in ${enemySet.id}: $enemyId');
        }
      }
    }
  }

  void _validateCombatCatalogs() {
    if (combatJobDefinitions.isEmpty) {
      throw StateError('Combat job catalog must not be empty');
    }
    final Set<String> usedSkillIds = <String>{
      for (final BattleEnemyDefinition enemy in enemyDefinitions.values)
        for (final BattleSkillDefinition skill in enemy.skills) skill.id,
    };
    final Set<String> usedPassiveIds = <String>{};
    for (final BattleCombatJobDefinition job in combatJobDefinitions.values) {
      if (job.tiers.isEmpty) {
        throw StateError('Combat job must define tiers: ${job.id}');
      }
      final Set<int> tierIndexes = <int>{};
      for (final BattleCombatJobTierDefinition tier in job.tiers) {
        if (tier.tierIndex <= 0) {
          throw StateError('Combat tier must be positive: ${job.id}');
        }
        if (!tierIndexes.add(tier.tierIndex)) {
          throw StateError(
            'Duplicate combat tier in ${job.id}: ${tier.tierIndex}',
          );
        }
        if (tier.ranks.isEmpty) {
          throw StateError(
            'Combat tier must define ranks: ${job.id} T${tier.tierIndex}',
          );
        }
        final Set<int> ranks = <int>{};
        for (final BattleCombatJobRankDefinition rank in tier.ranks) {
          if (rank.rank <= 0) {
            throw StateError('Combat rank must be positive: ${job.id}');
          }
          if (!ranks.add(rank.rank)) {
            throw StateError(
              'Duplicate combat rank in ${job.id} T${tier.tierIndex}: ${rank.rank}',
            );
          }
          for (final String skillId in rank.skillIds) {
            if (!combatSkillDefinitions.containsKey(skillId)) {
              throw StateError('Unknown combat skill in ${job.id}: $skillId');
            }
            usedSkillIds.add(skillId);
          }
          for (final String passiveId in rank.passiveIds) {
            if (!combatPassiveEffects.containsKey(passiveId)) {
              throw StateError(
                'Unknown combat passive in ${job.id}: $passiveId',
              );
            }
            usedPassiveIds.add(passiveId);
          }
        }
      }
    }
    for (final String skillId in combatSkillDefinitions.keys) {
      if (!usedSkillIds.contains(skillId)) {
        throw StateError('Unused combat skill: $skillId');
      }
    }
    for (final String passiveId in combatPassiveEffects.keys) {
      if (!usedPassiveIds.contains(passiveId)) {
        throw StateError('Unused combat passive: $passiveId');
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
    final int stageNumber = _stageNumber(stage.id);
    for (int index = 0; index < stage.encounters.length; index += 1) {
      final BattleStageEncounterDefinition encounter = stage.encounters[index];
      final String expectedEncounterId =
          'encounter_${stageNumber.toString().padLeft(2, '0')}_'
          '${(index + 1).toString().padLeft(3, '0')}';
      if (encounter.id != expectedEncounterId) {
        throw StateError(
          'Unexpected encounter order in ${stage.id}: '
          '${encounter.id}, expected $expectedEncounterId',
        );
      }
      final String expectedEnemySetId =
          'enemy_set_${stageNumber.toString().padLeft(2, '0')}_'
          '${(index + 1).toString().padLeft(3, '0')}';
      if (encounter.enemySetId != expectedEnemySetId) {
        throw StateError(
          'Unexpected enemy set order in ${stage.id}: '
          '${encounter.enemySetId}, expected $expectedEnemySetId',
        );
      }
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

  int _stageNumber(String stageId) {
    final RegExpMatch? match = RegExp(r'^stage_(\d+)$').firstMatch(stageId);
    if (match == null) {
      throw StateError('Invalid stage id format: $stageId');
    }
    return int.parse(match.group(1)!);
  }
}
