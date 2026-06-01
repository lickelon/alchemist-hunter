import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

import 'battle_catalog_json_helpers.dart';
import 'combat_modifier_dtos.dart';

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

  factory BattleSkillDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleSkillDefinitionDto(
      id: readString(json, 'id'),
      name: readString(json, 'name'),
      summary: readString(json, 'summary'),
      cooldownLifecycles: readInt(json, 'cooldownLifecycles', fallback: 0),
      priority: readInt(json, 'priority', fallback: 0),
      targetType: readEnum(
        json,
        'targetType',
        BattleSkillTargetType.values,
        fallback: BattleSkillTargetType.randomEnemy,
      ),
      effectType: readEnum(
        json,
        'effectType',
        BattleSkillEffectType.values,
        fallback: BattleSkillEffectType.damage,
      ),
      school: readEnum(
        json,
        'school',
        DamageSchool.values,
        fallback: DamageSchool.any,
      ),
      powerMultiplier: readDouble(json, 'powerMultiplier', fallback: 1),
      flatPower: readInt(json, 'flatPower', fallback: 0),
      durationLifecycles: readInt(json, 'durationLifecycles', fallback: 1),
      modifier: readOptionalMap(json, 'modifier', BattleModifierDto.fromJson),
      statusType: readOptionalEnum(json, 'statusType', BattleStatusType.values),
      shieldValue: readInt(json, 'shieldValue', fallback: 0),
    );
  }

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
