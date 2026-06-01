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

  factory BattleDropEntryDto.fromJson(Map<String, Object?> json) {
    return BattleDropEntryDto(
      materialId: _readString(json, 'materialId'),
      min: _readInt(json, 'min'),
      max: _readInt(json, 'max'),
      chance: _readDouble(json, 'chance'),
    );
  }

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

  factory BattleCombatStatsDto.fromJson(Map<String, Object?> json) {
    return BattleCombatStatsDto(
      maxHp: _readInt(json, 'maxHp'),
      maxMp: _readInt(json, 'maxMp', fallback: 0),
      physicalAttack: _readInt(json, 'physicalAttack'),
      physicalDefense: _readInt(json, 'physicalDefense'),
      magicalAttack: _readInt(json, 'magicalAttack'),
      magicalDefense: _readInt(json, 'magicalDefense'),
      speed: _readInt(json, 'speed'),
      critChance: _readDouble(json, 'critChance'),
      critDamage: _readDouble(json, 'critDamage'),
      accuracy: _readDouble(json, 'accuracy'),
      evasion: _readDouble(json, 'evasion'),
      statusAccuracy: _readDouble(json, 'statusAccuracy'),
      statusResistance: _readDouble(json, 'statusResistance'),
      physicalPenetration: _readDouble(json, 'physicalPenetration'),
      magicalPenetration: _readDouble(json, 'magicalPenetration'),
      lifesteal: _readDouble(json, 'lifesteal'),
      healingPower: _readDouble(json, 'healingPower'),
      regen: _readDouble(json, 'regen'),
      mpRegen: _readInt(json, 'mpRegen', fallback: 0),
    );
  }

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

  factory BattleEnemyDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleEnemyDefinitionDto(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      faction: _readEnum(json, 'faction', CombatFaction.values),
      summary: _readString(json, 'summary'),
      stats: _readMap(json, 'stats', BattleCombatStatsDto.fromJson),
      modifiers: _readList(json, 'modifiers', BattleModifierDto.fromJson),
      passives: _readList(json, 'passives', BattlePassiveEffectDto.fromJson),
      skills: _readList(json, 'skills', BattleSkillDefinitionDto.fromJson),
      normalDrops: _readList(json, 'normalDrops', BattleDropEntryDto.fromJson),
      specialDrops: _readList(
        json,
        'specialDrops',
        BattleDropEntryDto.fromJson,
      ),
    );
  }

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

  factory BattleEnemySetDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleEnemySetDefinitionDto(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      enemyIds: _readStringList(json, 'enemyIds'),
    );
  }

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

  factory BattleStageUnlockConditionDto.fromJson(Map<String, Object?> json) {
    return BattleStageUnlockConditionDto(
      requiredStageId: _readString(json, 'requiredStageId'),
      requiredWinStreakCount: _readInt(json, 'requiredWinStreakCount'),
      label: _readString(json, 'label'),
    );
  }

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

  factory BattleStageEncounterDefinitionDto.fromJson(
    Map<String, Object?> json,
  ) {
    return BattleStageEncounterDefinitionDto(
      id: _readString(json, 'id'),
      enemySetId: _readString(json, 'enemySetId'),
      chance: _readDouble(json, 'chance'),
    );
  }

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

  factory BattleStageDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleStageDefinitionDto(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      recommendedPower: _readInt(json, 'recommendedPower'),
      searchDurationSeconds: _readInt(json, 'searchDurationSeconds'),
      recoveryDurationSeconds: _readInt(
        json,
        'recoveryDurationSeconds',
        fallback: 10,
      ),
      encounters: _readList(
        json,
        'encounters',
        BattleStageEncounterDefinitionDto.fromJson,
      ),
      goldSuccess: _readInt(json, 'goldSuccess'),
      goldFailurePenalty: _readInt(json, 'goldFailurePenalty'),
      essenceSuccess: _readInt(json, 'essenceSuccess'),
      essenceFailure: _readInt(json, 'essenceFailure'),
      xpSuccessBase: _readInt(json, 'xpSuccessBase'),
      xpFailureBase: _readInt(json, 'xpFailureBase'),
      unlockCondition: _readOptionalMap(
        json,
        'unlockCondition',
        BattleStageUnlockConditionDto.fromJson,
      ),
      clearUnlockFlags: _readStringList(json, 'clearUnlockFlags').toSet(),
    );
  }

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

T _readMap<T>(
  Map<String, Object?> json,
  String key,
  T Function(Map<String, Object?> json) convert,
) {
  final Object? value = json[key];
  if (value is Map<String, Object?>) {
    return convert(value);
  }
  throw FormatException('Invalid object value for $key: $value');
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

List<T> _readList<T>(
  Map<String, Object?> json,
  String key,
  T Function(Map<String, Object?> json) convert,
) {
  final Object? value = json[key];
  if (value == null) {
    return <T>[];
  }
  if (value is List<Object?>) {
    return value
        .map((Object? entry) {
          if (entry is Map<String, Object?>) {
            return convert(entry);
          }
          throw FormatException('Invalid list entry for $key: $entry');
        })
        .toList(growable: false);
  }
  throw FormatException('Invalid list value for $key: $value');
}

List<String> _readStringList(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return const <String>[];
  }
  if (value is List<Object?>) {
    return value
        .map((Object? entry) {
          if (entry is String) {
            return entry;
          }
          throw FormatException('Invalid string list entry for $key: $entry');
        })
        .toList(growable: false);
  }
  throw FormatException('Invalid string list value for $key: $value');
}
