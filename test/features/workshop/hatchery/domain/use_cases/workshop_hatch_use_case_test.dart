import 'package:flutter_test/flutter_test.dart';
import '../../../../../support/catalog_fixtures.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/domain/use_cases/workshop_hatch_use_case.dart';

void main() {
  test('hatchHomunculus reserves resources and enqueues homunculus job', () {
    final state = createTestInitialSessionState(DateTime(2026, 1, 1, 10))
        .copyWith(
          player: createTestInitialSessionState(DateTime(2026, 1, 1, 10)).player
              .copyWith(
                essence: 120,
                arcaneDust: 2,
                materialInventory: const <String, int>{'m_1': 2, 'm_3': 1},
              ),
          workshop: createTestInitialSessionState(DateTime(2026, 1, 1, 10))
              .workshop
              .copyWith(
                extractedTraitInventory: const <String, double>{'t_hp': 0.8},
              ),
        );
    final recipe = testHomunculusHatchRepository.findById(
      'hatch_nigredo_mage',
    )!;

    final nextState = const WorkshopHatchUseCase().hatchHomunculus(
      state: state,
      recipe: recipe,
      now: DateTime(2026, 1, 1, 11),
      workshopSupportService: const WorkshopSupportService(),
      battleCatalogRepository: testBattleCatalogRepository,
    );

    expect(nextState.player.essence, 80);
    expect(nextState.player.arcaneDust, 0);
    expect(nextState.player.materialInventory, isEmpty);
    expect(nextState.workshop.extractedTraitInventory, isEmpty);
    expect(nextState.characters.homunculi, hasLength(1));
    expect(nextState.workshop.queue, hasLength(1));
    expect(nextState.workshop.queue.first.type, WorkshopJobType.hatch);
    expect(nextState.workshop.queue.first.completedHomunculus?.name, '마법사');
    expect(
      nextState.workshop.queue.first.completedHomunculus?.combatJobId,
      'homunculus_mage',
    );
    expect(
      nextState.workshop.queue.first.completedHomunculus?.homunculusOrigin,
      isNull,
    );
    expect(
      nextState.workshop.queue.first.completedHomunculus?.homunculusRole,
      isNull,
    );
    expect(
      nextState
          .workshop
          .queue
          .first
          .completedHomunculus
          ?.homunculusSupportEffect,
      isNull,
    );
    expect(nextState.workshop.queue.first.title, 'Nigredo 마법사');
  });

  test('hatchHomunculus applies hatch slot arcane discount', () {
    final SessionState state =
        createTestInitialSessionState(DateTime(2026, 1, 1, 10)).copyWith(
          player: createTestInitialSessionState(DateTime(2026, 1, 1, 10)).player
              .copyWith(
                essence: 120,
                arcaneDust: 1,
                materialInventory: const <String, int>{'m_1': 2, 'm_3': 1},
              ),
          workshop: createTestInitialSessionState(DateTime(2026, 1, 1, 10))
              .workshop
              .copyWith(
                extractedTraitInventory: const <String, double>{'t_hp': 0.8},
                supportAssignmentsByFunction: const <String, String>{
                  'hatch': 'homo_1',
                },
              ),
        );
    final recipe = testHomunculusHatchRepository.findById(
      'hatch_nigredo_mage',
    )!;

    final nextState = const WorkshopHatchUseCase().hatchHomunculus(
      state: state,
      recipe: recipe,
      now: DateTime(2026, 1, 1, 11),
      workshopSupportService: const WorkshopSupportService(),
      battleCatalogRepository: testBattleCatalogRepository,
    );

    expect(nextState.player.arcaneDust, 0);
    expect(nextState.characters.homunculi, hasLength(1));
    expect(nextState.workshop.queue, hasLength(1));
  });
}
