import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';

class WorkshopSkillNodeView {
  const WorkshopSkillNodeView({
    required this.id,
    required this.name,
    required this.description,
    required this.levelLabel,
    required this.costLabel,
    required this.effectLabel,
    required this.statusLabel,
    required this.upgradeable,
  });

  final String id;
  final String name;
  final String description;
  final String levelLabel;
  final String costLabel;
  final String effectLabel;
  final String statusLabel;
  final bool upgradeable;
}

final Provider<List<WorkshopSkillNodeView>> workshopSkillNodeViewsProvider =
    Provider<List<WorkshopSkillNodeView>>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final List<WorkshopSkillNode> nodes = ref.watch(workshopSkillNodesProvider);
      const WorkshopSkillTreeService service = WorkshopSkillTreeService();

      return nodes.map((WorkshopSkillNode node) {
        final int level = service.levelOf(state.workshop.skillTree, node.id);
        final bool prereqMet = service.prerequisitesMet(state, node);
        final bool reqMet = service.requirementsMet(state, node);
        final List<WorkshopSkillCost> costs = service.costsForNextLevel(node, level);
        final bool affordable = service.canAfford(state, costs);
        final bool upgradeable =
            level < node.maxLevel && prereqMet && reqMet && affordable;

        final String statusLabel;
        if (level >= node.maxLevel) {
          statusLabel = '최대 레벨';
        } else if (!prereqMet) {
          statusLabel = '선행 노드 필요';
        } else if (!reqMet) {
          statusLabel = node.requirements.map((e) => e.label).join(', ');
        } else if (!affordable) {
          statusLabel = '재화 부족';
        } else {
          statusLabel = '강화 가능';
        }

        return WorkshopSkillNodeView(
          id: node.id,
          name: node.name,
          description: node.description,
          levelLabel: 'Lv $level/${node.maxLevel}',
          costLabel: costs.isEmpty
              ? '비용 없음'
              : costs.map((WorkshopSkillCost cost) {
                  return switch (cost.type) {
                    WorkshopSkillCostType.arcaneDust =>
                      'ArcaneDust ${cost.amount}',
                    WorkshopSkillCostType.element =>
                      '${cost.elementId ?? "Element"} ${cost.amount}',
                  };
                }).join(' / '),
          effectLabel: node.effects
              .map((WorkshopSkillEffect e) => e.label)
              .join(', '),
          statusLabel: statusLabel,
          upgradeable: upgradeable,
        );
      }).toList(growable: false);
    });
