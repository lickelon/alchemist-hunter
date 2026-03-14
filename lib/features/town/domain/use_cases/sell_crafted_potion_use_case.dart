import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/potion_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class SellCraftedPotionUseCase {
  const SellCraftedPotionUseCase();

  SessionState sellCraftedPotion({
    required SessionState state,
    required String stackKey,
    required int quantity,
  }) {
    final int owned = state.workshop.craftedPotionStacks[stackKey] ?? 0;
    if (quantity < 1 || owned < quantity) {
      return state;
    }

    final CraftedPotion? sample = state.workshop.craftedPotionDetails[stackKey];
    if (sample == null) {
      return state;
    }

    final PotionBlueprint blueprint = potionCatalog.firstWhere(
      (PotionBlueprint potion) => potion.id == sample.typePotionId,
      orElse: () => potionCatalog.first,
    );
    final double multiplier = switch (sample.qualityGrade) {
      PotionQualityGrade.s => 1.6,
      PotionQualityGrade.a => 1.3,
      PotionQualityGrade.b => 1.0,
      PotionQualityGrade.c => 0.8,
    };
    final int earned = (blueprint.baseValue * multiplier * quantity).round();

    final Map<String, int> stacks = <String, int>{
      ...state.workshop.craftedPotionStacks,
    };
    final Map<String, CraftedPotion> details = <String, CraftedPotion>{
      ...state.workshop.craftedPotionDetails,
    };
    final int nextQuantity = owned - quantity;

    if (nextQuantity <= 0) {
      stacks.remove(stackKey);
      details.remove(stackKey);
    } else {
      stacks[stackKey] = nextQuantity;
    }

    return state.copyWith(
      player: state.player.copyWith(gold: state.player.gold + earned),
      workshop: state.workshop.copyWith(
        craftedPotionStacks: stacks,
        craftedPotionDetails: details,
      ),
    );
  }
}
