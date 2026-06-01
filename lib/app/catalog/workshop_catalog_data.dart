import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class WorkshopCatalogAssets {
  const WorkshopCatalogAssets({
    required this.traits,
    required this.materials,
    required this.extractionProfiles,
    required this.potions,
    required this.potionRecipeRules,
    required this.potionQualityRule,
    required this.craftRecipes,
    required this.hatchRecipes,
    required this.skillNodes,
  });

  final List<TraitUnit> traits;
  final List<MaterialEntity> materials;
  final List<ExtractionProfile> extractionProfiles;
  final List<PotionBlueprint> potions;
  final List<PotionRecipeRule> potionRecipeRules;
  final PotionQualityRule potionQualityRule;
  final List<WorkshopCraftRecipe> craftRecipes;
  final List<HomunculusHatchRecipe> hatchRecipes;
  final List<WorkshopSkillNode> skillNodes;
}
