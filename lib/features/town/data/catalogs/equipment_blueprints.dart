import 'package:alchemist_hunter/features/town/domain/models.dart';

const Map<String, String> townEquipmentMaterialNames = <String, String>{
  'm_1': 'Emberroot',
  'm_2': 'Ironbloom Bark',
  'm_3': 'Mossbone',
  'm_4': 'Gale Petal',
  'm_5': 'Sunleaf',
  'm_6': 'Nightsap Resin',
};

const List<EquipmentBlueprint> townEquipmentBlueprints = <EquipmentBlueprint>[
  EquipmentBlueprint(
    id: 'eq_1',
    name: 'Bronze Sword',
    slot: EquipmentSlot.weapon,
    materialCosts: <String, int>{'m_1': 2, 'm_2': 1},
    attack: 12,
    defense: 0,
    health: 0,
  ),
  EquipmentBlueprint(
    id: 'eq_2',
    name: 'Iron Buckler',
    slot: EquipmentSlot.armor,
    materialCosts: <String, int>{'m_2': 2, 'm_3': 1},
    attack: 0,
    defense: 10,
    health: 12,
  ),
  EquipmentBlueprint(
    id: 'eq_3',
    name: 'Hunter Charm',
    slot: EquipmentSlot.accessory,
    materialCosts: <String, int>{'m_4': 1, 'm_5': 1, 'm_6': 1},
    attack: 6,
    defense: 4,
    health: 18,
  ),
];
