import 'package:alchemist_hunter/features/workshop/crafting/domain/models/potion_models.dart';

abstract interface class PotionCatalogRepository {
  List<PotionBlueprint> potions();

  PotionBlueprint? findPotionById(String potionId);

  List<PotionRecipeRule> recipeRules();

  List<PotionRecipeBranchRule> recipeBranchRules();

  PotionQualityRule qualityRule();
}
