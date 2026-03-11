import 'package:alchemist_hunter/features/characters/application/character_providers.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
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

    final CharacterProgress updated = session.state.characters.mercenaries.first;
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

    final CharacterProgress updated = session.state.characters.mercenaries.first;
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
}
