import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('totalPower includes equipped item stats', () {
    const BattlePartyPowerService service = BattlePartyPowerService();
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

    const CharactersState baseState = CharactersState(
      mercenaries: <CharacterProgress>[
        CharacterProgress(
          id: 'merc_1',
          name: 'Rookie Swordsman',
          type: CharacterType.mercenary,
          level: 1,
          rank: 1,
          xp: 0,
          mercenaryTier: MercenaryTier.rookie,
        ),
      ],
      homunculi: <CharacterProgress>[
        CharacterProgress(
          id: 'homo_1',
          name: 'Nigredo Seed',
          type: CharacterType.homunculus,
          level: 1,
          rank: 1,
          xp: 0,
          homunculusTier: HomunculusTier.nigredo,
        ),
      ],
    );

    final int basePower = service.totalPower(baseState);
    final CharactersState equippedState = baseState.copyWith(
      mercenaries: <CharacterProgress>[
        baseState.mercenaries.first.copyWith(
          equipment: const CharacterEquipmentLoadout().equip(sword),
        ),
      ],
    );

    expect(basePower, 230);
    expect(service.totalPower(equippedState), 254);
  });
}
