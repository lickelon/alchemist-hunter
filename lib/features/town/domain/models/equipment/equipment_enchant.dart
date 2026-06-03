import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

@immutable
class EquipmentEnchant {
  const EquipmentEnchant({
    required this.potionStackKey,
    required this.potionName,
    required this.qualityLabel,
    required this.dominantTraitId,
    this.magicalAttackBonus = 0,
    this.magicalDefenseBonus = 0,
    this.speedBonus = 0,
    this.statModifiers = const <BattleStatModifier>[],
    this.modifiers = const <BattleModifier>[],
    this.passives = const <BattlePassiveEffect>[],
    int maxHpBonus = 0,
    int physicalAttackBonus = 0,
    int physicalDefenseBonus = 0,
    int attackBonus = 0,
    int defenseBonus = 0,
    int healthBonus = 0,
  }) : maxHpBonus = maxHpBonus != 0 ? maxHpBonus : healthBonus,
       physicalAttackBonus = physicalAttackBonus != 0
           ? physicalAttackBonus
           : attackBonus,
       physicalDefenseBonus = physicalDefenseBonus != 0
           ? physicalDefenseBonus
           : defenseBonus;

  final String potionStackKey;
  final String potionName;
  final String qualityLabel;
  final String dominantTraitId;
  final int maxHpBonus;
  final int physicalAttackBonus;
  final int physicalDefenseBonus;
  final int magicalAttackBonus;
  final int magicalDefenseBonus;
  final int speedBonus;
  final List<BattleStatModifier> statModifiers;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;

  int get attackBonus => physicalAttackBonus;

  int get defenseBonus => physicalDefenseBonus;

  int get healthBonus => maxHpBonus;
}
