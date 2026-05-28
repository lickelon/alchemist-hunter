import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_view.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';

class WorkshopSkillNodeView {
  const WorkshopSkillNodeView({
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

final Provider<List<WorkshopSkillNodeView>>
workshopSkillNodeViewsProvider = Provider<List<WorkshopSkillNodeView>>((
  Ref ref,
) {
  final SessionState state = ref.watch(sessionControllerProvider);
  final List<WorkshopSkillNode> nodes = ref.watch(workshopSkillNodesProvider);
  final Map<String, WorkshopSkillNode> nodeMap = <String, WorkshopSkillNode>{
    for (final WorkshopSkillNode node in nodes) node.id: node,
  };
  final Map<String, TraitUnit> traitMap = <String, TraitUnit>{
    for (final TraitUnit trait in ref.watch(traitsProvider)) trait.id: trait,
  };
  const WorkshopSkillTreeService service = WorkshopSkillTreeService();

  return nodes
      .map((WorkshopSkillNode node) {
        final int level = service.levelOf(state.workshop.skillTree, node.id);
        final bool prereqMet = service.prerequisitesMet(state, node);
        final bool reqMet = service.requirementsMet(state, node);
        final List<WorkshopSkillCost> costs = service.costsForNextLevel(
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
          statusLabel = _missingCostLabel(state, costs, traitMap);
          nodeState = SkillTreeNodeState.insufficient;
        } else {
          statusLabel = '강화 가능';
          nodeState = SkillTreeNodeState.upgradable;
        }

        return WorkshopSkillNodeView(
          id: node.id,
          name: node.name,
          description: node.description,
          parentIds: node.prerequisiteNodeIds,
          depth: _depthForNode(node, nodes),
          levelLabel: '레벨 $level/${node.maxLevel}',
          costLabel: costs.isEmpty
              ? '비용 없음'
              : costs
                    .map((WorkshopSkillCost cost) {
                      return switch (cost.type) {
                        WorkshopSkillCostType.arcaneDust => '신비 ${cost.amount}',
                        WorkshopSkillCostType.element =>
                          '${traitMap[cost.elementId]?.name ?? cost.elementId ?? "원소"} 원소 ${cost.amount}',
                      };
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
  Map<String, WorkshopSkillNode> nodeMap,
) {
  return prerequisiteNodeIds
      .map((String nodeId) => nodeMap[nodeId]?.name ?? nodeId)
      .join(', ');
}

String _missingCostLabel(
  SessionState state,
  List<WorkshopSkillCost> costs,
  Map<String, TraitUnit> traitMap,
) {
  for (final WorkshopSkillCost cost in costs) {
    if (cost.type == WorkshopSkillCostType.arcaneDust &&
        state.player.arcaneDust < cost.amount) {
      return '신비 부족';
    }
    if (cost.type == WorkshopSkillCostType.element) {
      final String? elementId = cost.elementId;
      if (elementId == null) {
        return '원소 부족';
      }
      if ((state.workshop.extractedTraitInventory[elementId] ?? 0) <
          cost.amount) {
        return '${traitMap[elementId]?.name ?? elementId} 원소 부족';
      }
    }
  }
  return '비용 부족';
}

int _depthForNode(WorkshopSkillNode node, List<WorkshopSkillNode> nodes) {
  if (node.prerequisiteNodeIds.isEmpty) {
    return 0;
  }
  final Map<String, WorkshopSkillNode> nodeMap = <String, WorkshopSkillNode>{
    for (final WorkshopSkillNode item in nodes) item.id: item,
  };
  int maxDepth = 0;
  for (final String prerequisiteId in node.prerequisiteNodeIds) {
    final WorkshopSkillNode? prerequisite = nodeMap[prerequisiteId];
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

String _effectPreview(List<WorkshopSkillEffect> effects, int level) {
  if (level <= 0) {
    return '효과 없음';
  }
  return effects
      .map((WorkshopSkillEffect effect) {
        final double amount = effect.value * level;
        final String valueLabel = switch (effect.modifierType) {
          WorkshopSkillModifierType.percent => '${(amount * 100).round()}%',
          WorkshopSkillModifierType.flat => amount.round().toString(),
        };
        final String typeLabel = switch (effect.type) {
          WorkshopSkillEffectType.extractionYield => '추출 수율',
          WorkshopSkillEffectType.craftQueueCapacity => '제작 큐 용량',
          WorkshopSkillEffectType.enchantPotency => '인챈트 강화량',
          WorkshopSkillEffectType.hatchAcceleration => '부화 속도',
        };
        return '$typeLabel +$valueLabel';
      })
      .join(' / ');
}
