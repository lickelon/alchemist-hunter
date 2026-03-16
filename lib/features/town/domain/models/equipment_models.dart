import 'package:flutter/foundation.dart';

enum EquipmentSlot { weapon, armor, accessory }

@immutable
class EquipmentEnchant {
  const EquipmentEnchant({
    required this.potionStackKey,
    required this.potionName,
    required this.qualityLabel,
    required this.dominantTraitId,
    required this.attackBonus,
    required this.defenseBonus,
    required this.healthBonus,
  });

  final String potionStackKey;
  final String potionName;
  final String qualityLabel;
  final String dominantTraitId;
  final int attackBonus;
  final int defenseBonus;
  final int healthBonus;

  String get label => '$potionName $qualityLabel';

  String get statLabel =>
      'ATK +$attackBonus / DEF +$defenseBonus / HP +$healthBonus';
}

@immutable
class EquipmentBlueprint {
  const EquipmentBlueprint({
    required this.id,
    required this.name,
    required this.slot,
    required this.materialCosts,
    this.craftDuration = const Duration(seconds: 30),
    required this.attack,
    required this.defense,
    required this.health,
  });

  final String id;
  final String name;
  final EquipmentSlot slot;
  final Map<String, int> materialCosts;
  final Duration craftDuration;
  final int attack;
  final int defense;
  final int health;
}

@immutable
class EquipmentInstance {
  const EquipmentInstance({
    required this.id,
    required this.blueprintId,
    required this.name,
    required this.slot,
    required this.attack,
    required this.defense,
    required this.health,
    required this.createdAt,
    this.enchant,
  });

  final String id;
  final String blueprintId;
  final String name;
  final EquipmentSlot slot;
  final int attack;
  final int defense;
  final int health;
  final DateTime createdAt;
  final EquipmentEnchant? enchant;

  int get totalAttack => attack + (enchant?.attackBonus ?? 0);

  int get totalDefense => defense + (enchant?.defenseBonus ?? 0);

  int get totalHealth => health + (enchant?.healthBonus ?? 0);

  EquipmentInstance copyWith({
    EquipmentEnchant? enchant,
    bool clearEnchant = false,
  }) {
    return EquipmentInstance(
      id: id,
      blueprintId: blueprintId,
      name: name,
      slot: slot,
      attack: attack,
      defense: defense,
      health: health,
      createdAt: createdAt,
      enchant: clearEnchant ? null : enchant ?? this.enchant,
    );
  }
}
