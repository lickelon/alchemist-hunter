import 'package:flutter/foundation.dart';

enum TownSkillCostType { townInsight, gold }

enum TownSkillRequirementType { salesTotal, mercenaryCount, equipmentCraftCount }

enum TownSkillEffectType {
  shopRefreshDiscount,
  potionSaleBonus,
  equipmentCraftEfficiency,
  mercenaryHireDiscount,
}

enum TownSkillModifierType { flat, percent }

@immutable
class TownSkillCost {
  const TownSkillCost({required this.type, required this.amount});

  final TownSkillCostType type;
  final int amount;
}

@immutable
class TownSkillRequirement {
  const TownSkillRequirement({
    required this.type,
    required this.threshold,
    required this.label,
  });

  final TownSkillRequirementType type;
  final int threshold;
  final String label;
}

@immutable
class TownSkillEffect {
  const TownSkillEffect({
    required this.type,
    required this.modifierType,
    required this.value,
    required this.label,
  });

  final TownSkillEffectType type;
  final TownSkillModifierType modifierType;
  final double value;
  final String label;
}

@immutable
class TownSkillNode {
  const TownSkillNode({
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
  final List<List<TownSkillCost>> costsByLevel;
  final List<String> prerequisiteNodeIds;
  final List<TownSkillRequirement> requirements;
  final List<TownSkillEffect> effects;
}

@immutable
class TownSkillTreeState {
  const TownSkillTreeState({
    required this.unlockedNodes,
    required this.nodeLevels,
    required this.availablePoints,
    required this.spentPoints,
  });

  final Set<String> unlockedNodes;
  final Map<String, int> nodeLevels;
  final int availablePoints;
  final int spentPoints;

  TownSkillTreeState copyWith({
    Set<String>? unlockedNodes,
    Map<String, int>? nodeLevels,
    int? availablePoints,
    int? spentPoints,
  }) {
    return TownSkillTreeState(
      unlockedNodes: unlockedNodes ?? this.unlockedNodes,
      nodeLevels: nodeLevels ?? this.nodeLevels,
      availablePoints: availablePoints ?? this.availablePoints,
      spentPoints: spentPoints ?? this.spentPoints,
    );
  }
}
