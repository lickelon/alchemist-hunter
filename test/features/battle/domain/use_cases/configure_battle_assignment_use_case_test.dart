import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/session_factory.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/configure_battle_assignment_use_case.dart';

void main() {
  test('toggleCharacter adds and removes stage assignment', () {
    final state = createInitialSessionState(DateTime(2026, 1, 1, 10)).copyWith(
      battle: createInitialSessionState(
        DateTime(2026, 1, 1, 10),
      ).battle.copyWith(stageAssignments: const <String, List<String>>{}),
    );
    const ConfigureBattleAssignmentUseCase useCase =
        ConfigureBattleAssignmentUseCase();

    final added = useCase.toggleCharacter(
      state: state,
      stageId: 'stage_2',
      characterId: 'merc_1',
    );
    expect(added.battle.stageAssignments['stage_2'], <String>['merc_1']);

    final removed = useCase.toggleCharacter(
      state: added,
      stageId: 'stage_2',
      characterId: 'merc_1',
    );
    expect(removed.battle.stageAssignments.containsKey('stage_2'), isFalse);
  });
}
