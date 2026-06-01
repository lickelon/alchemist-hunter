import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';

class StaticPotionCatalogRepository implements PotionCatalogRepository {
  const StaticPotionCatalogRepository({
    required List<PotionBlueprint> potions,
    required List<PotionRecipeRule> recipeRules,
    required PotionQualityRule qualityRule,
  }) : _potions = potions,
       _recipeRules = recipeRules,
       _qualityRule = qualityRule;

  final List<PotionBlueprint> _potions;
  final List<PotionRecipeRule> _recipeRules;
  final PotionQualityRule _qualityRule;

  @override
  PotionBlueprint? findPotionById(String potionId) {
    return _potions
        .where((PotionBlueprint potion) => potion.id == potionId)
        .firstOrNull;
  }

  @override
  List<PotionRecipeRule> recipeRules() => _recipeRules;

  @override
  PotionQualityRule qualityRule() => _qualityRule;

  @override
  List<PotionBlueprint> potions() => _potions;
}
