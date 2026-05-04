import 'package:flutter/foundation.dart';

enum CombatFaction { mercenary, homunculus }

enum CombatDiscipline { warrior, mage, rogue, archer }

enum BattleModifierType {
  damageDealt,
  damageTaken,
  critRate,
  critDamage,
  accuracy,
  evasion,
  lifesteal,
  healingPower,
  regen,
}

enum BattleModifierMode { flat, percent }

enum DamageSchool { any, physical, magical }

enum BattlePassiveTrigger { battleStart, beforeHitCheck, afterAction }

enum BattlePassiveEffectType { alwaysHit, extraAttack }

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
class BattleCombatStats {
  const BattleCombatStats({
    required this.maxHp,
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
  });

  const BattleCombatStats.zero()
    : maxHp = 0,
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
      regen = 0;

  final int maxHp;
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

  BattleCombatStats operator +(BattleCombatStats other) {
    return BattleCombatStats(
      maxHp: maxHp + other.maxHp,
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
    );
  }

  BattleCombatStats scale(int multiplier) {
    if (multiplier <= 0) {
      return const BattleCombatStats.zero();
    }
    return BattleCombatStats(
      maxHp: maxHp * multiplier,
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
    );
  }
}
