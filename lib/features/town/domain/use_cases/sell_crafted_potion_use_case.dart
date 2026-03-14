import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

typedef PotionBaseValueLookup = int? Function(String potionId);

class SellCraftedPotionUseCase {
  const SellCraftedPotionUseCase();

  SessionState sellCraftedPotion({
    required SessionState state,
    required String stackKey,
    required int quantity,
    required PotionBaseValueLookup potionBaseValueLookup,
  }) {
    final int owned = state.workshop.craftedPotionStacks[stackKey] ?? 0;
    if (quantity < 1 || owned < quantity) {
      return state;
    }

    final CraftedPotion? sample = state.workshop.craftedPotionDetails[stackKey];
    if (sample == null) {
      return state;
    }

    final int? potionBaseValue = potionBaseValueLookup(sample.typePotionId);
    if (potionBaseValue == null) {
      return state;
    }
    final double multiplier = switch (sample.qualityGrade) {
      PotionQualityGrade.s => 1.6,
      PotionQualityGrade.a => 1.3,
      PotionQualityGrade.b => 1.0,
      PotionQualityGrade.c => 0.8,
    };
    final int earned = (potionBaseValue * multiplier * quantity).round();

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
      player: state.player.copyWith(
        gold: state.player.gold + earned,
        townInsight: state.player.townInsight + quantity,
      ),
      town: state.town.copyWith(
        potionSalesTotal: state.town.potionSalesTotal + earned,
      ),
      workshop: state.workshop.copyWith(
        craftedPotionStacks: stacks,
        craftedPotionDetails: details,
      ),
    );
  }
}
