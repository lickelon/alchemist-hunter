import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_discovery_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

enum WorkshopBrewExperimentStatus {
  success,
  unknownReaction,
  elementMissing,
  failed,
}

class WorkshopBrewExperimentResult {
  const WorkshopBrewExperimentResult({
    required this.status,
    required this.state,
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
  final SessionState state;
  final String? potionId;
  final PotionQualityGrade? qualityGrade;
  final double? qualityScore;
  final Map<String, double>? discoveredTraits;
  final bool discoveryChanged;
  final bool isNewDiscovery;
  final PotionQualityGrade? previousGrade;
  final PotionQualityGrade? recordedGrade;
}

class WorkshopBrewExperimentUseCase {
  const WorkshopBrewExperimentUseCase();

  WorkshopBrewExperimentResult experiment({
    required SessionState state,
    required Map<String, double> inputTraits,
    required PotionCraftingService craftingService,
    required PotionDiscoveryService discoveryService,
    required PotionCatalogRepository potionCatalogRepository,
  }) {
    final Map<String, double> costs = _positiveTraitCosts(inputTraits);
    if (costs.isEmpty) {
      return WorkshopBrewExperimentResult(
        status: WorkshopBrewExperimentStatus.failed,
        state: state,
      );
    }

    final double totalCost = costs.values.fold(
      0,
      (double previous, double amount) => previous + amount,
    );
    if ((totalCost - 1).abs() > 0.0001) {
      return WorkshopBrewExperimentResult(
        status: WorkshopBrewExperimentStatus.failed,
        state: state,
      );
    }

    final Map<String, double> traits = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    for (final MapEntry<String, double> cost in costs.entries) {
      if ((traits[cost.key] ?? 0) < cost.value) {
        return WorkshopBrewExperimentResult(
          status: WorkshopBrewExperimentStatus.elementMissing,
          state: state,
        );
      }
    }
    for (final MapEntry<String, double> cost in costs.entries) {
      final double nextValue = (traits[cost.key] ?? 0) - cost.value;
      if (nextValue <= 0.0001) {
        traits.remove(cost.key);
      } else {
        traits[cost.key] = nextValue;
      }
    }

    final WorkshopState consumedWorkshop = state.workshop.copyWith(
      extractedTraitInventory: traits,
    );
    final SessionState consumedState = state.copyWith(
      workshop: consumedWorkshop,
    );

    final String? potionId = craftingService.resolvePotionTypeFromTraits(
      inputTraits: costs,
      recipeRules: potionCatalogRepository.recipeRules(),
    );
    if (potionId == null) {
      return WorkshopBrewExperimentResult(
        status: WorkshopBrewExperimentStatus.unknownReaction,
        state: consumedState,
      );
    }

    final PotionBlueprint? blueprint = potionCatalogRepository.findPotionById(
      potionId,
    );
    if (blueprint == null) {
      return WorkshopBrewExperimentResult(
        status: WorkshopBrewExperimentStatus.unknownReaction,
        state: consumedState,
      );
    }

    final CraftedPotion craftedPotion = craftingService.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: costs,
      recipeRules: potionCatalogRepository.recipeRules(),
      qualityRule: potionCatalogRepository.qualityRule(),
    );
    final PotionDiscoveryRecordResult discovery = discoveryService
        .recordDiscoveryWithResult(
          workshop: consumedWorkshop,
          potionId: craftedPotion.typePotionId,
          discoveredTraits: craftedPotion.traits,
          grade: craftedPotion.qualityGrade,
        );

    return WorkshopBrewExperimentResult(
      status: WorkshopBrewExperimentStatus.success,
      state: consumedState.copyWith(workshop: discovery.workshop),
      potionId: craftedPotion.typePotionId,
      qualityGrade: craftedPotion.qualityGrade,
      qualityScore: craftedPotion.qualityScore,
      discoveredTraits: craftedPotion.traits,
      discoveryChanged: discovery.changed,
      isNewDiscovery: discovery.isNew,
      previousGrade: discovery.previousGrade,
      recordedGrade: discovery.recordedGrade,
    );
  }

  Map<String, double> _positiveTraitCosts(Map<String, double> traits) {
    return <String, double>{
      for (final MapEntry<String, double> entry in traits.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
  }
}
