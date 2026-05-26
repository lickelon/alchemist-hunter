import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

export 'package:alchemist_hunter/features/battle/domain/models.dart'
    show
        BattleModifierMode,
        BattleModifierType,
        BattlePassiveEffectType,
        BattlePassiveTrigger,
        BattleSkillEffectType,
        BattleSkillTargetType,
        BattleStatusType,
        CombatFaction,
        DamageSchool;

@immutable
class BattleDropEntryDto {
  const BattleDropEntryDto({
    required this.materialId,
    required this.min,
    required this.max,
    required this.chance,
  });

  final String materialId;
  final int min;
  final int max;
  final double chance;

  BattleDropEntry toDomain() {
    return BattleDropEntry(
      materialId: materialId,
      min: min,
      max: max,
      chance: chance,
    );
  }
}

@immutable
class BattleModifierDto {
  const BattleModifierDto({
    required this.type,
    required this.mode,
    required this.value,
    this.school = DamageSchool.any,
    this.targetFaction,
    required this.sourceId,
  });

  final BattleModifierType type;
  final BattleModifierMode mode;
  final double value;
  final DamageSchool school;
  final CombatFaction? targetFaction;
  final String sourceId;

  BattleModifier toDomain() {
    return BattleModifier(
      type: type,
      mode: mode,
      value: value,
      school: school,
      targetFaction: targetFaction,
      sourceId: sourceId,
    );
  }
}

@immutable
class BattlePassiveConditionDto {
  const BattlePassiveConditionDto({
    this.type = BattlePassiveConditionType.always,
    this.threshold = 0,
    this.faction,
    this.statusType,
  });

  final BattlePassiveConditionType type;
  final double threshold;
  final CombatFaction? faction;
  final BattleStatusType? statusType;

  BattlePassiveCondition toDomain() {
    return BattlePassiveCondition(
      type: type,
      threshold: threshold,
      faction: faction,
      statusType: statusType,
    );
  }
}

@immutable
class BattlePassiveEffectDto {
  const BattlePassiveEffectDto({
    required this.trigger,
    required this.type,
    required this.sourceId,
    this.value,
    this.durationLifecycles = 1,
    this.modifier,
    this.statusType,
    this.condition = const BattlePassiveConditionDto(),
  });

  final BattlePassiveTrigger trigger;
  final BattlePassiveEffectType type;
  final String sourceId;
  final int? value;
  final int durationLifecycles;
  final BattleModifierDto? modifier;
  final BattleStatusType? statusType;
  final BattlePassiveConditionDto condition;

  BattlePassiveEffect toDomain() {
    return BattlePassiveEffect(
      trigger: trigger,
      type: type,
      sourceId: sourceId,
      value: value,
      durationLifecycles: durationLifecycles,
      modifier: modifier?.toDomain(),
      statusType: statusType,
      condition: condition.toDomain(),
    );
  }
}

@immutable
class BattleSkillDefinitionDto {
  const BattleSkillDefinitionDto({
    required this.id,
    required this.name,
    required this.summary,
    this.cooldownLifecycles = 0,
    this.priority = 0,
    this.targetType = BattleSkillTargetType.randomEnemy,
    this.effectType = BattleSkillEffectType.damage,
    this.school = DamageSchool.any,
    this.powerMultiplier = 1,
    this.flatPower = 0,
    this.durationLifecycles = 1,
    this.modifier,
    this.statusType,
    this.shieldValue = 0,
  });

  final String id;
  final String name;
  final String summary;
  final int cooldownLifecycles;
  final int priority;
  final BattleSkillTargetType targetType;
  final BattleSkillEffectType effectType;
  final DamageSchool school;
  final double powerMultiplier;
  final int flatPower;
  final int durationLifecycles;
  final BattleModifierDto? modifier;
  final BattleStatusType? statusType;
  final int shieldValue;

  BattleSkillDefinition toDomain() {
    return BattleSkillDefinition(
      id: id,
      name: name,
      summary: summary,
      cooldownLifecycles: cooldownLifecycles,
      priority: priority,
      targetType: targetType,
      effectType: effectType,
      school: school,
      powerMultiplier: powerMultiplier,
      flatPower: flatPower,
      durationLifecycles: durationLifecycles,
      modifier: modifier?.toDomain(),
      statusType: statusType,
      shieldValue: shieldValue,
    );
  }
}

@immutable
class BattleCombatStatsDto {
  const BattleCombatStatsDto({
    required this.maxHp,
    this.maxMp = 0,
    required this.physicalAttack,
    required this.physicalDefense,
    required this.magicalAttack,
    required this.magicalDefense,
    required this.speed,
    required this.critChance,
    required this.critDamage,
    required this.accuracy,
    required this.evasion,
    required this.statusAccuracy,
    required this.statusResistance,
    required this.physicalPenetration,
    required this.magicalPenetration,
    required this.lifesteal,
    required this.healingPower,
    required this.regen,
    this.mpRegen = 0,
  });

  final int maxHp;
  final int maxMp;
  final int physicalAttack;
  final int physicalDefense;
  final int magicalAttack;
  final int magicalDefense;
  final int speed;
  final double critChance;
  final double critDamage;
  final double accuracy;
  final double evasion;
  final double statusAccuracy;
  final double statusResistance;
  final double physicalPenetration;
  final double magicalPenetration;
  final double lifesteal;
  final double healingPower;
  final double regen;
  final int mpRegen;

