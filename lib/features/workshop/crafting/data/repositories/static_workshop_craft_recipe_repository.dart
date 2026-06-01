import 'package:alchemist_hunter/features/workshop/crafting/domain/models/workshop_craft_recipe_models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_data.dart';

class StaticWorkshopCraftRecipeRepository
    implements WorkshopCraftRecipeRepository {
  const StaticWorkshopCraftRecipeRepository({
    required WorkshopCatalogAssets catalog,
  }) : _catalog = catalog;

  final WorkshopCatalogAssets _catalog;

  List<WorkshopCraftRecipe> get _recipes => _catalog.craftRecipes;

  @override
  WorkshopCraftRecipe? findRecipeById(String recipeId) {
    return _recipes
        .where((WorkshopCraftRecipe recipe) => recipe.id == recipeId)
        .firstOrNull;
  }

  @override
  List<WorkshopCraftRecipe> recipes() => _recipes;
}
