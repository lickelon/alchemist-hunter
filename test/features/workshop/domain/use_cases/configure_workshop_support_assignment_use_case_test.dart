import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/configure_workshop_support_assignment_use_case.dart';

void main() {
  test('toggleHomunculus assigns and unassigns a function slot', () {
    final SessionState state = createInitialSessionState(
      DateTime(2026, 1, 1, 10),
    ).copyWith(
      battle: createInitialSessionState(
        DateTime(2026, 1, 1, 10),
      ).battle.copyWith(
        stageAssignments: const <String, List<String>>{
          'stage_1': <String>['merc_1'],
        },
      ),
    );
    const ConfigureWorkshopSupportAssignmentUseCase useCase =
        ConfigureWorkshopSupportAssignmentUseCase();

    final SessionState added = useCase.toggleHomunculus(
      state: state,
      slotId: 'extraction',
      characterId: 'homo_1',
    );
    expect(
      added.workshop.supportAssignmentsByFunction,
      const <String, String>{'extraction': 'homo_1'},
    );

    final SessionState removed = useCase.toggleHomunculus(
      state: added,
      slotId: 'extraction',
      characterId: 'homo_1',
    );
    expect(removed.workshop.supportAssignmentsByFunction, isEmpty);
  });

  test('toggleHomunculus rejects reassignment without prior removal', () {
    final SessionState state = createInitialSessionState(
      DateTime(2026, 1, 1, 10),
    ).copyWith(
      battle: createInitialSessionState(
        DateTime(2026, 1, 1, 10),
      ).battle.copyWith(
        stageAssignments: const <String, List<String>>{
          'stage_1': <String>['merc_1'],
        },
      ),
    );
    const ConfigureWorkshopSupportAssignmentUseCase useCase =
        ConfigureWorkshopSupportAssignmentUseCase();

    final SessionState assigned = useCase.toggleHomunculus(
      state: state,
      slotId: 'extraction',
      characterId: 'homo_1',
    );

    expect(
      assigned.workshop.supportAssignmentsByFunction,
      const <String, String>{'extraction': 'homo_1'},
    );
    final SessionState unchanged = useCase.toggleHomunculus(
      state: assigned,
      slotId: 'enchant',
      characterId: 'homo_1',
    );
    expect(
      unchanged.workshop.supportAssignmentsByFunction,
      const <String, String>{'extraction': 'homo_1'},
    );
  });

  test('toggleHomunculus rejects mercenary and caps total assigned count at three', () {
    final SessionState baseState = createInitialSessionState(
      DateTime(2026, 1, 1, 10),
    );
    final SessionState state = baseState.copyWith(
      characters: baseState.characters.copyWith(
        homunculi: <CharacterProgress>[
          baseState.characters.homunculi.first,
          CharacterProgress(
            id: 'homo_2',
            name: 'Guard Nigredo',
            type: CharacterType.homunculus,
            level: 1,
            rank: 1,
            xp: 0,
            homunculusTier: HomunculusTier.nigredo,
            homunculusOrigin: 'Guard Seed Flask',
            homunculusRole: '방어',
            homunculusSupportEffect: '방어 안정화 보조',
          ),
          CharacterProgress(
            id: 'homo_3',
            name: 'Swift Nigredo',
            type: CharacterType.homunculus,
            level: 1,
            rank: 1,
            xp: 0,
            homunculusTier: HomunculusTier.nigredo,
            homunculusOrigin: 'Swift Seed Flask',
            homunculusRole: '기동',
            homunculusSupportEffect: '행동 속도 보조',
          ),
          CharacterProgress(
            id: 'homo_4',
            name: 'Vital Nigredo',
            type: CharacterType.homunculus,
            level: 1,
            rank: 1,
            xp: 0,
            homunculusTier: HomunculusTier.nigredo,
            homunculusOrigin: 'Vital Seed Flask',
            homunculusRole: '지원',
            homunculusSupportEffect: '파티 생존력 보조',
          ),
        ],
      ),
    );
    const ConfigureWorkshopSupportAssignmentUseCase useCase =
        ConfigureWorkshopSupportAssignmentUseCase();

    final SessionState mercenaryIgnored = useCase.toggleHomunculus(
      state: state,
      slotId: 'extraction',
      characterId: 'merc_1',
    );
    expect(mercenaryIgnored.workshop.supportAssignmentsByFunction, isEmpty);

    final SessionState battleAssigned = useCase.toggleHomunculus(
      state: baseState,
      slotId: 'extraction',
      characterId: 'homo_1',
    );
    expect(battleAssigned.workshop.supportAssignmentsByFunction, isEmpty);

    final SessionState full = state.copyWith(
      workshop: state.workshop.copyWith(
        supportAssignmentsByFunction: const <String, String>{
          'extraction': 'homo_1',
          'crafting': 'homo_2',
          'enchant': 'homo_3',
        },
      ),
    );
    final SessionState unchanged = useCase.toggleHomunculus(
      state: full,
      slotId: 'hatch',
      characterId: 'homo_4',
    );
    expect(
      unchanged.workshop.supportAssignmentsByFunction,
      const <String, String>{
        'extraction': 'homo_1',
        'crafting': 'homo_2',
        'enchant': 'homo_3',
      },
    );
  });
}
