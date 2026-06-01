part of 'workshop_craft_queue_controller.dart';

mixin _WorkshopCraftQueueControllerSupport {
  SessionController get _session;
  PotionCraftingService get _craftingService;
  WorkshopBrewExperimentUseCase get _brewExperimentUseCase;
  WorkshopCraftEnqueueUseCase get _craftEnqueueUseCase;
  WorkshopQueueClaimUseCase get _queueClaimUseCase;
  PotionCatalogRepository get _potionCatalogRepository;
  WorkshopCraftRecipeRepository get _craftRecipeRepository;
  WorkshopSkillTreeRepository get _workshopSkillTreeRepository;
  WorkshopSkillTreeService get _workshopSkillTreeService;
  WorkshopSupportService get _workshopSupportService;
  PotionDiscoveryService get _discoveryService;

  int queueCapacity(SessionState state) {
    return _workshopSkillTreeService.craftQueueCapacity(
          state,
          _workshopSkillTreeRepository.nodes(),
        ) +
        _workshopSupportService.craftQueueCapacityBonus(state);
  }

  void applyState(SessionState nextState, {String? logMessage}) {
    _session.applyState(nextState);
    if (logMessage != null) {
      _session.appendLog(logMessage);
    }
  }

  bool hasEnoughTraits(
    Map<String, double> costs,
    Map<String, double> inventory,
    int repeatCount,
  ) {
    if (repeatCount <= 0) {
      return false;
    }
    final Iterable<MapEntry<String, double>> positiveCosts = costs.entries
        .where((MapEntry<String, double> entry) => entry.value > 0);
    if (positiveCosts.isEmpty) {
      return false;
    }
    return positiveCosts.every((MapEntry<String, double> entry) {
      return (inventory[entry.key] ?? 0) + 0.0001 >= entry.value * repeatCount;
    });
  }
}
