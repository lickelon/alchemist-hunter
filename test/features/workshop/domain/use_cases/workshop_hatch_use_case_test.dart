import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_homunculus_hatch_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_hatch_use_case.dart';

void main() {
  test('hatchHomunculus reserves resources and enqueues homunculus job', () {
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
      workshopSupportService: const WorkshopSupportService(),
    );

    expect(nextState.player.essence, 80);
    expect(nextState.player.arcaneDust, 0);
    expect(nextState.player.materialInventory, isEmpty);
    expect(nextState.workshop.extractedTraitInventory, isEmpty);
    expect(nextState.characters.homunculi, hasLength(1));
    expect(nextState.workshop.queue, hasLength(1));
    expect(nextState.workshop.queue.first.type, WorkshopJobType.hatch);
    expect(nextState.workshop.queue.first.completedHomunculus?.name, 'Vital Nigredo');
    expect(
      nextState.workshop.queue.first.completedHomunculus?.homunculusOrigin,
      'Vital Seed Flask',
    );
    expect(
      nextState.workshop.queue.first.completedHomunculus?.homunculusRole,
      '지원',
    );
    expect(
      nextState.workshop.queue.first.completedHomunculus?.homunculusSupportEffect,
      '파티 생존력 보조',
    );
  });

  test('hatchHomunculus applies hatch slot arcane dust discount', () {
    final SessionState state = createInitialSessionState(DateTime(2026, 1, 1, 10))
        .copyWith(
          player: createInitialSessionState(
            DateTime(2026, 1, 1, 10),
          ).player.copyWith(
            essence: 120,
            arcaneDust: 1,
            materialInventory: const <String, int>{'m_1': 2, 'm_3': 1},
          ),
          workshop: createInitialSessionState(
            DateTime(2026, 1, 1, 10),
          ).workshop.copyWith(
            extractedTraitInventory: const <String, double>{'t_hp': 0.8},
            supportAssignmentsByFunction: const <String, String>{
              'hatch': 'homo_1',
            },
          ),
        );
    final recipe = const StaticHomunculusHatchRepository().findById(
      'hatch_vital_seed',
    )!;

    final nextState = const WorkshopHatchUseCase().hatchHomunculus(
      state: state,
      recipe: recipe,
      now: DateTime(2026, 1, 1, 11),
      workshopSupportService: const WorkshopSupportService(),
    );

    expect(nextState.player.arcaneDust, 0);
    expect(nextState.characters.homunculi, hasLength(1));
    expect(nextState.workshop.queue, hasLength(1));
  });
}
