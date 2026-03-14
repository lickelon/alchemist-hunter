import 'package:alchemist_hunter/features/town/domain/models.dart';

const List<EquipmentBlueprint> townEquipmentBlueprints = <EquipmentBlueprint>[
  EquipmentBlueprint(
    id: 'eq_1',
    name: 'Bronze Sword',
    slot: EquipmentSlot.weapon,
    goldCost: 180,
    attack: 12,
    defense: 0,
    health: 0,
  ),
  EquipmentBlueprint(
    id: 'eq_2',
    name: 'Iron Buckler',
    slot: EquipmentSlot.armor,
    goldCost: 160,
    attack: 0,
    defense: 10,
    health: 12,
  ),
  EquipmentBlueprint(
    id: 'eq_3',
    name: 'Hunter Charm',
    slot: EquipmentSlot.accessory,
    goldCost: 220,
    attack: 6,
    defense: 4,
    health: 18,
  ),
];
