import 'dart:math';

import 'package:alchemist_hunter/features/workshop/domain/models.dart';

part 'potion_crafting_inventory_service.dart';
part 'potion_crafting_quality_service.dart';
part 'potion_crafting_recipe_service.dart';

class PotionCraftingService {
  PotionCraftingService({Random? random}) : _random = random ?? Random();

  final Random _random;

  ({
    Map<String, double> nextExtractedInventory,
    Map<String, double> extractedTraits,
  })?
  prepareCraftFromExtractedInventory({
    required PotionBlueprint blueprint,
    required Map<String, double> extractedInventory,
  }) {
    return prepareInventoryCraft(
      blueprint: blueprint,
      extractedInventory: extractedInventory,
    );
  }

  Map<String, double>? requiredTraitsForRepeatCount({
    required PotionBlueprint blueprint,
    required int repeatCount,
  }) {
    return blueprint.targetTraits.map(
      (String key, double value) =>
          MapEntry<String, double>(key, value * repeatCount),
    );
  }

  bool canCraftRepeatCount({
    required PotionBlueprint blueprint,
    required Map<String, double> extractedInventory,
    required int repeatCount,
  }) {
    return canCraft(
      blueprint: blueprint,
      extractedInventory: extractedInventory,
      repeatCount: repeatCount,
    );
  }

  int maxCraftableRepeatCount({
    required PotionBlueprint blueprint,
    required Map<String, double> extractedInventory,
    int cap = 99,
  }) {
    return maxRepeatCount(
      blueprint: blueprint,
      extractedInventory: extractedInventory,
      cap: cap,
    );
  }

  CraftedPotion craftPotion({
    required PotionBlueprint requestedBlueprint,
    required Map<String, double> extractedTraits,
    required List<PotionRecipeRule> recipeRules,
    required PotionQualityRule qualityRule,
  }) {
    final Map<String, double> normalizedTraits = normalizeTraits(
      extractedTraits,
    );
    final String typePotionId =
        resolvePotionType(
          normalizedTraits: normalizedTraits,
          recipeRules: recipeRules,
        ) ??
        requestedBlueprint.id;
    final ({PotionQualityGrade grade, double score}) quality =
        calculateQualityFromTraits(
          targetTraits: requestedBlueprint.targetTraits,
          inputTraits: normalizedTraits,
          qualityRule: qualityRule,
        );
    return CraftedPotion(
      id: 'cp_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}',
      typePotionId: typePotionId,
      qualityGrade: quality.grade,
      qualityScore: quality.score,
      traits: normalizedTraits,
      createdAt: DateTime.now(),
    );
  }

  String? resolvePotionTypeFromTraits({
    required Map<String, double> inputTraits,
    required List<PotionRecipeRule> recipeRules,
  }) {
    return resolvePotionType(
      normalizedTraits: normalizeTraits(inputTraits),
      recipeRules: recipeRules,
    );
  }

  ({PotionQualityGrade grade, double score}) calculateQualityFromTraits({
    required Map<String, double> targetTraits,
    required Map<String, double> inputTraits,
    required PotionQualityRule qualityRule,
  }) {
    return calculateQuality(
      targetTraits: targetTraits,
      inputTraits: inputTraits,
      qualityRule: qualityRule,
    );
  }

  ({
    String? predictedPotionId,
    String hintLabel,
    double stability,
    bool alreadyDiscovered,
  })
  previewBrew({
    required Map<String, double> inputTraits,
    required List<PotionRecipeRule> recipeRules,
    Set<String> discoveredPotionIds = const <String>{},
  }) {
    return previewBrewReaction(
      inputTraits: inputTraits,
      recipeRules: recipeRules,
      discoveredPotionIds: discoveredPotionIds,
    );
  }

  Map<String, double> generateCraftInputTraits(PotionBlueprint blueprint) {
    if (blueprint.targetTraits.isEmpty) {
      return const <String, double>{};
    }

    final Map<String, double> noisy = <String, double>{};
    blueprint.targetTraits.forEach((String key, double value) {
      final double noise = (_random.nextDouble() - 0.5) * 0.4;
      noisy[key] = max(0, value + noise);
    });
    return normalizeTraits(noisy);
  }
}
