import 'package:alchemist_hunter/features/workshop/crafting/domain/models/workshop_craft_recipe_models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';

class StaticWorkshopCraftRecipeRepository
    implements WorkshopCraftRecipeRepository {
  const StaticWorkshopCraftRecipeRepository({
    required List<WorkshopCraftRecipe> recipes,
  }) : _recipes = recipes;

  final List<WorkshopCraftRecipe> _recipes;

  @override
  WorkshopCraftRecipe? findRecipeById(String recipeId) {
    return _recipes
        .where((WorkshopCraftRecipe recipe) => recipe.id == recipeId)
        .firstOrNull;
  }

  @override
  List<WorkshopCraftRecipe> recipes() => _recipes;
}
