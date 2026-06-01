part of 'workshop_craft_queue_controller.dart';

mixin _WorkshopCraftQueueExperimentController
    on _WorkshopCraftQueueControllerSupport {
  WorkshopBrewExperimentSubmitResult experimentBrew(
    Map<String, double> inputTraits,
  ) {
    final SessionState current = _session.snapshot();
    final WorkshopBrewExperimentResult result = _brewExperimentUseCase
        .experiment(
          state: current,
          inputTraits: inputTraits,
          craftingService: _craftingService,
          discoveryService: _discoveryService,
          potionCatalogRepository: _potionCatalogRepository,
        );
    if (!identical(result.state, current)) {
      applyState(
        result.state,
        logMessage: switch (result.status) {
          WorkshopBrewExperimentStatus.success =>
            '양조 실험 완료 / ${result.potionId ?? 'unknown'} ${result.qualityGrade?.name ?? ''}',
          WorkshopBrewExperimentStatus.unknownReaction => '양조 실험 실패 / 조합 불명',
          WorkshopBrewExperimentStatus.elementMissing => '원소 부족 / 양조 실험',
          WorkshopBrewExperimentStatus.failed => '양조 실험 실패',
        },
      );
    } else {
      _session.appendLog(
        result.status == WorkshopBrewExperimentStatus.elementMissing
            ? '원소 부족 / 양조 실험'
            : '양조 실험 실패',
      );
    }

    return WorkshopBrewExperimentSubmitResult(
      status: result.status,
      potionId: result.potionId,
      qualityGrade: result.qualityGrade,
      qualityScore: result.qualityScore,
      discoveredTraits: result.discoveredTraits,
      discoveryChanged: result.discoveryChanged,
      isNewDiscovery: result.isNewDiscovery,
      previousGrade: result.previousGrade,
      recordedGrade: result.recordedGrade,
    );
  }

  bool pinBrewExperimentRecipe({
    required String potionId,
    required Map<String, double> discoveredTraits,
    required PotionQualityGrade grade,
  }) {
    final SessionState current = _session.snapshot();
    final WorkshopState nextWorkshop = current.workshop.copyWith(
      discoveredPotionRecipes: <String, DiscoveredPotionRecipe>{
        ...current.workshop.discoveredPotionRecipes,
        potionId: DiscoveredPotionRecipe(
          potionId: potionId,
          discoveredTraits: Map<String, double>.unmodifiable(discoveredTraits),
          bestKnownGrade: grade,
        ),
      },
    );
    applyState(
      current.copyWith(workshop: nextWorkshop),
      logMessage: '양조 레시피 고정 / $potionId ${grade.name}',
    );
    return true;
  }
}
