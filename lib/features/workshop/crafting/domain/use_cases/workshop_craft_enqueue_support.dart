part of 'workshop_craft_enqueue_use_case.dart';

mixin _CraftEnqueueSupportMixin {
  int queueCapacity({
    required SessionState state,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
  }) {
    return workshopSkillTreeService.craftQueueCapacity(
          state,
          workshopSkillTreeRepository.nodes(),
        ) +
        workshopSupportService.craftQueueCapacityBonus(state);
  }

  bool canEnqueue({
    required SessionState state,
    required int repeatCount,
    required int queueCapacity,
  }) {
    return repeatCount > 0 && state.workshop.queue.length < queueCapacity;
  }

  bool hasActiveJob(List<CraftQueueJob> jobs) {
    return jobs.any(
      (CraftQueueJob job) => job.status != QueueJobStatus.completed,
    );
  }

  Map<String, double> positiveTraitCosts(Map<String, double> traits) {
    return <String, double>{
      for (final MapEntry<String, double> entry in traits.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
  }

  String potionStackKey(CraftedPotion potion) {
    return '${potion.typePotionId}|${potion.qualityGrade.name}';
  }

  Map<String, double> consumeTraits({
    required Map<String, double> inventory,
    required Map<String, double> costs,
  }) {
    final Map<String, double> nextInventory = <String, double>{...inventory};
    for (final MapEntry<String, double> cost in costs.entries) {
      final double nextValue = (nextInventory[cost.key] ?? 0) - cost.value;
      if (nextValue <= 0.0001) {
        nextInventory.remove(cost.key);
      } else {
        nextInventory[cost.key] = nextValue;
      }
    }
    return nextInventory;
  }

  Map<String, int> consumeMaterials({
    required Map<String, int> inventory,
    required Map<String, int> costs,
  }) {
    final Map<String, int> nextInventory = <String, int>{...inventory};
    for (final MapEntry<String, int> cost in costs.entries) {
      final int nextValue = (nextInventory[cost.key] ?? 0) - cost.value;
      if (nextValue <= 0) {
        nextInventory.remove(cost.key);
      } else {
        nextInventory[cost.key] = nextValue;
      }
    }
    return nextInventory;
  }

  bool hasEnoughTraits({
    required Map<String, double> inventory,
    required Map<String, double> costs,
  }) {
    for (final MapEntry<String, double> cost in costs.entries) {
      if ((inventory[cost.key] ?? 0) < cost.value) {
        return false;
      }
    }
    return true;
  }

  bool hasEnoughMaterials({
    required Map<String, int> inventory,
    required Map<String, int> costs,
  }) {
    for (final MapEntry<String, int> cost in costs.entries) {
      if ((inventory[cost.key] ?? 0) < cost.value) {
        return false;
      }
    }
    return true;
  }

  Map<String, int> scaledMaterialCosts(
    Map<String, int> costs,
    int repeatCount,
  ) {
    return <String, int>{
      for (final MapEntry<String, int> entry in costs.entries)
        entry.key: entry.value * repeatCount,
    };
  }

  Map<String, double> scaledTraitCosts(
    Map<String, double> costs,
    int repeatCount,
  ) {
    return <String, double>{
      for (final MapEntry<String, double> entry in costs.entries)
        entry.key: entry.value * repeatCount,
    };
  }
}
