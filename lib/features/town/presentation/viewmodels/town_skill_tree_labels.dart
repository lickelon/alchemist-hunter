import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

String townSkillPrerequisiteNames(
  List<String> prerequisiteNodeIds,
  Map<String, TownSkillNode> nodeMap,
) {
  return prerequisiteNodeIds
      .map((String nodeId) => nodeMap[nodeId]?.name ?? nodeId)
      .join(', ');
}

String townSkillMissingCostLabel(
  SessionState state,
  List<TownSkillCost> costs,
) {
  for (final TownSkillCost cost in costs) {
    if (cost.type == TownSkillCostType.townInsight &&
        state.player.townInsight < cost.amount) {
      return '명성 부족';
    }
    if (cost.type == TownSkillCostType.gold &&
        state.player.gold < cost.amount) {
      return '골드 부족';
    }
  }
  return '비용 부족';
}

String townSkillCostLabel(List<TownSkillCost> costs) {
  if (costs.isEmpty) {
    return '비용 없음';
  }
  return costs
      .map((TownSkillCost cost) {
        final String label = switch (cost.type) {
          TownSkillCostType.townInsight => '명성',
          TownSkillCostType.gold => '골드',
        };
        return '$label ${cost.amount}';
      })
      .join(' / ');
}

String townSkillEffectPreview(List<TownSkillEffect> effects, int level) {
  if (level <= 0) {
    return '효과 없음';
  }
  return effects
      .map((TownSkillEffect effect) {
        final double amount = effect.value * level;
        final String valueLabel = switch (effect.modifierType) {
          TownSkillModifierType.percent => '${(amount * 100).round()}%',
          TownSkillModifierType.flat => amount.round().toString(),
        };
        final String typeLabel = switch (effect.type) {
          TownSkillEffectType.shopRefreshDiscount => '강제 갱신 비용',
          TownSkillEffectType.potionSaleBonus => '포션 판매가',
          TownSkillEffectType.equipmentCraftEfficiency => '장비 제작 효율',
          TownSkillEffectType.mercenaryHireDiscount => '용병 고용 비용',
        };
        final String sign =
            effect.modifierType == TownSkillModifierType.percent &&
                    effect.type == TownSkillEffectType.shopRefreshDiscount ||
                effect.type == TownSkillEffectType.mercenaryHireDiscount
            ? '-'
            : '+';
        return '$typeLabel $sign$valueLabel';
      })
      .join(' / ');
}

int townSkillDepthForNode(TownSkillNode node, List<TownSkillNode> nodes) {
  if (node.prerequisiteNodeIds.isEmpty) {
    return 0;
  }
  final Map<String, TownSkillNode> nodeMap = <String, TownSkillNode>{
    for (final TownSkillNode item in nodes) item.id: item,
  };
  int maxDepth = 0;
  for (final String prerequisiteId in node.prerequisiteNodeIds) {
    final TownSkillNode? prerequisite = nodeMap[prerequisiteId];
    if (prerequisite == null) {
      continue;
    }
    final int prerequisiteDepth =
        townSkillDepthForNode(prerequisite, nodes) + 1;
    if (prerequisiteDepth > maxDepth) {
      maxDepth = prerequisiteDepth;
    }
  }
  return maxDepth;
}
