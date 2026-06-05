import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

String workshopSkillPrerequisiteNames(
  List<String> prerequisiteNodeIds,
  Map<String, WorkshopSkillNode> nodeMap,
) {
  return prerequisiteNodeIds
      .map((String nodeId) => nodeMap[nodeId]?.name ?? nodeId)
      .join(', ');
}

String workshopSkillMissingCostLabel(
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

List<String> workshopSkillCostLabels(
  List<WorkshopSkillCost> costs,
  Map<String, TraitUnit> traitMap,
) {
  if (costs.isEmpty) {
    return const <String>['비용 없음'];
  }
  return costs
      .map((WorkshopSkillCost cost) {
        return switch (cost.type) {
          WorkshopSkillCostType.arcaneDust => '신비 ${cost.amount}',
          WorkshopSkillCostType.element =>
            '${traitMap[cost.elementId]?.name ?? cost.elementId ?? "원소"} 원소 ${cost.amount}',
        };
      })
      .toList(growable: false);
}

List<String> workshopSkillEffectPreviewLabels(
  List<WorkshopSkillEffect> effects,
  int level,
) {
  if (level <= 0) {
    return const <String>['효과 없음'];
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
      .toList(growable: false);
}

int workshopSkillDepthForNode(
  WorkshopSkillNode node,
  List<WorkshopSkillNode> nodes,
) {
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
    final int prerequisiteDepth =
        workshopSkillDepthForNode(prerequisite, nodes) + 1;
    if (prerequisiteDepth > maxDepth) {
      maxDepth = prerequisiteDepth;
    }
  }
  return maxDepth;
}
