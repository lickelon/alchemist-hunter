import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/session_factory.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/upgrade_workshop_skill_node_use_case.dart';

void main() {
  test('upgrade workshop root node consumes arcane dust and increases level', () {
    final useCase = UpgradeWorkshopSkillNodeUseCase();
    final state = createInitialSessionState(DateTime(2026, 1, 1, 10));

    final nextState = useCase.upgradeNode(
      state: state,
      nodeId: 'workshop_alembic',
      repository: const StaticWorkshopSkillTreeRepository(),
      service: const WorkshopSkillTreeService(),
    );

    expect(nextState.player.arcaneDust, 1);
    expect(nextState.workshop.skillTree.nodeLevels['workshop_alembic'], 1);
    expect(nextState.workshop.skillTree.spentPoints, 1);
  });

  test('upgrade workshop node consumes element cost on next level', () {
    final initial = createInitialSessionState(DateTime(2026, 1, 1, 10));
    final useCase = UpgradeWorkshopSkillNodeUseCase();
    final state = initial.copyWith(
      player: initial.player.copyWith(arcaneDust: 5),
      workshop: initial.workshop.copyWith(
        extractedTraitInventory: const <String, double>{'t_hp': 2},
        potionCraftCount: 5,
        skillTree: initial.workshop.skillTree.copyWith(
          nodeLevels: const <String, int>{'workshop_alembic': 1},
          unlockedNodes: const <String>{
            'workshop_alembic',
            'workshop_queue_matrix',
          },
        ),
      ),
    );

    final nextState = useCase.upgradeNode(
      state: state,
      nodeId: 'workshop_alembic',
      repository: const StaticWorkshopSkillTreeRepository(),
      service: const WorkshopSkillTreeService(),
    );

    expect(nextState.player.arcaneDust, 3);
    expect(nextState.workshop.extractedTraitInventory['t_hp'], 1);
    expect(nextState.workshop.skillTree.nodeLevels['workshop_alembic'], 2);
  });
}
