import 'dart:math';

import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_controller.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionController buildSession() {
    return SessionController(clock: () => DateTime(2026, 1, 1, 10));
  }

  BattleController buildController(
    SessionController session, {
    int battleSeed = 11,
  }) {
    return BattleController(session, BattleService(random: Random(battleSeed)));
  }

  test('runAutoBattle updates rewards progression and battle xp', () {
    final SessionController session = buildSession();
    final BattleController controller = buildController(session);
    final int previousGold = session.state.player.gold;
    final int previousEssence = session.state.player.essence;
    final int previousMercLevel =
        session.state.characters.mercenaries.first.level;
    final int previousMercXp = session.state.characters.mercenaries.first.xp;
    final int previousHomoLevel =
        session.state.characters.homunculi.first.level;
    final int previousHomoXp = session.state.characters.homunculi.first.xp;

    controller.runAutoBattle('stage_1');

    expect(session.state.player.gold, isNot(previousGold));
    expect(session.state.player.essence, greaterThan(previousEssence));
    expect(session.state.player.materialInventory, isNotEmpty);
    expect(
      session.state.characters.mercenaries.first.level > previousMercLevel ||
          session.state.characters.mercenaries.first.xp > previousMercXp,
      true,
    );
    expect(
      session.state.characters.homunculi.first.level > previousHomoLevel ||
          session.state.characters.homunculi.first.xp > previousHomoXp,
      true,
    );
    expect(session.state.workshop.logs.first, contains('Battle '));
  });

  test('runAutoBattle does not overflow xp at rank max level', () {
    final SessionController session = buildSession();
    final BattleController controller = buildController(session);
    final CharacterProgress merc = session.state.characters.mercenaries.first;
    final CharacterProgress homo = session.state.characters.homunculi.first;

    session.state = session.state.copyWith(
      characters: session.state.characters.copyWith(
        mercenaries: <CharacterProgress>[
          merc.copyWith(level: merc.maxLevelForRank, xp: 999),
        ],
        homunculi: <CharacterProgress>[
          homo.copyWith(level: homo.maxLevelForRank, xp: 999),
        ],
      ),
    );

    controller.runAutoBattle('stage_5');

    expect(
      session.state.characters.mercenaries.first.level,
      merc.maxLevelForRank,
    );
    expect(
      session.state.characters.homunculi.first.level,
      homo.maxLevelForRank,
    );
    expect(session.state.characters.mercenaries.first.xp, 0);
    expect(session.state.characters.homunculi.first.xp, 0);
  });
}
