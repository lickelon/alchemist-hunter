import 'package:alchemist_hunter/features/workshop/crafting/data/catalogs/potion_catalog.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';

class StaticPotionCatalogRepository implements PotionCatalogRepository {
  const StaticPotionCatalogRepository({WorkshopCatalogAssets? catalog})
    : _catalog = catalog;

  final WorkshopCatalogAssets? _catalog;

  List<PotionBlueprint> get _potions => _catalog?.potions ?? potionCatalog;

  @override
  PotionBlueprint? findPotionById(String potionId) {
    return _potions
        .where((PotionBlueprint potion) => potion.id == potionId)
        .firstOrNull;
  }

  @override
  List<PotionRecipeRule> recipeRules() =>
      _catalog?.potionRecipeRules ?? potionRecipeCatalog;

  @override
  PotionQualityRule qualityRule() =>
      _catalog?.potionQualityRule ?? potionQualityCatalog;

  @override
  List<PotionBlueprint> potions() => _potions;
}
