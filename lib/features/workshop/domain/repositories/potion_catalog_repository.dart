import '../models.dart';

abstract interface class PotionCatalogRepository {
  List<PotionBlueprint> potions();

  PotionBlueprint? findPotionById(String potionId);

  List<PotionRecipeRule> recipeRules();

  List<PotionRecipeBranchRule> recipeBranchRules();

  PotionQualityRule qualityRule();
}
