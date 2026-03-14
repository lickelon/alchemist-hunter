import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/use_cases/character_equipment_use_case.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionState buildState() {
    return createInitialSessionState(DateTime(2026, 1, 1, 10)).copyWith(
      town: createInitialSessionState(DateTime(2026, 1, 1, 10)).town.copyWith(
        equipmentInventory: <EquipmentInstance>[
          EquipmentInstance(
            id: 'eq_instance_1',
            blueprintId: 'eq_1',
            name: 'Bronze Sword',
            slot: EquipmentSlot.weapon,
            attack: 12,
            defense: 0,
            health: 0,
            createdAt: DateTime(2026, 1, 1, 10),
          ),
          EquipmentInstance(
            id: 'eq_instance_2',
            blueprintId: 'eq_2',
            name: 'Iron Buckler',
            slot: EquipmentSlot.armor,
            attack: 0,
            defense: 10,
            health: 12,
            createdAt: DateTime(2026, 1, 1, 10, 1),
          ),
          EquipmentInstance(
            id: 'eq_instance_3',
            blueprintId: 'eq_4',
            name: 'Steel Sword',
            slot: EquipmentSlot.weapon,
            attack: 18,
            defense: 0,
            health: 0,
            createdAt: DateTime(2026, 1, 1, 10, 2),
          ),
        ],
      ),
    );
  }

  test('equip moves stored equipment into character slot', () {
    final CharacterEquipmentUseCase useCase = CharacterEquipmentUseCase();
    final SessionState nextState = useCase.equip(
      state: buildState(),
      type: CharacterType.mercenary,
      characterId: 'merc_1',
      equipmentId: 'eq_instance_1',
    );

    final CharacterProgress character = nextState.characters.mercenaries.first;
    expect(character.equipment.weapon?.name, 'Bronze Sword');
    expect(nextState.town.equipmentInventory, hasLength(2));
    expect(
      nextState.town.equipmentInventory.any(
        (EquipmentInstance item) => item.id == 'eq_instance_1',
      ),
      isFalse,
    );
  });

  test('equip returns previous slot item to storage', () {
    final CharacterEquipmentUseCase useCase = CharacterEquipmentUseCase();
    final SessionState equippedState = useCase.equip(
      state: buildState(),
      type: CharacterType.mercenary,
      characterId: 'merc_1',
      equipmentId: 'eq_instance_1',
    );

    final SessionState nextState = useCase.equip(
      state: equippedState,
      type: CharacterType.mercenary,
      characterId: 'merc_1',
      equipmentId: 'eq_instance_3',
    );

    final CharacterProgress character = nextState.characters.mercenaries.first;
    expect(character.equipment.weapon?.name, 'Steel Sword');
    expect(
      nextState.town.equipmentInventory
          .firstWhere((EquipmentInstance item) => item.id == 'eq_instance_1')
          .name,
      'Bronze Sword',
    );
  });

  test('unequip returns equipped item to storage', () {
    final CharacterEquipmentUseCase useCase = CharacterEquipmentUseCase();
    final SessionState equippedState = useCase.equip(
      state: buildState(),
      type: CharacterType.mercenary,
      characterId: 'merc_1',
      equipmentId: 'eq_instance_1',
    );

    final SessionState nextState = useCase.unequip(
      state: equippedState,
      type: CharacterType.mercenary,
      characterId: 'merc_1',
      slot: EquipmentSlot.weapon,
    );

    final CharacterProgress character = nextState.characters.mercenaries.first;
    expect(character.equipment.weapon, isNull);
    expect(nextState.town.equipmentInventory, hasLength(3));
    expect(nextState.town.equipmentInventory.first.name, 'Bronze Sword');
  });
}
