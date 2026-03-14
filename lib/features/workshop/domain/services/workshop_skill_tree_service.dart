import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class WorkshopSkillTreeService {
  const WorkshopSkillTreeService();

  int levelOf(WorkshopSkillTreeState state, String nodeId) {
    return state.nodeLevels[nodeId] ?? 0;
  }

  List<WorkshopSkillCost> costsForNextLevel(
    WorkshopSkillNode node,
    int currentLevel,
  ) {
    if (currentLevel >= node.maxLevel) {
      return const <WorkshopSkillCost>[];
    }
    return node.costsByLevel[currentLevel];
  }

  bool requirementsMet(SessionState state, WorkshopSkillNode node) {
    for (final WorkshopSkillRequirement requirement in node.requirements) {
      final int progress = switch (requirement.type) {
        WorkshopSkillRequirementType.extractionCount =>
          state.workshop.extractionCount,
        WorkshopSkillRequirementType.potionCraftCount =>
          state.workshop.potionCraftCount,
        WorkshopSkillRequirementType.enchantCount => state.workshop.enchantCount,
      };
      if (progress < requirement.threshold) {
        return false;
      }
    }
    return true;
  }

  bool prerequisitesMet(SessionState state, WorkshopSkillNode node) {
    for (final String nodeId in node.prerequisiteNodeIds) {
      if (levelOf(state.workshop.skillTree, nodeId) <= 0) {
        return false;
      }
    }
    return true;
  }

  bool canAfford(SessionState state, List<WorkshopSkillCost> costs) {
    for (final WorkshopSkillCost cost in costs) {
      final double owned = switch (cost.type) {
        WorkshopSkillCostType.arcaneDust => state.player.arcaneDust.toDouble(),
        WorkshopSkillCostType.element =>
          state.workshop.extractedTraitInventory[cost.elementId] ?? 0,
      };
      if (owned < cost.amount) {
        return false;
      }
    }
    return true;
  }

  Set<String> resolveUnlockedNodes(
    SessionState state,
    List<WorkshopSkillNode> nodes,
  ) {
    final Set<String> unlocked = <String>{
      ...state.workshop.skillTree.unlockedNodes,
    };
    for (final WorkshopSkillNode node in nodes) {
      if (levelOf(state.workshop.skillTree, node.id) > 0 ||
          (prerequisitesMet(state, node) && requirementsMet(state, node))) {
        unlocked.add(node.id);
      }
    }
    return unlocked;
  }
}
