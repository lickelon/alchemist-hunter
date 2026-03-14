import '../models.dart';

abstract interface class HomunculusHatchRepository {
  List<HomunculusHatchRecipe> recipes();

  HomunculusHatchRecipe? findById(String recipeId);
}
