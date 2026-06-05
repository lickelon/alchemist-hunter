import 'package:flutter_test/flutter_test.dart';
import '../../../../../support/catalog_fixtures.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/use_cases/configure_workshop_support_assignment_use_case.dart';

void main() {
  test('toggleHomunculus assigns and unassigns a function slot', () {
    final SessionState state =
        createTestInitialSessionState(DateTime(2026, 1, 1, 10)).copyWith(
          battle: createTestInitialSessionState(DateTime(2026, 1, 1, 10)).battle
              .copyWith(
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
    expect(added.workshop.supportAssignmentsByFunction, const <String, String>{
      'extraction': 'homo_1',
    });

    final SessionState removed = useCase.toggleHomunculus(
      state: added,
      slotId: 'extraction',
      characterId: 'homo_1',
    );
    expect(removed.workshop.supportAssignmentsByFunction, isEmpty);
  });

  test('toggleHomunculus rejects reassignment without prior removal', () {
    final SessionState state =
        createTestInitialSessionState(DateTime(2026, 1, 1, 10)).copyWith(
          battle: createTestInitialSessionState(DateTime(2026, 1, 1, 10)).battle
              .copyWith(
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

  test(
    'toggleHomunculus rejects mercenary and caps total assigned count at three',
    () {
      final SessionState baseState = createTestInitialSessionState(
        DateTime(2026, 1, 1, 10),
      );
      final SessionState state = baseState.copyWith(
        characters: baseState.characters.copyWith(
          homunculi: <CharacterProgress>[
            baseState.characters.homunculi.first,
            CharacterProgress(
              id: 'homo_2',
              name: '전사',
              type: CharacterType.homunculus,
              combatJobId: CombatJobIds.homunculusWarrior,
              level: 1,
              rank: 1,
              xp: 0,
              homunculusTier: HomunculusTier.nigredo,
            ),
            CharacterProgress(
              id: 'homo_3',
              name: '도적',
              type: CharacterType.homunculus,
              combatJobId: CombatJobIds.homunculusRogue,
              level: 1,
              rank: 1,
              xp: 0,
              homunculusTier: HomunculusTier.nigredo,
            ),
            CharacterProgress(
              id: 'homo_4',
              name: '궁수',
              type: CharacterType.homunculus,
              combatJobId: CombatJobIds.homunculusArcher,
              level: 1,
              rank: 1,
              xp: 0,
              homunculusTier: HomunculusTier.nigredo,
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
    },
  );
}
