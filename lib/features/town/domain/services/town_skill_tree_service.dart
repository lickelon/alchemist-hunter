import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class TownSkillTreeService {
  const TownSkillTreeService();

  int levelOf(TownSkillTreeState state, String nodeId) {
    return state.nodeLevels[nodeId] ?? 0;
  }

  List<TownSkillCost> costsForNextLevel(TownSkillNode node, int currentLevel) {
    if (currentLevel >= node.maxLevel) {
      return const <TownSkillCost>[];
    }
    return node.costsByLevel[currentLevel];
  }

  bool requirementsMet(SessionState state, TownSkillNode node) {
    for (final TownSkillRequirement requirement in node.requirements) {
      final int progress = switch (requirement.type) {
        TownSkillRequirementType.salesTotal => state.town.potionSalesTotal,
        TownSkillRequirementType.mercenaryCount =>
          state.characters.mercenaries.length,
        TownSkillRequirementType.equipmentCraftCount =>
          state.town.equipmentCraftCount,
      };
      if (progress < requirement.threshold) {
        return false;
      }
    }
    return true;
  }

  bool prerequisitesMet(SessionState state, TownSkillNode node) {
    for (final String nodeId in node.prerequisiteNodeIds) {
      if (levelOf(state.town.skillTree, nodeId) <= 0) {
        return false;
      }
    }
    return true;
  }

  bool canAfford(SessionState state, List<TownSkillCost> costs) {
    for (final TownSkillCost cost in costs) {
      final int owned = switch (cost.type) {
        TownSkillCostType.townInsight => state.player.townInsight,
        TownSkillCostType.gold => state.player.gold,
      };
      if (owned < cost.amount) {
        return false;
      }
    }
    return true;
  }

  Set<String> resolveUnlockedNodes(
    SessionState state,
    List<TownSkillNode> nodes,
  ) {
    final Set<String> unlocked = <String>{...state.town.skillTree.unlockedNodes};
    for (final TownSkillNode node in nodes) {
      if (levelOf(state.town.skillTree, node.id) > 0 ||
          (prerequisitesMet(state, node) && requirementsMet(state, node))) {
        unlocked.add(node.id);
      }
    }
    return unlocked;
  }
}
