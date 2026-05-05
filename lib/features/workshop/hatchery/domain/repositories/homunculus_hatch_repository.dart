import 'package:alchemist_hunter/features/workshop/hatchery/domain/models/hatch_models.dart';

abstract interface class HomunculusHatchRepository {
  List<HomunculusHatchRecipe> recipes();

  HomunculusHatchRecipe? findById(String recipeId);
}
