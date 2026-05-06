import 'package:alchemist_hunter/app/session/session_factory.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_town_skill_tree_repository.dart';

InitialSessionCatalogs createDefaultInitialSessionCatalogs() {
  return const InitialSessionCatalogs(
    shopCatalogRepository: StaticShopCatalogRepository(),
    mercenaryTemplateRepository: StaticMercenaryTemplateRepository(),
    townSkillTreeRepository: StaticTownSkillTreeRepository(),
  );
}