  BattleCombatStats toDomain() {
    return BattleCombatStats(
      maxHp: maxHp,
      maxMp: maxMp,
      physicalAttack: physicalAttack,
      physicalDefense: physicalDefense,
      magicalAttack: magicalAttack,
      magicalDefense: magicalDefense,
      speed: speed,
      critChance: critChance,
      critDamage: critDamage,
      accuracy: accuracy,
      evasion: evasion,
      statusAccuracy: statusAccuracy,
      statusResistance: statusResistance,
      physicalPenetration: physicalPenetration,
      magicalPenetration: magicalPenetration,
      lifesteal: lifesteal,
      healingPower: healingPower,
      regen: regen,
      mpRegen: mpRegen,
    );
  }
}

@immutable
class BattleEnemyDefinitionDto {
  const BattleEnemyDefinitionDto({
    required this.id,
    required this.name,
    required this.faction,
    required this.summary,
    required this.stats,
    this.modifiers = const <BattleModifierDto>[],
    this.passives = const <BattlePassiveEffectDto>[],
    this.skills = const <BattleSkillDefinitionDto>[],
    this.normalDrops = const <BattleDropEntryDto>[],
    this.specialDrops = const <BattleDropEntryDto>[],
  });

  final String id;
  final String name;
  final CombatFaction faction;
  final String summary;
  final BattleCombatStatsDto stats;
  final List<BattleModifierDto> modifiers;
  final List<BattlePassiveEffectDto> passives;
  final List<BattleSkillDefinitionDto> skills;
  final List<BattleDropEntryDto> normalDrops;
  final List<BattleDropEntryDto> specialDrops;

  BattleEnemyDefinition toDomain() {
    return BattleEnemyDefinition(
      id: id,
      name: name,
      faction: faction,
      summary: summary,
      stats: stats.toDomain(),
      modifiers: modifiers
          .map((BattleModifierDto modifier) => modifier.toDomain())
          .toList(growable: false),
      passives: passives
          .map((BattlePassiveEffectDto passive) => passive.toDomain())
          .toList(growable: false),
      skills: skills
          .map((BattleSkillDefinitionDto skill) => skill.toDomain())
          .toList(growable: false),
      normalDrops: normalDrops
          .map((BattleDropEntryDto drop) => drop.toDomain())
          .toList(growable: false),
      specialDrops: specialDrops
          .map((BattleDropEntryDto drop) => drop.toDomain())
          .toList(growable: false),
    );
  }
}

@immutable
class BattleEnemySetDefinitionDto {
  const BattleEnemySetDefinitionDto({
    required this.id,
    required this.name,
    required this.enemyIds,
  });

  final String id;
  final String name;
  final List<String> enemyIds;

  BattleEnemySetDefinition toDomain() {
    return BattleEnemySetDefinition(id: id, name: name, enemyIds: enemyIds);
  }
}

@immutable
class BattleStageUnlockConditionDto {
  const BattleStageUnlockConditionDto({
    required this.requiredStageId,
    required this.requiredWinStreakCount,
    required this.label,
  });

  final String requiredStageId;
  final int requiredWinStreakCount;
  final String label;

  BattleStageUnlockCondition toDomain() {
    return BattleStageUnlockCondition(
      requiredStageId: requiredStageId,
      requiredWinStreakCount: requiredWinStreakCount,
      label: label,
    );
  }
}

@immutable
class BattleStageEncounterDefinitionDto {
  const BattleStageEncounterDefinitionDto({
    required this.id,
    required this.enemySetId,
    required this.chance,
  });

  final String id;
  final String enemySetId;
  final double chance;

  BattleStageEncounterDefinition toDomain() {
    return BattleStageEncounterDefinition(
      id: id,
      enemySetId: enemySetId,
      chance: chance,
    );
  }
}

@immutable
class BattleStageDefinitionDto {
  const BattleStageDefinitionDto({
    required this.id,
    required this.name,
    required this.recommendedPower,
    required this.searchDurationSeconds,
    this.recoveryDurationSeconds = 10,
    required this.encounters,
    required this.goldSuccess,
    required this.goldFailurePenalty,
    required this.essenceSuccess,
    required this.essenceFailure,
    required this.xpSuccessBase,
    required this.xpFailureBase,
    this.unlockCondition,
    this.clearUnlockFlags = const <String>{},
  });

  final String id;
  final String name;
  final int recommendedPower;
  final int searchDurationSeconds;
  final int recoveryDurationSeconds;
  final List<BattleStageEncounterDefinitionDto> encounters;
  final int goldSuccess;
  final int goldFailurePenalty;
  final int essenceSuccess;
  final int essenceFailure;
  final int xpSuccessBase;
  final int xpFailureBase;
  final BattleStageUnlockConditionDto? unlockCondition;
  final Set<String> clearUnlockFlags;

  BattleStageDefinition toDomain() {
    return BattleStageDefinition(
      id: id,
      name: name,
      recommendedPower: recommendedPower,
      searchDuration: Duration(seconds: searchDurationSeconds),
      recoveryDuration: Duration(seconds: recoveryDurationSeconds),
      encounters: encounters
          .map(
            (BattleStageEncounterDefinitionDto encounter) =>
                encounter.toDomain(),
          )
          .toList(growable: false),
      goldSuccess: goldSuccess,
      goldFailurePenalty: goldFailurePenalty,
      essenceSuccess: essenceSuccess,
      essenceFailure: essenceFailure,
      xpSuccessBase: xpSuccessBase,
      xpFailureBase: xpFailureBase,
      unlockCondition: unlockCondition?.toDomain(),
      clearUnlockFlags: clearUnlockFlags,
    );
  }
}
