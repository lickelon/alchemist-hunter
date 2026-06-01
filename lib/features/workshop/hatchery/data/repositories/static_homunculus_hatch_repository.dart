import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/data/catalogs/homunculus_hatch_recipes.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/domain/repositories/homunculus_hatch_repository.dart';

class StaticHomunculusHatchRepository implements HomunculusHatchRepository {
  const StaticHomunculusHatchRepository({WorkshopCatalogAssets? catalog})
    : _catalog = catalog;

  final WorkshopCatalogAssets? _catalog;

  List<HomunculusHatchRecipe> get _recipes =>
      _catalog?.hatchRecipes ?? homunculusHatchRecipes;

  @override
  HomunculusHatchRecipe? findById(String recipeId) {
    return _recipes
        .where((HomunculusHatchRecipe recipe) => recipe.id == recipeId)
        .firstOrNull;
  }

  @override
  List<HomunculusHatchRecipe> recipes() => _recipes;
}
