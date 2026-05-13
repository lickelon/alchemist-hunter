import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class CraftedPotionStackService {
  const CraftedPotionStackService();

  CraftedPotion? potionForStack(WorkshopState workshop, String stackKey) {
    final int owned = workshop.craftedPotionStacks[stackKey] ?? 0;
    if (owned <= 0) {
      return null;
    }
    return workshop.craftedPotionDetails[stackKey];
  }

  WorkshopState consumeOne(WorkshopState workshop, String stackKey) {
    final Map<String, int> stacks = <String, int>{
      ...workshop.craftedPotionStacks,
    };
    final Map<String, CraftedPotion> details = <String, CraftedPotion>{
      ...workshop.craftedPotionDetails,
    };

    final int nextCount = (stacks[stackKey] ?? 0) - 1;
    if (nextCount <= 0) {
      stacks.remove(stackKey);
      details.remove(stackKey);
    } else {
      stacks[stackKey] = nextCount;
    }

    return workshop.copyWith(
      craftedPotionStacks: stacks,
      craftedPotionDetails: details,
    );
  }
}
