import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models/equipment/equipment_slot.dart';
import 'package:flutter/foundation.dart';

@immutable
class EquipmentBlueprint {
  const EquipmentBlueprint({
    required this.id,
    required this.name,
    required this.slot,
    required this.materialCosts,
    this.craftDuration = const Duration(seconds: 30),
    this.magicalAttack = 0,
    this.magicalDefense = 0,
    this.speed = 0,
    this.statModifiers = const <BattleStatModifier>[],
    this.modifiers = const <BattleModifier>[],
    this.passives = const <BattlePassiveEffect>[],
    int maxHp = 0,
    int physicalAttack = 0,
    int physicalDefense = 0,
    int attack = 0,
    int defense = 0,
    int health = 0,
  }) : maxHp = maxHp != 0 ? maxHp : health,
       physicalAttack = physicalAttack != 0 ? physicalAttack : attack,
       physicalDefense = physicalDefense != 0 ? physicalDefense : defense;

  final String id;
  final String name;
  final EquipmentSlot slot;
  final Map<String, int> materialCosts;
  final Duration craftDuration;
  final int maxHp;
  final int physicalAttack;
  final int physicalDefense;
  final int magicalAttack;
  final int magicalDefense;
  final int speed;
  final List<BattleStatModifier> statModifiers;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;

  int get attack => physicalAttack;

  int get defense => physicalDefense;

  int get health => maxHp;
}
