import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'dart:math';

part 'town_skill_tree_cost_service.dart';
part 'town_skill_tree_effect_service.dart';

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
    final Set<String> unlocked = <String>{
      ...state.town.skillTree.unlockedNodes,
    };
    for (final TownSkillNode node in nodes) {
      if (levelOf(state.town.skillTree, node.id) > 0 ||
          (prerequisitesMet(state, node) && requirementsMet(state, node))) {
        unlocked.add(node.id);
      }
    }
    return unlocked;
  }

  double shopRefreshDiscountRate(
    SessionState state,
    List<TownSkillNode> nodes,
  ) {
    return townSkillPercentModifierTotal(
      service: this,
      state: state,
      nodes: nodes,
      effectType: TownSkillEffectType.shopRefreshDiscount,
    );
  }

  double potionSaleBonusRate(SessionState state, List<TownSkillNode> nodes) {
    return townSkillPercentModifierTotal(
      service: this,
      state: state,
      nodes: nodes,
      effectType: TownSkillEffectType.potionSaleBonus,
    );
  }

  double equipmentCraftEfficiencyRate(
    SessionState state,
    List<TownSkillNode> nodes,
  ) {
    return townSkillPercentModifierTotal(
      service: this,
      state: state,
      nodes: nodes,
      effectType: TownSkillEffectType.equipmentCraftEfficiency,
    );
  }

  double mercenaryHireDiscountRate(
    SessionState state,
    List<TownSkillNode> nodes,
  ) {
    return townSkillPercentModifierTotal(
      service: this,
      state: state,
      nodes: nodes,
      effectType: TownSkillEffectType.mercenaryHireDiscount,
    );
  }

  int discountedGoldCost({
    required int baseCost,
    required double discountRate,
  }) {
    return townSkillDiscountedGoldCost(
      baseCost: baseCost,
      discountRate: discountRate,
    );
  }

  Map<String, int> adjustedMaterialCosts({
    required Map<String, int> baseCosts,
    required double efficiencyRate,
  }) {
    return townSkillAdjustedMaterialCosts(
      baseCosts: baseCosts,
      efficiencyRate: efficiencyRate,
    );
  }
}
