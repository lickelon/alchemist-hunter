import 'package:alchemist_hunter/features/workshop/crafting/domain/use_cases/workshop_brew_experiment_use_case.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

enum WorkshopCraftSubmitResult {
  success,
  queueFull,
  elementMissing,
  resourceMissing,
  failed,
}

class WorkshopBrewExperimentSubmitResult {
  const WorkshopBrewExperimentSubmitResult({
    required this.status,
    this.potionId,
    this.qualityGrade,
    this.qualityScore,
    this.discoveredTraits,
    this.discoveryChanged = false,
    this.isNewDiscovery = false,
    this.previousGrade,
    this.recordedGrade,
  });

  final WorkshopBrewExperimentStatus status;
  final String? potionId;
  final PotionQualityGrade? qualityGrade;
  final double? qualityScore;
  final Map<String, double>? discoveredTraits;
  final bool discoveryChanged;
  final bool isNewDiscovery;
  final PotionQualityGrade? previousGrade;
  final PotionQualityGrade? recordedGrade;
}
