import 'package:alchemist_hunter/features/workshop/crafting/data/catalogs/workshop_craft_recipes.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/models/workshop_craft_recipe_models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';

class StaticWorkshopCraftRecipeRepository
    implements WorkshopCraftRecipeRepository {
  const StaticWorkshopCraftRecipeRepository();

  @override
  WorkshopCraftRecipe? findRecipeById(String recipeId) {
    return workshopCraftRecipes
        .where((WorkshopCraftRecipe recipe) => recipe.id == recipeId)
        .firstOrNull;
  }

  @override
  List<WorkshopCraftRecipe> recipes() => workshopCraftRecipes;
}
