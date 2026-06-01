part of 'potion_crafting_service.dart';

extension PotionCraftingRecipeService on PotionCraftingService {
  String? resolvePotionType({
    required Map<String, double> normalizedTraits,
    required List<PotionRecipeRule> recipeRules,
  }) {
    if (normalizedTraits.length != 2) {
      return null;
    }
    for (final PotionRecipeRule rule in recipeRules) {
      final double mainAmount = normalizedTraits[rule.mainTraitId] ?? 0;
      final double subAmount = normalizedTraits[rule.subTraitId] ?? 0;
      if (mainAmount > subAmount &&
          mainAmount > 0 &&
          subAmount > 0 &&
          normalizedTraits.keys.every(rule.requiredTraits.contains)) {
        return rule.resultPotionId;
      }
    }
    return null;
  }

  ({
    String? predictedPotionId,
    String hintLabel,
    double stability,
    bool alreadyDiscovered,
  })
  previewBrewReaction({
    required Map<String, double> inputTraits,
    required List<PotionRecipeRule> recipeRules,
    required Set<String> discoveredPotionIds,
  }) {
    final Map<String, double> normalizedTraits = normalizeTraits(inputTraits);
    final String? potionId = resolvePotionType(
      normalizedTraits: normalizedTraits,
      recipeRules: recipeRules,
    );
    final bool alreadyDiscovered =
        potionId != null && discoveredPotionIds.contains(potionId);
    final double stability = dominantRatioGap(normalizedTraits);
    final String hintLabel = potionId == null
        ? '알 수 없는 반응'
        : alreadyDiscovered
        ? '기록된 레시피와 유사'
        : '새로운 반응';
    return (
      predictedPotionId: potionId,
      hintLabel: hintLabel,
      stability: stability,
      alreadyDiscovered: alreadyDiscovered,
    );
  }

  double dominantRatioGap(Map<String, double> normalizedTraits) {
    final List<double> values = normalizedTraits.values.toList()
      ..sort((double a, double b) => b.compareTo(a));
    if (values.isEmpty) {
      return 0;
    }
    if (values.length == 1) {
      return values.first.clamp(0, 1);
    }
    return (values.first - values[1]).clamp(0, 1);
  }

  Map<String, double> normalizeTraits(Map<String, double> traits) {
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
