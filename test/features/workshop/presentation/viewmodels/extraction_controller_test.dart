import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/extraction_controller.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/alchemy_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionController buildSession() {
    return SessionController(clock: () => DateTime(2026, 1, 1, 10));
  }

  test('extractMaterial consumes material and stores extracted traits', () {
    final SessionController session = buildSession();
    final WorkshopExtractionController
    controller = WorkshopExtractionController(
      session,
      AlchemyService(),
      materialCatalogRepository: const StaticMaterialCatalogRepository(),
      extractionProfileRepository: const StaticExtractionProfileRepository(),
      workshopSkillTreeRepository: const StaticWorkshopSkillTreeRepository(),
      workshopSkillTreeService: const WorkshopSkillTreeService(),
      workshopSupportService: const WorkshopSupportService(),
    );

    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 1},
      ),
    );

    controller.extractMaterial('m_1', 'full_basic');

    expect(session.state.player.materialInventory.containsKey('m_1'), false);
    expect(session.state.workshop.queue, hasLength(1));
    expect(session.state.workshop.queue.first.type, WorkshopJobType.extraction);
    expect(
      session.state.workshop.queue.first.completedExtractedTraits['t_hp'],
      isNotNull,
    );
    expect(
      session.state.workshop.queue.first.completedExtractedTraits['t_spd'],
      isNotNull,
    );
    expect(session.state.workshop.logs.first, '추출 등록 / m_1 x1');
  });

  test('extractMaterial supports bulk quantity', () {
    final SessionController session = buildSession();
    final WorkshopExtractionController
    controller = WorkshopExtractionController(
      session,
      AlchemyService(),
      materialCatalogRepository: const StaticMaterialCatalogRepository(),
      extractionProfileRepository: const StaticExtractionProfileRepository(),
      workshopSkillTreeRepository: const StaticWorkshopSkillTreeRepository(),
      workshopSkillTreeService: const WorkshopSkillTreeService(),
      workshopSupportService: const WorkshopSupportService(),
    );

    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 3},
      ),
    );

    controller.extractMaterial('m_1', 'full_basic', quantity: 2);

    expect(session.state.player.materialInventory['m_1'], 1);
    expect(
      session.state.workshop.queue.first.completedExtractedTraits['t_hp'],
      closeTo(1.7, 0.0001),
    );
    expect(
      session.state.workshop.queue.first.completedExtractedTraits['t_spd'],
      closeTo(1.7, 0.0001),
    );
    expect(session.state.workshop.logs.first, '추출 등록 / m_1 x2');
  });

  test('extractMaterial applies alembic yield bonus', () {
    final SessionController session = buildSession();
    final WorkshopExtractionController
    controller = WorkshopExtractionController(
      session,
      AlchemyService(),
      materialCatalogRepository: const StaticMaterialCatalogRepository(),
      extractionProfileRepository: const StaticExtractionProfileRepository(),
      workshopSkillTreeRepository: const StaticWorkshopSkillTreeRepository(),
      workshopSkillTreeService: const WorkshopSkillTreeService(),
      workshopSupportService: const WorkshopSupportService(),
    );

    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 1},
      ),
      workshop: session.state.workshop.copyWith(
        skillTree: session.state.workshop.skillTree.copyWith(
          nodeLevels: const <String, int>{'workshop_alembic': 1},
          unlockedNodes: const <String>{'workshop_alembic'},
        ),
      ),
    );

    controller.extractMaterial('m_1', 'full_basic');

    expect(
      session.state.workshop.queue.first.completedExtractedTraits['t_hp'],
      closeTo(0.918, 0.0001),
    );
  });

  test('extractMaterial applies workshop support yield bonus', () {
    final SessionController session = buildSession();
    final WorkshopExtractionController
    controller = WorkshopExtractionController(
      session,
      AlchemyService(),
      materialCatalogRepository: const StaticMaterialCatalogRepository(),
      extractionProfileRepository: const StaticExtractionProfileRepository(),
      workshopSkillTreeRepository: const StaticWorkshopSkillTreeRepository(),
      workshopSkillTreeService: const WorkshopSkillTreeService(),
      workshopSupportService: const WorkshopSupportService(),
    );

    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 1},
      ),
      workshop: session.state.workshop.copyWith(
        supportAssignmentsByFunction: const <String, String>{
          'extraction': 'homo_1',
        },
      ),
    );

    controller.extractMaterial('m_1', 'full_basic');

    expect(
      session.state.workshop.queue.first.completedExtractedTraits['t_hp'],
      closeTo(0.8925, 0.0001),
    );
  });
}
