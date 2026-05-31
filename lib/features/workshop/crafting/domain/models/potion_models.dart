import 'package:flutter/foundation.dart';

import 'package:alchemist_hunter/features/workshop/domain/models/enums.dart';

@immutable
class PotionBlueprint {
  const PotionBlueprint({
    required this.id,
    required this.name,
    required this.targetTraits,
    required this.baseValue,
    required this.useType,
  });

  final String id;
  final String name;
  final Map<String, double> targetTraits;
  final int baseValue;
  final PotionUseType useType;
}

@immutable
class PotionRecipeRule {
  const PotionRecipeRule({
    required this.id,
    required this.mainTraitId,
    required this.subTraitId,
    required this.mainPercent,
    required this.subPercent,
    required this.resultPotionId,
  });

  final String id;
  final String mainTraitId;
  final String subTraitId;
  final int mainPercent;
  final int subPercent;
  final String resultPotionId;

  Set<String> get requiredTraits => <String>{mainTraitId, subTraitId};

  Map<String, double> get targetTraits => <String, double>{
    mainTraitId: mainPercent / 100,
    subTraitId: subPercent / 100,
  };
}

@immutable
class PotionQualityRule {
  const PotionQualityRule({required this.gradeThresholds});

  final Map<PotionQualityGrade, double> gradeThresholds;
}

@immutable
class CraftedPotion {
  const CraftedPotion({
    required this.id,
    required this.typePotionId,
    required this.qualityGrade,
    required this.qualityScore,
    required this.traits,
    required this.createdAt,
  });

  final String id;
  final String typePotionId;
  final PotionQualityGrade qualityGrade;
  final double qualityScore;
  final Map<String, double> traits;
  final DateTime createdAt;
}

@immutable
class DiscoveredPotionRecipe {
  const DiscoveredPotionRecipe({
    required this.potionId,
    required this.discoveredTraits,
    required this.bestKnownGrade,
  });

  final String potionId;
  final Map<String, double> discoveredTraits;
  final PotionQualityGrade bestKnownGrade;
}
