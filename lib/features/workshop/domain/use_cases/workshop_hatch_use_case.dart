import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';

class WorkshopHatchUseCase {
  const WorkshopHatchUseCase();

  SessionState hatchHomunculus({
    required SessionState state,
    required HomunculusHatchRecipe recipe,
    required DateTime now,
    required WorkshopSupportService workshopSupportService,
  }) {
    final int arcaneDustCost = (recipe.arcaneDustCost -
            workshopSupportService.hatchArcaneDustDiscount(state))
        .clamp(0, recipe.arcaneDustCost)
        .toInt();
    if (state.player.essence < recipe.essenceCost ||
        state.player.arcaneDust < arcaneDustCost) {
      return state;
    }

    final Map<String, int> materialInventory = <String, int>{
      ...state.player.materialInventory,
    };
    for (final MapEntry<String, int> entry in recipe.materialCosts.entries) {
      if ((materialInventory[entry.key] ?? 0) < entry.value) {
        return state;
      }
    }

    final Map<String, double> traitInventory = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    for (final MapEntry<String, double> entry in recipe.traitCosts.entries) {
      if ((traitInventory[entry.key] ?? 0) < entry.value) {
        return state;
      }
    }

    for (final MapEntry<String, int> entry in recipe.materialCosts.entries) {
      final int nextValue = (materialInventory[entry.key] ?? 0) - entry.value;
      if (nextValue <= 0) {
        materialInventory.remove(entry.key);
      } else {
        materialInventory[entry.key] = nextValue;
      }
    }

    for (final MapEntry<String, double> entry in recipe.traitCosts.entries) {
      final double nextValue = (traitInventory[entry.key] ?? 0) - entry.value;
      if (nextValue <= 0) {
        traitInventory.remove(entry.key);
      } else {
        traitInventory[entry.key] = nextValue;
      }
    }

    final CharacterProgress homunculus = CharacterProgress(
      id: 'homo_${now.microsecondsSinceEpoch}_${recipe.id}',
      name: recipe.resultName,
      type: CharacterType.homunculus,
      level: 1,
      rank: 1,
      xp: 0,
      homunculusTier: HomunculusTier.nigredo,
      homunculusOrigin: recipe.name,
      homunculusRole: recipe.roleLabel,
      homunculusSupportEffect: recipe.supportEffectLabel,
    );

    return state.copyWith(
      player: state.player.copyWith(
        essence: state.player.essence - recipe.essenceCost,
        arcaneDust: state.player.arcaneDust - arcaneDustCost,
        materialInventory: materialInventory,
      ),
      workshop: state.workshop.copyWith(extractedTraitInventory: traitInventory),
      characters: state.characters.copyWith(
        homunculi: <CharacterProgress>[
          ...state.characters.homunculi,
          homunculus,
        ],
      ),
    );
  }
}
