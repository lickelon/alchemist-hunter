import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/domain/repositories/homunculus_hatch_repository.dart';

class StaticHomunculusHatchRepository implements HomunculusHatchRepository {
  const StaticHomunculusHatchRepository({
    required List<HomunculusHatchRecipe> recipes,
  }) : _recipes = recipes;

  final List<HomunculusHatchRecipe> _recipes;

  @override
  HomunculusHatchRecipe? findById(String recipeId) {
    return _recipes
        .where((HomunculusHatchRecipe recipe) => recipe.id == recipeId)
        .firstOrNull;
  }

  @override
  List<HomunculusHatchRecipe> recipes() => _recipes;
}
