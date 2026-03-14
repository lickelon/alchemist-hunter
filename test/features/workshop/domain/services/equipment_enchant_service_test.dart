import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/equipment_enchant_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weapon enchant favors attack from dominant trait', () {
    const EquipmentEnchantService service = EquipmentEnchantService();
    final EquipmentInstance sword = EquipmentInstance(
      id: 'eq_instance_1',
      blueprintId: 'eq_1',
      name: 'Bronze Sword',
      slot: EquipmentSlot.weapon,
      attack: 12,
      defense: 0,
      health: 0,
      createdAt: DateTime(2026, 1, 1, 10),
    );
    final CraftedPotion potion = CraftedPotion(
      id: 'cp_1',
      typePotionId: 'p_1',
      qualityGrade: PotionQualityGrade.a,
      qualityScore: 0.84,
      traits: const <String, double>{'t_atk': 0.7, 't_hp': 0.3},
      createdAt: DateTime(2026, 1, 1, 10),
    );
    const PotionBlueprint blueprint = PotionBlueprint(
      id: 'p_1',
      name: 'Potion 1',
      targetTraits: <String, double>{'t_atk': 0.6, 't_hp': 0.4},
      baseValue: 100,
      useType: PotionUseType.both,
    );

    final EquipmentEnchant enchant = service.buildEnchant(
      equipment: sword,
      potion: potion,
      blueprint: blueprint,
    );

    expect(enchant.label, 'Potion 1 A');
    expect(enchant.attackBonus, 13);
    expect(enchant.defenseBonus, 3);
    expect(enchant.healthBonus, 20);
  });
}
