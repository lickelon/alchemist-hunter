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
    physicalAttack: 12,
  ),
  EquipmentBlueprint(
    id: 'eq_2',
    name: 'Iron Buckler',
    slot: EquipmentSlot.armor,
    materialCosts: <String, int>{'m_2': 2, 'm_3': 1},
    maxHp: 12,
    physicalDefense: 10,
    magicalDefense: 4,
  ),
  EquipmentBlueprint(
    id: 'eq_3',
    name: 'Hunter Charm',
    slot: EquipmentSlot.accessory,
    materialCosts: <String, int>{'m_4': 1, 'm_5': 1, 'm_6': 1},
    maxHp: 18,
    physicalAttack: 4,
    magicalAttack: 4,
    speed: 2,
  ),
];
