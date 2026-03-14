import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'dart:math';

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
    return _percentModifierTotal(
      state,
      nodes,
      TownSkillEffectType.shopRefreshDiscount,
    );
  }

  double potionSaleBonusRate(SessionState state, List<TownSkillNode> nodes) {
    return _percentModifierTotal(
      state,
      nodes,
      TownSkillEffectType.potionSaleBonus,
    );
  }

  double equipmentCraftEfficiencyRate(
    SessionState state,
    List<TownSkillNode> nodes,
  ) {
    return _percentModifierTotal(
      state,
      nodes,
      TownSkillEffectType.equipmentCraftEfficiency,
    );
  }

  double mercenaryHireDiscountRate(
    SessionState state,
    List<TownSkillNode> nodes,
  ) {
    return _percentModifierTotal(
      state,
      nodes,
      TownSkillEffectType.mercenaryHireDiscount,
    );
  }

  int discountedGoldCost({
    required int baseCost,
    required double discountRate,
  }) {
    if (baseCost <= 0 || discountRate <= 0) {
      return baseCost;
    }
    return max(0, (baseCost * (1 - discountRate)).round());
  }

  Map<String, int> adjustedMaterialCosts({
    required Map<String, int> baseCosts,
    required double efficiencyRate,
  }) {
    if (efficiencyRate <= 0 || baseCosts.isEmpty) {
      return <String, int>{...baseCosts};
    }

    final Map<String, int> adjusted = <String, int>{...baseCosts};
    final int totalCost = adjusted.values.fold<int>(
      0,
      (int sum, int value) => sum + value,
    );
    final int minimumTotal = adjusted.length;
    final int maxReducible = totalCost - minimumTotal;
    if (maxReducible <= 0) {
      return adjusted;
    }

    int remainingReduction = min(
      maxReducible,
      max(1, (totalCost * efficiencyRate).round()),
    );

    while (remainingReduction > 0) {
      final List<MapEntry<String, int>> entries = adjusted.entries.toList()
        ..sort(
          (MapEntry<String, int> left, MapEntry<String, int> right) =>
              right.value.compareTo(left.value),
        );

      bool changed = false;
      for (final MapEntry<String, int> entry in entries) {
        if (entry.value <= 1) {
          continue;
        }
        adjusted[entry.key] = entry.value - 1;
        remainingReduction -= 1;
        changed = true;
        if (remainingReduction <= 0) {
          break;
        }
      }
      if (!changed) {
        break;
      }
    }

    return adjusted;
  }

  double _percentModifierTotal(
    SessionState state,
    List<TownSkillNode> nodes,
    TownSkillEffectType effectType,
  ) {
    double total = 0;
    for (final TownSkillNode node in nodes) {
      final int level = levelOf(state.town.skillTree, node.id);
      if (level <= 0) {
        continue;
      }
      for (final TownSkillEffect effect in node.effects) {
        if (effect.type != effectType ||
            effect.modifierType != TownSkillModifierType.percent) {
          continue;
        }
        total += effect.value * level;
      }
    }
    return total;
  }
}
