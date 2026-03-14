import 'package:alchemist_hunter/features/characters/presentation/character_providers.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionController buildSession() {
    return SessionController(clock: () => DateTime(2026, 1, 1, 10));
  }

  test('rankUp resets level/xp and increases rank', () {
    final SessionController session = buildSession();
    final CharacterController controller = CharacterController(session);

    final CharacterProgress target = session.state.characters.mercenaries.first;
    session.state = session.state.copyWith(
      characters: session.state.characters.copyWith(
        mercenaries: <CharacterProgress>[
          target.copyWith(level: target.maxLevelForRank, xp: 0),
        ],
      ),
    );

    controller.rankUp(CharacterType.mercenary, target.id);

    final CharacterProgress updated =
        session.state.characters.mercenaries.first;
    expect(updated.rank, 2);
    expect(updated.level, 1);
    expect(updated.xp, 0);
  });

  test('tierUp consumes material and advances tier', () {
    final SessionController session = buildSession();
    final CharacterController controller = CharacterController(session);
    final CharacterProgress target = session.state.characters.mercenaries.first;
    final String matKey = 'tier_mat_mercenary_2';

    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: <String, int>{matKey: 1},
      ),
      characters: session.state.characters.copyWith(
        mercenaries: <CharacterProgress>[
          target.copyWith(
            rank: target.maxRankForCurrentTier,
            level: target.maxLevelForRank,
          ),
        ],
      ),
    );

    controller.tierUp(CharacterType.mercenary, target.id);

    final CharacterProgress updated =
        session.state.characters.mercenaries.first;
    expect(updated.tierIndex, 2);
    expect(updated.rank, 1);
    expect(updated.level, 1);
    expect(session.state.player.materialInventory.containsKey(matKey), false);
  });

  test('xpToNextLevel is zero at max level', () {
    final SessionController session = buildSession();
    final CharacterProgress target = session.state.characters.mercenaries.first;
    final CharacterProgress maxed = target.copyWith(
      level: target.maxLevelForRank,
      xp: 0,
    );

    expect(maxed.xpToNextLevel, 0);
  });

  test('equip and unequip moves equipment between storage and slot', () {
    final SessionController session = buildSession();
    final CharacterController controller = CharacterController(session);

    session.state = session.state.copyWith(
      town: session.state.town.copyWith(
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
        ],
      ),
    );

    controller.equip(CharacterType.mercenary, 'merc_1', 'eq_instance_1');

    expect(
      session.state.characters.mercenaries.first.equipment.weapon?.name,
      'Bronze Sword',
    );
    expect(session.state.town.equipmentInventory, isEmpty);

    controller.unequip(CharacterType.mercenary, 'merc_1', EquipmentSlot.weapon);

    expect(session.state.characters.mercenaries.first.equipment.weapon, isNull);
    expect(session.state.town.equipmentInventory, hasLength(1));
    expect(session.state.town.equipmentInventory.first.name, 'Bronze Sword');
  });
}
