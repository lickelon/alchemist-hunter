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
    required this.depth,
    required this.levelLabel,
    required this.costLabel,
    required this.currentEffectLabel,
    required this.nextEffectLabel,
    required this.prerequisiteLabel,
    required this.statusLabel,
    required this.upgradeable,
  });

  final String id;
  final String name;
  final String description;
  final int depth;
  final String levelLabel;
  final String costLabel;
  final String currentEffectLabel;
  final String nextEffectLabel;
  final String prerequisiteLabel;
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
          depth: _depthForNode(node, nodes),
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
          currentEffectLabel: _effectPreview(node.effects, level),
          nextEffectLabel: _effectPreview(
            node.effects,
            level < node.maxLevel ? level + 1 : level,
          ),
          prerequisiteLabel: node.prerequisiteNodeIds.isEmpty
              ? '루트 노드'
              : '선행 ${node.prerequisiteNodeIds.join(", ")}',
          statusLabel: statusLabel,
          upgradeable: upgradeable,
        );
      }).toList(growable: false);
    });

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
  return effects.map((WorkshopSkillEffect effect) {
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
  }).join(' / ');
}
