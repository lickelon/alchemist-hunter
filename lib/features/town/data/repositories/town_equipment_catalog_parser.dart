part of 'town_catalog_asset_loader.dart';

mixin _TownEquipmentCatalogParserMixin {
  EquipmentBlueprint readEquipmentBlueprint(Map<String, Object?> json) {
    return EquipmentBlueprint(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      slot: j.readEnum(json, 'slot', EquipmentSlot.values),
      materialCosts: j.readIntMap(json, 'materialCosts'),
      craftDuration: Duration(
        seconds: j.readInt(json, 'craftDurationSeconds', fallback: 30),
      ),
      maxHp: j.readInt(json, 'maxHp', fallback: 0),
      physicalAttack: j.readInt(json, 'physicalAttack', fallback: 0),
      physicalDefense: j.readInt(json, 'physicalDefense', fallback: 0),
      magicalAttack: j.readInt(json, 'magicalAttack', fallback: 0),
      magicalDefense: j.readInt(json, 'magicalDefense', fallback: 0),
      speed: j.readInt(json, 'speed', fallback: 0),
      statModifiers: j
          .readObjectList(json, 'statModifiers')
          .map(readBattleStatModifier)
          .toList(growable: false),
      modifiers: j
          .readObjectList(json, 'modifiers')
          .map(readBattleModifier)
          .toList(growable: false),
      passives: j
          .readObjectList(json, 'passives')
          .map(readBattlePassiveEffect)
          .toList(growable: false),
    );
  }

  BattleStatModifier readBattleStatModifier(Map<String, Object?> json) {
    return BattleStatModifier(
      type: j.readEnum(json, 'type', BattleStatModifierType.values),
      mode: j.readEnum(json, 'mode', BattleModifierMode.values),
      value: j.readDouble(json, 'value'),
      sourceId: j.readString(json, 'sourceId'),
    );
  }

  BattleModifier readBattleModifier(Map<String, Object?> json) {
    return BattleModifier(
      type: j.readEnum(json, 'type', BattleModifierType.values),
      mode: j.readEnum(json, 'mode', BattleModifierMode.values),
      value: j.readDouble(json, 'value'),
      school: j.readEnum(
        json,
        'school',
        DamageSchool.values,
        fallback: DamageSchool.any,
      ),
      targetFaction: j.readOptionalEnum(
        json,
        'targetFaction',
        CombatFaction.values,
      ),
      sourceId: j.readString(json, 'sourceId'),
    );
  }

  BattlePassiveCondition readBattlePassiveCondition(Map<String, Object?> json) {
    return BattlePassiveCondition(
      type: j.readEnum(
        json,
        'type',
        BattlePassiveConditionType.values,
        fallback: BattlePassiveConditionType.always,
      ),
      threshold: j.readDouble(json, 'threshold', fallback: 0),
      faction: j.readOptionalEnum(json, 'faction', CombatFaction.values),
      statusType: j.readOptionalEnum(
        json,
        'statusType',
        BattleStatusType.values,
      ),
    );
  }

  BattlePassiveEffect readBattlePassiveEffect(Map<String, Object?> json) {
    final Map<String, Object?>? modifier = j.readOptionalObject(
      json,
      'modifier',
    );
    final Map<String, Object?>? condition = j.readOptionalObject(
      json,
      'condition',
    );
    return BattlePassiveEffect(
      trigger: j.readEnum(json, 'trigger', BattlePassiveTrigger.values),
      type: j.readEnum(json, 'type', BattlePassiveEffectType.values),
      sourceId: j.readString(json, 'sourceId'),
      value: j.readOptionalInt(json, 'value'),
      durationLifecycles: j.readInt(json, 'durationLifecycles', fallback: 1),
      modifier: modifier == null ? null : readBattleModifier(modifier),
      statusType: j.readOptionalEnum(
        json,
        'statusType',
        BattleStatusType.values,
      ),
      condition: condition == null
          ? const BattlePassiveCondition()
          : readBattlePassiveCondition(condition),
    );
  }

  Map<String, String> readStringMap(Map<String, Object?> json, String key) {
    final Object? value = json[key];
    if (value is Map<String, Object?>) {
      return value.map((String key, Object? entry) {
        if (entry is String) {
          return MapEntry<String, String>(key, entry);
        }
        throw FormatException('Invalid string map entry for $key: $entry');
      });
    }
    throw FormatException('Invalid string map value for $key: $value');
  }
}
