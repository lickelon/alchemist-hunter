import 'dart:math';

import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class PotionCraftingService {
  PotionCraftingService({Random? random}) : _random = random ?? Random();

  final Random _random;

  ({Map<String, int> nextInventory, Map<String, double> extractedTraits})?
  prepareCraftFromInventory({
    required PotionBlueprint blueprint,
    required Map<String, int> inventory,
    required List<MaterialEntity> materials,
  }) {
    final List<MapEntry<String, double>> orderedTraits =
        blueprint.targetTraits.entries.toList()..sort(
          (MapEntry<String, double> left, MapEntry<String, double> right) =>
              right.value.compareTo(left.value),
        );

    final Map<String, int> workingInventory = <String, int>{...inventory};
    final Map<String, double> extractedTraits = <String, double>{};

    for (final MapEntry<String, double> traitEntry in orderedTraits) {
      final MaterialEntity? selected = _selectMaterialForTrait(
        traitId: traitEntry.key,
        inventory: workingInventory,
        materials: materials,
      );
      if (selected == null) {
        return null;
      }

      final int nextCount = (workingInventory[selected.id] ?? 0) - 1;
      if (nextCount <= 0) {
        workingInventory.remove(selected.id);
      } else {
        workingInventory[selected.id] = nextCount;
      }

      final Map<String, double> materialTraits = _expandTraits(selected.traits);
      materialTraits.forEach((String id, double amount) {
        extractedTraits[id] = (extractedTraits[id] ?? 0) + amount;
      });
    }

    return (
      nextInventory: workingInventory,
      extractedTraits: _normalizeTraits(extractedTraits),
    );
  }

  bool canCraftRepeatCount({
    required PotionBlueprint blueprint,
    required Map<String, int> inventory,
    required List<MaterialEntity> materials,
    required int repeatCount,
  }) {
    Map<String, int> workingInventory = <String, int>{...inventory};
    for (int index = 0; index < repeatCount; index++) {
      final ({
        Map<String, int> nextInventory,
        Map<String, double> extractedTraits,
      })?
      prepared = prepareCraftFromInventory(
        blueprint: blueprint,
        inventory: workingInventory,
        materials: materials,
      );
      if (prepared == null) {
        return false;
      }
      workingInventory = prepared.nextInventory;
    }
    return true;
  }

  int maxCraftableRepeatCount({
    required PotionBlueprint blueprint,
    required Map<String, int> inventory,
    required List<MaterialEntity> materials,
    int cap = 99,
  }) {
    Map<String, int> workingInventory = <String, int>{...inventory};
    int count = 0;
    while (count < cap) {
      final ({
        Map<String, int> nextInventory,
        Map<String, double> extractedTraits,
      })?
      prepared = prepareCraftFromInventory(
        blueprint: blueprint,
        inventory: workingInventory,
        materials: materials,
      );
      if (prepared == null) {
        break;
      }
      workingInventory = prepared.nextInventory;
      count += 1;
    }
    return count;
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

  MaterialEntity? _selectMaterialForTrait({
    required String traitId,
    required Map<String, int> inventory,
    required List<MaterialEntity> materials,
  }) {
    MaterialEntity? best;
    double bestScore = -1;

    for (final MaterialEntity material in materials) {
      final int owned = inventory[material.id] ?? 0;
      if (owned <= 0) {
        continue;
      }

      final Map<String, double> traits = _expandTraits(material.traits);
      final double score = traits[traitId] ?? 0;
      if (score <= 0) {
        continue;
      }

      if (score > bestScore) {
        best = material;
        bestScore = score;
      }
    }

    return best;
  }

  Map<String, double> _expandTraits(List<TraitUnit> traits) {
    final Map<String, double> expanded = <String, double>{};
    for (final TraitUnit trait in traits) {
      if (trait.type == TraitType.single) {
        expanded[trait.id] = (expanded[trait.id] ?? 0) + trait.potency;
        continue;
      }

      trait.components.forEach((String id, double ratio) {
        expanded[id] = (expanded[id] ?? 0) + (trait.potency * ratio);
      });
    }
    return expanded;
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
