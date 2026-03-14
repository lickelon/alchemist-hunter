import 'craft_queue_models.dart';
import 'potion_models.dart';

class WorkshopState {
  const WorkshopState({
    required this.queue,
    required this.extractedTraitInventory,
    required this.craftedPotionStacks,
    required this.craftedPotionDetails,
    required this.logs,
  });

  final List<CraftQueueJob> queue;
  final Map<String, double> extractedTraitInventory;
  final Map<String, int> craftedPotionStacks;
  final Map<String, CraftedPotion> craftedPotionDetails;
  final List<String> logs;

  WorkshopState copyWith({
    List<CraftQueueJob>? queue,
    Map<String, double>? extractedTraitInventory,
    Map<String, int>? craftedPotionStacks,
    Map<String, CraftedPotion>? craftedPotionDetails,
    List<String>? logs,
  }) {
    return WorkshopState(
      queue: queue ?? this.queue,
      extractedTraitInventory:
          extractedTraitInventory ?? this.extractedTraitInventory,
      craftedPotionStacks: craftedPotionStacks ?? this.craftedPotionStacks,
      craftedPotionDetails: craftedPotionDetails ?? this.craftedPotionDetails,
      logs: logs ?? this.logs,
    );
  }
}
