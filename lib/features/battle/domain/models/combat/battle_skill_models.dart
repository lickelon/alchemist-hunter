import 'package:alchemist_hunter/features/battle/domain/models/combat/battle_effect_models.dart';
import 'package:alchemist_hunter/features/battle/domain/models/combat/combat_enums.dart';
import 'package:flutter/foundation.dart';

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
  final BattleModifier? modifier;
  final BattleStatusType? statusType;
  final int shieldValue;
}
