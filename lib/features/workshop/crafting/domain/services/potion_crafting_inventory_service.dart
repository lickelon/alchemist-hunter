part of 'potion_crafting_service.dart';

extension PotionCraftingInventoryService on PotionCraftingService {
  ({
    Map<String, double> nextExtractedInventory,
    Map<String, double> extractedTraits,
  })?
  prepareInventoryCraft({
    required PotionBlueprint blueprint,
    required Map<String, double> extractedInventory,
  }) {
    if (!canCraft(
      blueprint: blueprint,
      extractedInventory: extractedInventory,
      repeatCount: 1,
    )) {
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

  bool canCraft({
    required PotionBlueprint blueprint,
    required Map<String, double> extractedInventory,
    required int repeatCount,
  }) {
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

  int maxRepeatCount({
    required PotionBlueprint blueprint,
    required Map<String, double> extractedInventory,
    required int cap,
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
}
