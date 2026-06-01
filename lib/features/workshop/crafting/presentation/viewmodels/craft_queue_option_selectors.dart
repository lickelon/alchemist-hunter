import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/discovered_potion_recipe_selectors.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/material_craft_recipe_selectors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'craft_queue_potion_option_selectors.dart';
export 'discovered_potion_recipe_selectors.dart';
export 'material_craft_recipe_selectors.dart';

class WorkshopCraftMenuSummaryView {
  const WorkshopCraftMenuSummaryView({
    required this.craftableCount,
    required this.unlockedCount,
    required this.materialCraftableCount,
    required this.description,
  });

  final int craftableCount;
  final int unlockedCount;
  final int materialCraftableCount;
  final String description;
}

final Provider<WorkshopCraftMenuSummaryView> workshopCraftMenuSummaryProvider =
    Provider<WorkshopCraftMenuSummaryView>((Ref ref) {
      final List<DiscoveredPotionRecipeView> discoveredRecipes = ref.watch(
        workshopDiscoveredPotionRecipeViewsProvider,
      );
      final List<WorkshopMaterialCraftRecipeView> materialRecipes = ref.watch(
        workshopMaterialCraftRecipeViewsProvider,
      );
      final int unlockedCount = discoveredRecipes.length;
      final int craftableCount = discoveredRecipes
          .where((entry) => entry.craftableNow)
          .length;
      final int materialCraftableCount = materialRecipes
          .where((entry) => entry.craftableNow)
          .length;
      final String description = unlockedCount == 0
          ? '양조 가능한 포션 없음'
          : '양조 $craftableCount종 / 제작 $materialCraftableCount종';
      return WorkshopCraftMenuSummaryView(
        craftableCount: craftableCount,
        unlockedCount: unlockedCount,
        materialCraftableCount: materialCraftableCount,
        description: description,
      );
    });
