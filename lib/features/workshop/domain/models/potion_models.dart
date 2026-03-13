import 'package:flutter/foundation.dart';

import 'enums.dart';

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
    required this.requiredTraits,
    required this.resultPotionId,
    this.optionalTraits = const <String>{},
    this.forbiddenTraits = const <String>{},
  });

  final String id;
  final Set<String> requiredTraits;
  final Set<String> optionalTraits;
  final Set<String> forbiddenTraits;
  final String resultPotionId;
}

@immutable
class PotionRecipeBranchRule {
  const PotionRecipeBranchRule({
    required this.recipeId,
    required this.dominantTrait,
    required this.ratioGapMin,
    required this.branchedPotionId,
  });

  final String recipeId;
  final String dominantTrait;
  final double ratioGapMin;
  final String branchedPotionId;
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
