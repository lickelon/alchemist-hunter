import 'package:flutter/foundation.dart';

enum EquipmentSlot { weapon, armor, accessory }

@immutable
class EquipmentBlueprint {
  const EquipmentBlueprint({
    required this.id,
    required this.name,
    required this.slot,
    required this.materialCosts,
    required this.attack,
    required this.defense,
    required this.health,
  });

  final String id;
  final String name;
  final EquipmentSlot slot;
  final Map<String, int> materialCosts;
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
  });

  final String id;
  final String blueprintId;
  final String name;
  final EquipmentSlot slot;
  final int attack;
  final int defense;
  final int health;
  final DateTime createdAt;
}
