import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

import 'battle_catalog_json_helpers.dart';

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
      type: readEnum(json, 'type', BattleModifierType.values),
      mode: readEnum(json, 'mode', BattleModifierMode.values),
      value: readDouble(json, 'value'),
      school: readEnum(
        json,
        'school',
        DamageSchool.values,
        fallback: DamageSchool.any,
      ),
      targetFaction: readOptionalEnum(
        json,
        'targetFaction',
        CombatFaction.values,
      ),
      sourceId: readString(json, 'sourceId'),
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
