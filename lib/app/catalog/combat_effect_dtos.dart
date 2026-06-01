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

  factory BattleModifierDto.fromJson(Map<String, Object?> json) {
    return BattleModifierDto(
      type: _readEnum(json, 'type', BattleModifierType.values),
      mode: _readEnum(json, 'mode', BattleModifierMode.values),
      value: _readDouble(json, 'value'),
      school: _readEnum(
        json,
        'school',
        DamageSchool.values,
        fallback: DamageSchool.any,
      ),
      targetFaction: _readOptionalEnum(
        json,
        'targetFaction',
        CombatFaction.values,
      ),
      sourceId: _readString(json, 'sourceId'),
    );
  }

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

  factory BattlePassiveConditionDto.fromJson(Map<String, Object?> json) {
    return BattlePassiveConditionDto(
      type: _readEnum(
        json,
        'type',
        BattlePassiveConditionType.values,
        fallback: BattlePassiveConditionType.always,
      ),
      threshold: _readDouble(json, 'threshold', fallback: 0),
      faction: _readOptionalEnum(json, 'faction', CombatFaction.values),
      statusType: _readOptionalEnum(
        json,
        'statusType',
        BattleStatusType.values,
      ),
    );
  }

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

  factory BattlePassiveEffectDto.fromJson(Map<String, Object?> json) {
    return BattlePassiveEffectDto(
      trigger: _readEnum(json, 'trigger', BattlePassiveTrigger.values),
      type: _readEnum(json, 'type', BattlePassiveEffectType.values),
      sourceId: _readString(json, 'sourceId'),
      value: _readOptionalInt(json, 'value'),
      durationLifecycles: _readInt(json, 'durationLifecycles', fallback: 1),
      modifier: _readOptionalMap(json, 'modifier', BattleModifierDto.fromJson),
      statusType: _readOptionalEnum(
        json,
        'statusType',
        BattleStatusType.values,
      ),
      condition:
          _readOptionalMap(
            json,
            'condition',
            BattlePassiveConditionDto.fromJson,
          ) ??
          const BattlePassiveConditionDto(),
    );
  }

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

  factory BattleSkillDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleSkillDefinitionDto(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      summary: _readString(json, 'summary'),
      cooldownLifecycles: _readInt(json, 'cooldownLifecycles', fallback: 0),
      priority: _readInt(json, 'priority', fallback: 0),
      targetType: _readEnum(
        json,
        'targetType',
        BattleSkillTargetType.values,
        fallback: BattleSkillTargetType.randomEnemy,
      ),
      effectType: _readEnum(
        json,
        'effectType',
        BattleSkillEffectType.values,
        fallback: BattleSkillEffectType.damage,
      ),
      school: _readEnum(
        json,
        'school',
        DamageSchool.values,
        fallback: DamageSchool.any,
      ),
      powerMultiplier: _readDouble(json, 'powerMultiplier', fallback: 1),
      flatPower: _readInt(json, 'flatPower', fallback: 0),
      durationLifecycles: _readInt(json, 'durationLifecycles', fallback: 1),
      modifier: _readOptionalMap(json, 'modifier', BattleModifierDto.fromJson),
      statusType: _readOptionalEnum(
        json,
        'statusType',
        BattleStatusType.values,
      ),
      shieldValue: _readInt(json, 'shieldValue', fallback: 0),
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

T _readEnum<T extends Enum>(
  Map<String, Object?> json,
  String key,
  List<T> values, {
  T? fallback,
}) {
  final Object? value = json[key];
  if (value == null && fallback != null) {
    return fallback;
  }
  if (value is String) {
    for (final T entry in values) {
      if (entry.name == value) {
        return entry;
      }
    }
  }
  throw FormatException('Invalid enum value for $key: $value');
}

T? _readOptionalEnum<T extends Enum>(
  Map<String, Object?> json,
  String key,
  List<T> values,
) {
  if (!json.containsKey(key) || json[key] == null) {
    return null;
  }
  return _readEnum(json, key, values);
}

String _readString(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Invalid string value for $key: $value');
}

int _readInt(Map<String, Object?> json, String key, {int? fallback}) {
  final Object? value = json[key];
  if (value == null && fallback != null) {
    return fallback;
  }
  if (value is int) {
    return value;
  }
  throw FormatException('Invalid int value for $key: $value');
}

int? _readOptionalInt(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  throw FormatException('Invalid int value for $key: $value');
}

double _readDouble(Map<String, Object?> json, String key, {double? fallback}) {
  final Object? value = json[key];
  if (value == null && fallback != null) {
    return fallback;
  }
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException('Invalid number value for $key: $value');
}

T? _readOptionalMap<T>(
  Map<String, Object?> json,
  String key,
  T Function(Map<String, Object?> json) convert,
) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }
  if (value is Map<String, Object?>) {
    return convert(value);
  }
  throw FormatException('Invalid object value for $key: $value');
}
