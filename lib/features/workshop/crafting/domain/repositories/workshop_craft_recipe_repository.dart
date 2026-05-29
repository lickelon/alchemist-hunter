import 'package:alchemist_hunter/features/workshop/crafting/domain/models/workshop_craft_recipe_models.dart';

abstract interface class WorkshopCraftRecipeRepository {
  List<WorkshopCraftRecipe> recipes();

  WorkshopCraftRecipe? findRecipeById(String recipeId);
}
