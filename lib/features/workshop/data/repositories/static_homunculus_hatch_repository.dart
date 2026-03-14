import 'package:alchemist_hunter/features/workshop/data/catalogs/homunculus_hatch_recipes.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/homunculus_hatch_repository.dart';

class StaticHomunculusHatchRepository implements HomunculusHatchRepository {
  const StaticHomunculusHatchRepository();

  @override
  HomunculusHatchRecipe? findById(String recipeId) {
    return homunculusHatchRecipes
        .where((HomunculusHatchRecipe recipe) => recipe.id == recipeId)
        .firstOrNull;
  }

  @override
  List<HomunculusHatchRecipe> recipes() => homunculusHatchRecipes;
}
