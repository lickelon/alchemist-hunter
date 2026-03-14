import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';

class UpgradeWorkshopSkillNodeUseCase {
  const UpgradeWorkshopSkillNodeUseCase();

  SessionState upgradeNode({
    required SessionState state,
    required String nodeId,
    required WorkshopSkillTreeRepository repository,
    required WorkshopSkillTreeService service,
  }) {
    final WorkshopSkillNode? node = repository.findById(nodeId);
    if (node == null) {
      return state;
    }

    final int currentLevel = service.levelOf(state.workshop.skillTree, nodeId);
    if (currentLevel >= node.maxLevel) {
      return state;
    }
    if (!service.prerequisitesMet(state, node) ||
        !service.requirementsMet(state, node)) {
      return state;
    }

    final List<WorkshopSkillCost> costs = service.costsForNextLevel(
      node,
      currentLevel,
    );
    if (!service.canAfford(state, costs)) {
      return state;
    }

    int nextArcaneDust = state.player.arcaneDust;
    final Map<String, double> nextTraits = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    for (final WorkshopSkillCost cost in costs) {
      switch (cost.type) {
        case WorkshopSkillCostType.arcaneDust:
          nextArcaneDust -= cost.amount;
        case WorkshopSkillCostType.element:
          final String? elementId = cost.elementId;
          if (elementId == null) {
            return state;
          }
          final double nextAmount = (nextTraits[elementId] ?? 0) - cost.amount;
          if (nextAmount <= 0) {
            nextTraits.remove(elementId);
          } else {
            nextTraits[elementId] = nextAmount;
          }
      }
    }

    final Map<String, int> nodeLevels = <String, int>{
      ...state.workshop.skillTree.nodeLevels,
      nodeId: currentLevel + 1,
    };
    final WorkshopSkillTreeState intermediate = state.workshop.skillTree
        .copyWith(
          nodeLevels: nodeLevels,
          spentPoints: state.workshop.skillTree.spentPoints + 1,
        );
    final SessionState intermediateState = state.copyWith(
      player: state.player.copyWith(arcaneDust: nextArcaneDust),
      workshop: state.workshop.copyWith(
        extractedTraitInventory: nextTraits,
        skillTree: intermediate,
      ),
    );

    return intermediateState.copyWith(
      workshop: intermediateState.workshop.copyWith(
        skillTree: intermediate.copyWith(
          unlockedNodes: service.resolveUnlockedNodes(
            intermediateState,
            repository.nodes(),
          ),
        ),
      ),
    );
  }
}
