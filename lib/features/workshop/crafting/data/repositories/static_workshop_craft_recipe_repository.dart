import 'package:alchemist_hunter/features/workshop/crafting/data/catalogs/workshop_craft_recipes.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/models/workshop_craft_recipe_models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_asset_loader.dart';

class StaticWorkshopCraftRecipeRepository
    implements WorkshopCraftRecipeRepository {
  const StaticWorkshopCraftRecipeRepository({WorkshopCatalogAssets? catalog})
    : _catalog = catalog;

  final WorkshopCatalogAssets? _catalog;

  List<WorkshopCraftRecipe> get _recipes =>
      _catalog?.craftRecipes ?? workshopCraftRecipes;

  @override
  WorkshopCraftRecipe? findRecipeById(String recipeId) {
    return _recipes
        .where((WorkshopCraftRecipe recipe) => recipe.id == recipeId)
        .firstOrNull;
  }

  @override
  List<WorkshopCraftRecipe> recipes() => _recipes;
}
