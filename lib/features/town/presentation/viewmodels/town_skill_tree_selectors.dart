import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_view.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_skill_tree_labels.dart';
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
          statusLabel = townSkillMissingCostLabel(state, costs);
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
          depth: townSkillDepthForNode(node, nodes),
          levelLabel: '레벨 $level/${node.maxLevel}',
          costLabel: townSkillCostLabel(costs),
          currentEffectLabel: townSkillEffectPreview(node.effects, level),
          nextEffectLabel: townSkillEffectPreview(
            node.effects,
            level < node.maxLevel ? level + 1 : level,
          ),
          prerequisiteLabel: node.prerequisiteNodeIds.isEmpty
              ? '루트 노드'
              : '선행 ${townSkillPrerequisiteNames(node.prerequisiteNodeIds, nodeMap)}',
          statusLabel: statusLabel,
          state: nodeState,
          upgradeable: upgradeable,
        );
      })
      .toList(growable: false);
});
