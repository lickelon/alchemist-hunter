import 'package:flutter/foundation.dart';

enum WorkshopSkillCostType { arcaneDust, element }

enum WorkshopSkillRequirementType {
  extractionCount,
  potionCraftCount,
  enchantCount,
}

enum WorkshopSkillEffectType {
  extractionYield,
  craftQueueCapacity,
  enchantPotency,
  hatchAcceleration,
}

enum WorkshopSkillModifierType { flat, percent }

@immutable
class WorkshopSkillCost {
  const WorkshopSkillCost({
    required this.type,
    required this.amount,
    this.elementId,
  });

  final WorkshopSkillCostType type;
  final int amount;
  final String? elementId;
}

@immutable
class WorkshopSkillRequirement {
  const WorkshopSkillRequirement({
    required this.type,
    required this.threshold,
    required this.label,
  });

  final WorkshopSkillRequirementType type;
  final int threshold;
  final String label;
}

@immutable
class WorkshopSkillEffect {
  const WorkshopSkillEffect({
    required this.type,
    required this.modifierType,
    required this.value,
    required this.label,
  });

  final WorkshopSkillEffectType type;
  final WorkshopSkillModifierType modifierType;
  final double value;
  final String label;
}

@immutable
class WorkshopSkillNode {
  const WorkshopSkillNode({
    required this.id,
    required this.name,
    required this.description,
    required this.maxLevel,
    required this.costsByLevel,
    required this.prerequisiteNodeIds,
    required this.requirements,
    required this.effects,
  });

  final String id;
  final String name;
  final String description;
  final int maxLevel;
  final List<List<WorkshopSkillCost>> costsByLevel;
  final List<String> prerequisiteNodeIds;
  final List<WorkshopSkillRequirement> requirements;
  final List<WorkshopSkillEffect> effects;
}

@immutable
class WorkshopSkillTreeState {
  const WorkshopSkillTreeState({
    required this.unlockedNodes,
    required this.nodeLevels,
    required this.availablePoints,
    required this.spentPoints,
  });

  final Set<String> unlockedNodes;
  final Map<String, int> nodeLevels;
  final int availablePoints;
  final int spentPoints;

  WorkshopSkillTreeState copyWith({
    Set<String>? unlockedNodes,
    Map<String, int>? nodeLevels,
    int? availablePoints,
    int? spentPoints,
  }) {
    return WorkshopSkillTreeState(
      unlockedNodes: unlockedNodes ?? this.unlockedNodes,
      nodeLevels: nodeLevels ?? this.nodeLevels,
      availablePoints: availablePoints ?? this.availablePoints,
      spentPoints: spentPoints ?? this.spentPoints,
    );
  }
}
