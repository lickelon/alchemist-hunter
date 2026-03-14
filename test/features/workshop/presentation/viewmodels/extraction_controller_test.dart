import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/extraction_controller.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/alchemy_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionController buildSession() {
    return SessionController(clock: () => DateTime(2026, 1, 1, 10));
  }

  test('extractMaterial consumes material and stores extracted traits', () {
    final SessionController session = buildSession();
    final WorkshopExtractionController controller =
        WorkshopExtractionController(session, AlchemyService());

    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 1},
      ),
    );

    controller.extractMaterial('m_1', 'full_basic');

    expect(session.state.player.materialInventory.containsKey('m_1'), false);
    expect(session.state.workshop.extractedTraitInventory['t_hp'], isNotNull);
    expect(session.state.workshop.extractedTraitInventory['t_spd'], isNotNull);
    expect(session.state.workshop.logs.first, 'Extracted m_1 with full_basic');
  });
}
