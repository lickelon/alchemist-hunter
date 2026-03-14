import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';

class UpgradeTownSkillNodeUseCase {
  const UpgradeTownSkillNodeUseCase();

  SessionState upgradeNode({
    required SessionState state,
    required String nodeId,
    required TownSkillTreeRepository repository,
    required TownSkillTreeService service,
  }) {
    final TownSkillNode? node = repository.findById(nodeId);
    if (node == null) {
      return state;
    }

    final int currentLevel = service.levelOf(state.town.skillTree, nodeId);
    if (currentLevel >= node.maxLevel) {
      return state;
    }
    if (!service.prerequisitesMet(state, node) ||
        !service.requirementsMet(state, node)) {
      return state;
    }

    final List<TownSkillCost> costs = service.costsForNextLevel(
      node,
      currentLevel,
    );
    if (!service.canAfford(state, costs)) {
      return state;
    }

    int nextGold = state.player.gold;
    int nextTownInsight = state.player.townInsight;
    for (final TownSkillCost cost in costs) {
      switch (cost.type) {
        case TownSkillCostType.townInsight:
          nextTownInsight -= cost.amount;
        case TownSkillCostType.gold:
          nextGold -= cost.amount;
      }
    }

    final Map<String, int> nodeLevels = <String, int>{
      ...state.town.skillTree.nodeLevels,
      nodeId: currentLevel + 1,
    };
    final TownSkillTreeState intermediate = state.town.skillTree.copyWith(
      nodeLevels: nodeLevels,
      spentPoints: state.town.skillTree.spentPoints + 1,
    );
    final SessionState intermediateState = state.copyWith(
      player: state.player.copyWith(
        gold: nextGold,
        townInsight: nextTownInsight,
      ),
      town: state.town.copyWith(skillTree: intermediate),
    );

    return intermediateState.copyWith(
      town: intermediateState.town.copyWith(
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
