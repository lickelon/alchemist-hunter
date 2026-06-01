import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';

class StaticPotionCatalogRepository implements PotionCatalogRepository {
  const StaticPotionCatalogRepository({required WorkshopCatalogAssets catalog})
    : _catalog = catalog;

  final WorkshopCatalogAssets _catalog;

  List<PotionBlueprint> get _potions => _catalog.potions;

  @override
  PotionBlueprint? findPotionById(String potionId) {
    return _potions
        .where((PotionBlueprint potion) => potion.id == potionId)
        .firstOrNull;
  }

  @override
  List<PotionRecipeRule> recipeRules() => _catalog.potionRecipeRules;

  @override
  PotionQualityRule qualityRule() => _catalog.potionQualityRule;

  @override
  List<PotionBlueprint> potions() => _potions;
}
