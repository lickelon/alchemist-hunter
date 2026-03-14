import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/extraction_profiles.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/potion_catalog.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_tables.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/shop_seed.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class DummyData {
  static final List<TraitUnit> traits = traitCatalog;

  static final List<MaterialEntity> materials = materialCatalog;

  static final List<PotionBlueprint> potions = potionCatalog;

  static const List<PotionRecipeRule> potionRecipeRules = potionRecipeCatalog;

  static const List<PotionRecipeBranchRule> potionRecipeBranchRules =
      potionRecipeBranchCatalog;

  static const PotionQualityRule potionQualityRule = potionQualityCatalog;

  static const List<ExtractionProfile> extractionProfiles =
      extractionProfileCatalog;

  static final List<String> stages = stageCatalog;

  static final List<String> enemySets = enemySetCatalog;

  static ShopState generalShopState(DateTime now) {
    return buildGeneralShopState(now);
  }

  static ShopState catalystShopState(DateTime now) {
    return buildCatalystShopState(now);
  }

  static BattleDropTable dropTable(String stageId) {
    return stageDropTable(stageId);
  }

  static List<ShopItem> buildGeneralShopItems() {
    return buildGeneralShopSeedItems();
  }

  static List<ShopItem> buildCatalystShopItems() {
    return buildCatalystShopSeedItems();
  }
}
