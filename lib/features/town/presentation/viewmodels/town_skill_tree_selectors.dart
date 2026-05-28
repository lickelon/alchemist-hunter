import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_view.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';

class TownSkillNodeView {
  const TownSkillNodeView({
    required this.id,
    required this.name,
    required this.description,
    required this.parentIds,
    required this.depth,
    required this.levelLabel,
    required this.costLabel,
    required this.currentEffectLabel,
    required this.nextEffectLabel,
    required this.prerequisiteLabel,
    required this.statusLabel,
    required this.state,
    required this.upgradeable,
  });

  final String id;
  final String name;
  final String description;
  final List<String> parentIds;
  final int depth;
  final String levelLabel;
  final String costLabel;
  final String currentEffectLabel;
  final String nextEffectLabel;
  final String prerequisiteLabel;
  final String statusLabel;
  final SkillTreeNodeState state;
  final bool upgradeable;

  SkillTreeGraphNode toGraphNode() {
    return SkillTreeGraphNode(
      id: id,
      parentIds: parentIds,
      title: name,
      description: description,
      levelLabel: levelLabel,
      costLabel: costLabel,
      currentEffectLabel: currentEffectLabel,
      nextEffectLabel: nextEffectLabel,
      prerequisiteLabel: prerequisiteLabel,
      statusLabel: statusLabel,
      state: state,
    );
  }
}

final Provider<List<TownSkillNodeView>>
townSkillNodeViewsProvider = Provider<List<TownSkillNodeView>>((Ref ref) {
  final SessionState state = ref.watch(sessionControllerProvider);
  final List<TownSkillNode> nodes = ref.watch(townSkillNodesProvider);
  const TownSkillTreeService service = TownSkillTreeService();
  final Map<String, TownSkillNode> nodeMap = <String, TownSkillNode>{
    for (final TownSkillNode node in nodes) node.id: node,
  };

  return nodes
      .map((TownSkillNode node) {
        final int level = service.levelOf(state.town.skillTree, node.id);
        final bool prereqMet = service.prerequisitesMet(state, node);
        final bool reqMet = service.requirementsMet(state, node);
        final List<TownSkillCost> costs = service.costsForNextLevel(
          node,
          level,
        );
        final bool affordable = service.canAfford(state, costs);
        final bool upgradeable =
            level < node.maxLevel && prereqMet && reqMet && affordable;

        final String statusLabel;
        final SkillTreeNodeState nodeState;
        if (level >= node.maxLevel) {
          statusLabel = '최대 레벨';
          nodeState = SkillTreeNodeState.maxed;
        } else if (!prereqMet) {
          statusLabel = '선행 노드 필요';
          nodeState = SkillTreeNodeState.locked;
        } else if (!reqMet) {
          statusLabel = node.requirements.map((e) => e.label).join(', ');
          nodeState = SkillTreeNodeState.locked;
        } else if (!affordable) {
          statusLabel = _missingCostLabel(state, costs);
          nodeState = SkillTreeNodeState.insufficient;
        } else {
          statusLabel = '강화 가능';
          nodeState = SkillTreeNodeState.upgradable;
        }

        return TownSkillNodeView(
          id: node.id,
          name: node.name,
          description: node.description,
          parentIds: node.prerequisiteNodeIds,
          depth: _depthForNode(node, nodes),
          levelLabel: '레벨 $level/${node.maxLevel}',
          costLabel: costs.isEmpty
              ? '비용 없음'
              : costs
                    .map((TownSkillCost cost) {
                      final String label = switch (cost.type) {
                        TownSkillCostType.townInsight => '명성',
                        TownSkillCostType.gold => '골드',
                      };
                      return '$label ${cost.amount}';
                    })
                    .join(' / '),
          currentEffectLabel: _effectPreview(node.effects, level),
          nextEffectLabel: _effectPreview(
            node.effects,
            level < node.maxLevel ? level + 1 : level,
          ),
          prerequisiteLabel: node.prerequisiteNodeIds.isEmpty
              ? '루트 노드'
              : '선행 ${_prerequisiteNames(node.prerequisiteNodeIds, nodeMap)}',
          statusLabel: statusLabel,
          state: nodeState,
          upgradeable: upgradeable,
        );
      })
      .toList(growable: false);
});

String _prerequisiteNames(
  List<String> prerequisiteNodeIds,
  Map<String, TownSkillNode> nodeMap,
) {
  return prerequisiteNodeIds
      .map((String nodeId) => nodeMap[nodeId]?.name ?? nodeId)
      .join(', ');
}

String _missingCostLabel(SessionState state, List<TownSkillCost> costs) {
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

int _depthForNode(TownSkillNode node, List<TownSkillNode> nodes) {
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
    final int prerequisiteDepth = _depthForNode(prerequisite, nodes) + 1;
    if (prerequisiteDepth > maxDepth) {
      maxDepth = prerequisiteDepth;
    }
  }
  return maxDepth;
}

String _effectPreview(List<TownSkillEffect> effects, int level) {
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
