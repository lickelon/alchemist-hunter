import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

SessionState claimCraftJob({
  required SessionState state,
  required List<CraftQueueJob> queue,
  required CraftQueueJob job,
}) {
  final String? stackKey = job.completedPotionStackKey;
  final CraftedPotion? detail = job.completedPotion;
  if ((stackKey == null || detail == null) && job.completedMaterials.isEmpty) {
    return state;
  }

  final Map<String, int> materialInventory = <String, int>{
    ...state.player.materialInventory,
  };
  job.completedMaterials.forEach((String materialId, int quantity) {
    materialInventory[materialId] =
        (materialInventory[materialId] ?? 0) + quantity;
  });

  final Map<String, int> potionStacks = <String, int>{
    ...state.workshop.craftedPotionStacks,
  };
  final Map<String, CraftedPotion> potionDetails = <String, CraftedPotion>{
    ...state.workshop.craftedPotionDetails,
  };
  if (stackKey != null && detail != null) {
    potionStacks[stackKey] = (potionStacks[stackKey] ?? 0) + job.repeatCount;
    potionDetails[stackKey] = detail;
  }

  return state.copyWith(
    player: state.player.copyWith(materialInventory: materialInventory),
    workshop: state.workshop.copyWith(
      queue: queue,
      craftedPotionStacks: potionStacks,
      craftedPotionDetails: potionDetails,
      potionCraftCount: stackKey != null && detail != null
          ? state.workshop.potionCraftCount + job.repeatCount
          : state.workshop.potionCraftCount,
    ),
  );
}
