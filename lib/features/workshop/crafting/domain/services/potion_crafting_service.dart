import 'dart:math';

import 'package:alchemist_hunter/features/workshop/domain/models.dart';

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
    if (!_canCraftOnce(blueprint, extractedInventory)) {
      return null;
    }

    final Map<String, double> nextInventory = <String, double>{
      ...extractedInventory,
    };
    final Map<String, double> extractedTraits = <String, double>{
      ...blueprint.targetTraits,
    };
    blueprint.targetTraits.forEach((String traitId, double cost) {
      final double remaining = (nextInventory[traitId] ?? 0) - cost;
      if (remaining <= 0.0001) {
        nextInventory.remove(traitId);
      } else {
        nextInventory[traitId] = remaining;
      }
    });

    return (
      nextExtractedInventory: nextInventory,
      extractedTraits: extractedTraits,
    );
  }

  Map<String, double>? requiredTraitsForRepeatCount({
    required PotionBlueprint blueprint,
    required int repeatCount,
  }) {
    final Map<String, double> required = blueprint.targetTraits.map(
      (String key, double value) =>
          MapEntry<String, double>(key, value * repeatCount),
    );
    return required;
  }

  bool canCraftRepeatCount({
    required PotionBlueprint blueprint,
    required Map<String, double> extractedInventory,
    required int repeatCount,
  }) {
    return _canCraft(blueprint, extractedInventory, repeatCount);
  }

  int maxCraftableRepeatCount({
    required PotionBlueprint blueprint,
    required Map<String, double> extractedInventory,
    int cap = 99,
  }) {
    if (blueprint.targetTraits.isEmpty) {
      return 0;
    }
    final List<int> counts = blueprint.targetTraits.entries
        .map(
          (MapEntry<String, double> entry) =>
              ((extractedInventory[entry.key] ?? 0) / entry.value).floor(),
        )
        .toList();
    if (counts.isEmpty) {
      return 0;
    }
    return counts.reduce(min).clamp(0, cap);
  }

  CraftedPotion craftPotion({
    required PotionBlueprint requestedBlueprint,
    required Map<String, double> extractedTraits,
    required List<PotionRecipeRule> recipeRules,
    required List<PotionRecipeBranchRule> branchRules,
    required PotionQualityRule qualityRule,
  }) {
    final Map<String, double> normalizedTraits = _normalizeTraits(
      extractedTraits,
    );
    final String typePotionId = _resolvePotionType(
      requestedBlueprint: requestedBlueprint,
      normalizedTraits: normalizedTraits,
      recipeRules: recipeRules,
      branchRules: branchRules,
    );
    final double score = _calculateQualityScore(
      targetTraits: requestedBlueprint.targetTraits,
      actualTraits: normalizedTraits,
    );
    final PotionQualityGrade grade = _resolveGrade(score, qualityRule);
    return CraftedPotion(
      id: 'cp_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}',
      typePotionId: typePotionId,
      qualityGrade: grade,
      qualityScore: score,
      traits: normalizedTraits,
      createdAt: DateTime.now(),
    );
  }

  String _resolvePotionType({
    required PotionBlueprint requestedBlueprint,
    required Map<String, double> normalizedTraits,
    required List<PotionRecipeRule> recipeRules,
    required List<PotionRecipeBranchRule> branchRules,
  }) {
    final Set<String> traitIds = normalizedTraits.keys.toSet();
    final List<PotionRecipeRule> matchedRules = recipeRules.where((
      PotionRecipeRule rule,
    ) {
      final bool requiredOk = rule.requiredTraits.every(traitIds.contains);
      final bool forbiddenOk = rule.forbiddenTraits.every(
        (String id) => !traitIds.contains(id),
      );
      return requiredOk && forbiddenOk;
    }).toList();

    if (matchedRules.isEmpty) {
      return requestedBlueprint.id;
    }

    matchedRules.sort((PotionRecipeRule a, PotionRecipeRule b) {
      return b.requiredTraits.length.compareTo(a.requiredTraits.length);
    });
    final PotionRecipeRule selectedRule = matchedRules.first;

    final List<PotionRecipeBranchRule> candidates = branchRules
        .where((PotionRecipeBranchRule b) => b.recipeId == selectedRule.id)
        .toList();
    if (candidates.isEmpty) {
      return selectedRule.resultPotionId;
    }

    final List<MapEntry<String, double>> sortedTraits =
        normalizedTraits.entries.toList()..sort(
          (MapEntry<String, double> a, MapEntry<String, double> b) =>
              b.value.compareTo(a.value),
        );

    if (sortedTraits.length < 2) {
      return selectedRule.resultPotionId;
    }

    final String dominantTrait = sortedTraits.first.key;
    final double ratioGap = sortedTraits.first.value - sortedTraits[1].value;
    for (final PotionRecipeBranchRule branch in candidates) {
      if (branch.dominantTrait == dominantTrait &&
          ratioGap >= branch.ratioGapMin) {
        return branch.branchedPotionId;
      }
    }

    return selectedRule.resultPotionId;
  }

  double _calculateQualityScore({
    required Map<String, double> targetTraits,
    required Map<String, double> actualTraits,
  }) {
    if (targetTraits.isEmpty) {
      return 0;
    }

    double diff = 0;
    targetTraits.forEach((String id, double targetRatio) {
      final double actualRatio = actualTraits[id] ?? 0;
      diff += (targetRatio - actualRatio).abs();
    });

    final double score = 1 - (diff / max(1, targetTraits.length));
    return score.clamp(0, 1);
  }

  PotionQualityGrade _resolveGrade(double score, PotionQualityRule rule) {
    final Map<PotionQualityGrade, double> thresholds = rule.gradeThresholds;
    if (score >= (thresholds[PotionQualityGrade.s] ?? 0.9)) {
      return PotionQualityGrade.s;
    }
    if (score >= (thresholds[PotionQualityGrade.a] ?? 0.75)) {
      return PotionQualityGrade.a;
    }
    if (score >= (thresholds[PotionQualityGrade.b] ?? 0.55)) {
      return PotionQualityGrade.b;
    }
    return PotionQualityGrade.c;
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
    return _normalizeTraits(noisy);
  }

  bool _canCraft(
    PotionBlueprint blueprint,
    Map<String, double> extractedInventory,
    int repeatCount,
  ) {
    if (repeatCount <= 0) {
      return false;
    }
    return blueprint.targetTraits.entries.every((
      MapEntry<String, double> entry,
    ) {
      return (extractedInventory[entry.key] ?? 0) + 0.0001 >=
          (entry.value * repeatCount);
    });
  }

  bool _canCraftOnce(
    PotionBlueprint blueprint,
    Map<String, double> extractedInventory,
  ) {
    return _canCraft(blueprint, extractedInventory, 1);
  }

  Map<String, double> _normalizeTraits(Map<String, double> traits) {
    if (traits.isEmpty) {
      return const <String, double>{};
    }
    final double sum = traits.values.fold(
      0,
      (double prev, double e) => prev + e,
    );
    if (sum <= 0) {
      return traits.map(
        (String key, double value) => MapEntry<String, double>(key, 0),
      );
    }
    return traits.map(
      (String key, double value) =>
          MapEntry<String, double>(key, value < 0 ? 0 : value / sum),
    );
  }
}
