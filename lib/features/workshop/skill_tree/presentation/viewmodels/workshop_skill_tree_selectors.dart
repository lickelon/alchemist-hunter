import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_view.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/presentation/viewmodels/workshop_skill_tree_labels.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';

class WorkshopSkillNodeView {
  const WorkshopSkillNodeView({
    required this.id,
    required this.name,
    required this.description,
    required this.parentIds,
    required this.depth,
    required this.levelLabel,
    required this.costLabels,
    required this.currentEffectLabels,
    required this.nextEffectLabels,
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
  final List<String> costLabels;
  final List<String> currentEffectLabels;
  final List<String> nextEffectLabels;
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
      costLabels: costLabels,
      currentEffectLabels: currentEffectLabels,
      nextEffectLabels: nextEffectLabels,
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
          statusLabel = workshopSkillMissingCostLabel(state, costs, traitMap);
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
          depth: workshopSkillDepthForNode(node, nodes),
          levelLabel: '레벨 $level/${node.maxLevel}',
          costLabels: workshopSkillCostLabels(costs, traitMap),
          currentEffectLabels: workshopSkillEffectPreviewLabels(
            node.effects,
            level,
          ),
          nextEffectLabels: workshopSkillEffectPreviewLabels(
            node.effects,
            level < node.maxLevel ? level + 1 : level,
          ),
          prerequisiteLabel: node.prerequisiteNodeIds.isEmpty
              ? '루트 노드'
              : '선행 ${workshopSkillPrerequisiteNames(node.prerequisiteNodeIds, nodeMap)}',
          statusLabel: statusLabel,
          state: nodeState,
          upgradeable: upgradeable,
        );
      })
      .toList(growable: false);
});
