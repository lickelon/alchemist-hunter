import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

import 'battle_catalog_json_helpers.dart';

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
      maxHp: readInt(json, 'maxHp'),
      maxMp: readInt(json, 'maxMp', fallback: 0),
      physicalAttack: readInt(json, 'physicalAttack'),
      physicalDefense: readInt(json, 'physicalDefense'),
      magicalAttack: readInt(json, 'magicalAttack'),
      magicalDefense: readInt(json, 'magicalDefense'),
      speed: readInt(json, 'speed'),
      critChance: readDouble(json, 'critChance'),
      critDamage: readDouble(json, 'critDamage'),
      accuracy: readDouble(json, 'accuracy'),
      evasion: readDouble(json, 'evasion'),
      statusAccuracy: readDouble(json, 'statusAccuracy'),
      statusResistance: readDouble(json, 'statusResistance'),
      physicalPenetration: readDouble(json, 'physicalPenetration'),
      magicalPenetration: readDouble(json, 'magicalPenetration'),
      lifesteal: readDouble(json, 'lifesteal'),
      healingPower: readDouble(json, 'healingPower'),
      regen: readDouble(json, 'regen'),
      mpRegen: readInt(json, 'mpRegen', fallback: 0),
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
