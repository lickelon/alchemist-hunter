import 'package:alchemist_hunter/features/workshop/data/catalogs/potion_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';

class StaticPotionCatalogRepository implements PotionCatalogRepository {
  const StaticPotionCatalogRepository();

  @override
  PotionBlueprint? findPotionById(String potionId) {
    return potionCatalog
        .where((PotionBlueprint potion) => potion.id == potionId)
        .firstOrNull;
  }

  @override
  List<PotionRecipeBranchRule> recipeBranchRules() => potionRecipeBranchCatalog;

  @override
  List<PotionRecipeRule> recipeRules() => potionRecipeCatalog;

  @override
  PotionQualityRule qualityRule() => potionQualityCatalog;

  @override
  List<PotionBlueprint> potions() => potionCatalog;
}
