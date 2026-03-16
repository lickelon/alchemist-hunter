import 'dart:math';

import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_controller.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/static_battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionController buildSession() {
    return SessionController(clock: () => DateTime(2026, 1, 1, 10));
  }

  BattleController buildController(
    SessionController session, {
    int battleSeed = 11,
  }) {
    return BattleController(
      session,
      battleService: BattleService(random: Random(battleSeed)),
      battleCatalogRepository: const StaticBattleCatalogRepository(),
    );
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
      battle: session.state.battle.copyWith(
        stageAssignments: <String, List<String>>{
          ...session.state.battle.stageAssignments,
          'stage_5': <String>[merc.id, homo.id],
        },
      ),
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

  test('equipped stats raise battle power and secure stage_5 clear', () {
    final SessionController session = buildSession();
    final BattleController controller = buildController(session, battleSeed: 1);
    final CharacterProgress merc = session.state.characters.mercenaries.first;

    session.state = session.state.copyWith(
      battle: session.state.battle.copyWith(
        stageAssignments: <String, List<String>>{
          ...session.state.battle.stageAssignments,
          'stage_5': <String>[merc.id],
        },
      ),
      characters: session.state.characters.copyWith(
        mercenaries: <CharacterProgress>[
          merc.copyWith(
            equipment: CharacterEquipmentLoadout(
              weapon: EquipmentInstance(
                id: 'eq_instance_1',
                blueprintId: 'eq_1',
                name: 'Bronze Sword',
                slot: EquipmentSlot.weapon,
                attack: 12,
                defense: 0,
                health: 0,
                createdAt: DateTime(2026, 1, 1, 10),
              ),
            ),
          ),
        ],
      ),
    );

    controller.runAutoBattle('stage_5');

    expect(
      session.state.workshop.logs.first,
      contains('Battle 성공'),
    );
    expect(session.state.player.essence, 126);
  });

  test('toggleStageAssignment stores assignment per stage', () {
    final SessionController session = buildSession();
    final BattleController controller = buildController(session);
    session.state = session.state.copyWith(
      battle: session.state.battle.copyWith(
        stageAssignments: const <String, List<String>>{},
      ),
    );

    controller.toggleStageAssignment('stage_2', 'merc_1');

    expect(session.state.battle.stageAssignments['stage_2'], <String>['merc_1']);
    expect(
      session.state.workshop.logs.first,
      contains('Assigned Rookie Swordsman to stage_2'),
    );
  });

  test('toggleStageAssignment blocks workshop-assigned homunculus', () {
    final SessionController session = buildSession();
    final BattleController controller = buildController(session);

    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        supportAssignmentsByFunction: const <String, String>{
          'extraction': 'homo_1',
        },
      ),
      battle: session.state.battle.copyWith(stageAssignments: const <String, List<String>>{}),
    );

    controller.toggleStageAssignment('stage_2', 'homo_1');

    expect(session.state.battle.stageAssignments.containsKey('stage_2'), isFalse);
    expect(session.state.workshop.logs.first, 'Character assigned to workshop');
  });
}
