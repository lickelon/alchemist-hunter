import 'craft_queue_models.dart';
import 'potion_models.dart';
import 'workshop_skill_tree_models.dart';

class WorkshopState {
  const WorkshopState({
    required this.queue,
    required this.extractedTraitInventory,
    required this.craftedPotionStacks,
    required this.craftedPotionDetails,
    required this.logs,
    required this.skillTree,
    required this.extractionCount,
    required this.potionCraftCount,
    required this.enchantCount,
  });

  final List<CraftQueueJob> queue;
  final Map<String, double> extractedTraitInventory;
  final Map<String, int> craftedPotionStacks;
  final Map<String, CraftedPotion> craftedPotionDetails;
  final List<String> logs;
  final WorkshopSkillTreeState skillTree;
  final int extractionCount;
  final int potionCraftCount;
  final int enchantCount;

  WorkshopState copyWith({
    List<CraftQueueJob>? queue,
    Map<String, double>? extractedTraitInventory,
    Map<String, int>? craftedPotionStacks,
    Map<String, CraftedPotion>? craftedPotionDetails,
    List<String>? logs,
    WorkshopSkillTreeState? skillTree,
    int? extractionCount,
    int? potionCraftCount,
    int? enchantCount,
  }) {
    return WorkshopState(
      queue: queue ?? this.queue,
      extractedTraitInventory:
          extractedTraitInventory ?? this.extractedTraitInventory,
      craftedPotionStacks: craftedPotionStacks ?? this.craftedPotionStacks,
      craftedPotionDetails: craftedPotionDetails ?? this.craftedPotionDetails,
      logs: logs ?? this.logs,
      skillTree: skillTree ?? this.skillTree,
      extractionCount: extractionCount ?? this.extractionCount,
      potionCraftCount: potionCraftCount ?? this.potionCraftCount,
      enchantCount: enchantCount ?? this.enchantCount,
    );
  }
}
