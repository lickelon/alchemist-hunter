import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/session_factory.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_hatch_use_case.dart';

void main() {
  test('hatchHomunculus consumes resources and appends homunculus', () {
    final state = createInitialSessionState(DateTime(2026, 1, 1, 10)).copyWith(
      player: createInitialSessionState(
        DateTime(2026, 1, 1, 10),
      ).player.copyWith(
        essence: 120,
        arcaneDust: 2,
        materialInventory: const <String, int>{'m_1': 2, 'm_3': 1},
      ),
      workshop: createInitialSessionState(
        DateTime(2026, 1, 1, 10),
      ).workshop.copyWith(
        extractedTraitInventory: const <String, double>{'t_hp': 0.8},
      ),
    );
    final recipe = const StaticHomunculusHatchRepository().findById(
      'hatch_vital_seed',
    )!;

    final nextState = const WorkshopHatchUseCase().hatchHomunculus(
      state: state,
      recipe: recipe,
      now: DateTime(2026, 1, 1, 11),
    );

    expect(nextState.player.essence, 80);
    expect(nextState.player.arcaneDust, 0);
    expect(nextState.player.materialInventory, isEmpty);
    expect(nextState.workshop.extractedTraitInventory, isEmpty);
    expect(nextState.characters.homunculi, hasLength(2));
    expect(nextState.characters.homunculi.last.name, 'Vital Nigredo');
  });
}
