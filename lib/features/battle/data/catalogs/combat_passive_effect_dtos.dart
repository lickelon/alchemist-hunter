import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

import 'battle_catalog_json_helpers.dart';
import 'combat_modifier_dtos.dart';

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
      type: readEnum(
        json,
        'type',
        BattlePassiveConditionType.values,
        fallback: BattlePassiveConditionType.always,
      ),
      threshold: readDouble(json, 'threshold', fallback: 0),
      faction: readOptionalEnum(json, 'faction', CombatFaction.values),
      statusType: readOptionalEnum(json, 'statusType', BattleStatusType.values),
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
      trigger: readEnum(json, 'trigger', BattlePassiveTrigger.values),
      type: readEnum(json, 'type', BattlePassiveEffectType.values),
      sourceId: readString(json, 'sourceId'),
      value: readOptionalInt(json, 'value'),
      durationLifecycles: readInt(json, 'durationLifecycles', fallback: 1),
      modifier: readOptionalMap(json, 'modifier', BattleModifierDto.fromJson),
      statusType: readOptionalEnum(json, 'statusType', BattleStatusType.values),
      condition:
          readOptionalMap(
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
