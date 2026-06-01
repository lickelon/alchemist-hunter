import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class PotionDiscoveryRecordResult {
  const PotionDiscoveryRecordResult({
    required this.workshop,
    required this.changed,
    required this.isNew,
    required this.previousGrade,
    required this.recordedGrade,
  });

  final WorkshopState workshop;
  final bool changed;
  final bool isNew;
  final PotionQualityGrade? previousGrade;
  final PotionQualityGrade recordedGrade;
}

class PotionDiscoveryService {
  const PotionDiscoveryService();

  WorkshopState recordDiscovery({
    required WorkshopState workshop,
    required String potionId,
    required Map<String, double> discoveredTraits,
    required PotionQualityGrade grade,
  }) {
    return recordDiscoveryWithResult(
      workshop: workshop,
      potionId: potionId,
      discoveredTraits: discoveredTraits,
      grade: grade,
    ).workshop;
  }

  PotionDiscoveryRecordResult recordDiscoveryWithResult({
    required WorkshopState workshop,
    required String potionId,
    required Map<String, double> discoveredTraits,
    required PotionQualityGrade grade,
  }) {
    final DiscoveredPotionRecipe? current =
        workshop.discoveredPotionRecipes[potionId];
    if (current != null && !_isBetterGrade(grade, current.bestKnownGrade)) {
      return PotionDiscoveryRecordResult(
        workshop: workshop,
        changed: false,
        isNew: false,
        previousGrade: current.bestKnownGrade,
        recordedGrade: current.bestKnownGrade,
      );
    }

    final WorkshopState nextWorkshop = workshop.copyWith(
      discoveredPotionRecipes: <String, DiscoveredPotionRecipe>{
        ...workshop.discoveredPotionRecipes,
        potionId: DiscoveredPotionRecipe(
          potionId: potionId,
          discoveredTraits: Map<String, double>.unmodifiable(discoveredTraits),
          bestKnownGrade: grade,
        ),
      },
    );
    return PotionDiscoveryRecordResult(
      workshop: nextWorkshop,
      changed: true,
      isNew: current == null,
      previousGrade: current?.bestKnownGrade,
      recordedGrade: grade,
    );
  }

  bool _isBetterGrade(
    PotionQualityGrade candidate,
    PotionQualityGrade current,
  ) {
    return candidate.index < current.index;
  }
}
