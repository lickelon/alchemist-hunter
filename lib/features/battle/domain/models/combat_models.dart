import 'package:flutter/foundation.dart';

enum CombatFaction { mercenary, homunculus }

enum CombatDiscipline { warrior, mage, rogue, archer }

enum BattleModifierType { damageDealt, damageTaken }

enum BattleModifierMode { flat, percent }

enum DamageSchool { any, physical, magical }

enum BattleStatModifierType {
  maxHp,
  maxMp,
  physicalAttack,
  physicalDefense,
  magicalAttack,
  magicalDefense,
  speed,
  critRate,
  critDamage,
  accuracy,
  evasion,
  statusAccuracy,
  statusResistance,
  physicalPenetration,
  magicalPenetration,
  lifesteal,
  healingPower,
  regen,
  mpRegen,
}

enum BattlePassiveTrigger {
  battleStart,
  beforeAction,
  beforeHitCheck,
  beforeDamage,
  afterHit,
  afterAction,
  turnEnd,
  onDamaged,
  onDefeat,
}

enum BattlePassiveEffectType {
  alwaysHit,
  extraAttack,
  firstStrike,
  counterAttack,
}

enum BattleSkillTargetType {
  randomEnemy,
  self,
  randomAlly,
  allEnemies,
  allAllies,
}

enum BattleSkillEffectType { damage, heal, grantModifier }

@immutable
class BattleModifier {
  const BattleModifier({
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
}

@immutable
class BattleStatModifier {
  const BattleStatModifier({
    required this.type,
    required this.mode,
    required this.value,
    required this.sourceId,
  });

  final BattleStatModifierType type;
  final BattleModifierMode mode;
  final double value;
  final String sourceId;
}

@immutable
class BattlePassiveEffect {
  const BattlePassiveEffect({
    required this.trigger,
    required this.type,
    required this.sourceId,
    this.value,
  });

  final BattlePassiveTrigger trigger;
  final BattlePassiveEffectType type;
  final String sourceId;
  final int? value;
}

@immutable
class BattleSkillDefinition {
  const BattleSkillDefinition({
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
}

@immutable
class BattleCombatStats {
  const BattleCombatStats({
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

  const BattleCombatStats.zero()
    : maxHp = 0,
      maxMp = 0,
      physicalAttack = 0,
      physicalDefense = 0,
      magicalAttack = 0,
      magicalDefense = 0,
      speed = 0,
      critChance = 0,
      critDamage = 0,
      accuracy = 0,
      evasion = 0,
      statusAccuracy = 0,
      statusResistance = 0,
      physicalPenetration = 0,
      magicalPenetration = 0,
      lifesteal = 0,
      healingPower = 0,
      regen = 0,
      mpRegen = 0;

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

  BattleCombatStats operator +(BattleCombatStats other) {
    return BattleCombatStats(
      maxHp: maxHp + other.maxHp,
      maxMp: maxMp + other.maxMp,
      physicalAttack: physicalAttack + other.physicalAttack,
      physicalDefense: physicalDefense + other.physicalDefense,
      magicalAttack: magicalAttack + other.magicalAttack,
      magicalDefense: magicalDefense + other.magicalDefense,
      speed: speed + other.speed,
      critChance: critChance + other.critChance,
      critDamage: critDamage + other.critDamage,
      accuracy: accuracy + other.accuracy,
      evasion: evasion + other.evasion,
      statusAccuracy: statusAccuracy + other.statusAccuracy,
      statusResistance: statusResistance + other.statusResistance,
      physicalPenetration: physicalPenetration + other.physicalPenetration,
      magicalPenetration: magicalPenetration + other.magicalPenetration,
      lifesteal: lifesteal + other.lifesteal,
      healingPower: healingPower + other.healingPower,
      regen: regen + other.regen,
      mpRegen: mpRegen + other.mpRegen,
    );
  }

  BattleCombatStats scale(int multiplier) {
    if (multiplier <= 0) {
      return const BattleCombatStats.zero();
    }
    return BattleCombatStats(
      maxHp: maxHp * multiplier,
      maxMp: maxMp * multiplier,
      physicalAttack: physicalAttack * multiplier,
      physicalDefense: physicalDefense * multiplier,
      magicalAttack: magicalAttack * multiplier,
      magicalDefense: magicalDefense * multiplier,
      speed: speed * multiplier,
      critChance: critChance * multiplier,
      critDamage: critDamage * multiplier,
      accuracy: accuracy * multiplier,
      evasion: evasion * multiplier,
      statusAccuracy: statusAccuracy * multiplier,
      statusResistance: statusResistance * multiplier,
      physicalPenetration: physicalPenetration * multiplier,
      magicalPenetration: magicalPenetration * multiplier,
      lifesteal: lifesteal * multiplier,
      healingPower: healingPower * multiplier,
      regen: regen * multiplier,
      mpRegen: mpRegen * multiplier,
    );
  }
}
