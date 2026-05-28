import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

enum EquipmentSlot { weapon, armor, accessory }

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

  String get label => '$potionName $qualityLabel';
}

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

@immutable
class EquipmentInstance {
  const EquipmentInstance({
    required this.id,
    required this.blueprintId,
    required this.name,
    required this.slot,
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
    required this.createdAt,
    this.enchant,
  }) : maxHp = maxHp != 0 ? maxHp : health,
       physicalAttack = physicalAttack != 0 ? physicalAttack : attack,
       physicalDefense = physicalDefense != 0 ? physicalDefense : defense;

  final String id;
  final String blueprintId;
  final String name;
  final EquipmentSlot slot;
  final int maxHp;
  final int physicalAttack;
  final int physicalDefense;
  final int magicalAttack;
  final int magicalDefense;
  final int speed;
  final List<BattleStatModifier> statModifiers;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;
  final DateTime createdAt;
  final EquipmentEnchant? enchant;

  int get attack => physicalAttack;

  int get defense => physicalDefense;

  int get health => maxHp;

  int get totalMaxHp => maxHp + (enchant?.maxHpBonus ?? 0);

  int get totalPhysicalAttack =>
      physicalAttack + (enchant?.physicalAttackBonus ?? 0);

  int get totalPhysicalDefense =>
      physicalDefense + (enchant?.physicalDefenseBonus ?? 0);

  int get totalMagicalAttack =>
      magicalAttack + (enchant?.magicalAttackBonus ?? 0);

  int get totalMagicalDefense =>
      magicalDefense + (enchant?.magicalDefenseBonus ?? 0);

  int get totalSpeed => speed + (enchant?.speedBonus ?? 0);

  int get totalAttack => totalPhysicalAttack;

  int get totalDefense => totalPhysicalDefense;

  int get totalHealth => totalMaxHp;

  List<BattleStatModifier> get totalStatModifiers => <BattleStatModifier>[
    ...statModifiers,
    ...?enchant?.statModifiers,
  ];

  List<BattleModifier> get totalModifiers => <BattleModifier>[
    ...modifiers,
    ...?enchant?.modifiers,
  ];

  List<BattlePassiveEffect> get totalPassives => <BattlePassiveEffect>[
    ...passives,
    ...?enchant?.passives,
  ];

  EquipmentInstance copyWith({
    EquipmentEnchant? enchant,
    bool clearEnchant = false,
  }) {
    return EquipmentInstance(
      id: id,
      blueprintId: blueprintId,
      name: name,
      slot: slot,
      maxHp: maxHp,
      physicalAttack: physicalAttack,
      physicalDefense: physicalDefense,
      magicalAttack: magicalAttack,
      magicalDefense: magicalDefense,
      speed: speed,
      statModifiers: statModifiers,
      modifiers: modifiers,
      passives: passives,
      createdAt: createdAt,
      enchant: clearEnchant ? null : enchant ?? this.enchant,
    );
  }
}
