import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class PotionDiscoveryService {
  const PotionDiscoveryService();

  WorkshopState recordDiscovery({
    required WorkshopState workshop,
    required String potionId,
    required Map<String, double> discoveredTraits,
    required PotionQualityGrade grade,
  }) {
    final DiscoveredPotionRecipe? current =
        workshop.discoveredPotionRecipes[potionId];
    if (current != null && !_isBetterGrade(grade, current.bestKnownGrade)) {
      return workshop;
    }

    return workshop.copyWith(
      discoveredPotionRecipes: <String, DiscoveredPotionRecipe>{
        ...workshop.discoveredPotionRecipes,
        potionId: DiscoveredPotionRecipe(
          potionId: potionId,
          discoveredTraits: Map<String, double>.unmodifiable(discoveredTraits),
          bestKnownGrade: grade,
        ),
      },
    );
  }

  bool _isBetterGrade(
    PotionQualityGrade candidate,
    PotionQualityGrade current,
  ) {
    return candidate.index < current.index;
  }
}
