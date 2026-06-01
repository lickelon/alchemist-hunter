import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/data/catalogs/workshop_skill_nodes.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';

class StaticWorkshopSkillTreeRepository implements WorkshopSkillTreeRepository {
  const StaticWorkshopSkillTreeRepository({WorkshopCatalogAssets? catalog})
    : _catalog = catalog;

  final WorkshopCatalogAssets? _catalog;

  List<WorkshopSkillNode> get _nodes =>
      _catalog?.skillNodes ?? workshopSkillNodes;

  @override
  WorkshopSkillNode? findById(String nodeId) {
    return _nodes
        .where((WorkshopSkillNode node) => node.id == nodeId)
        .firstOrNull;
  }

  @override
  List<WorkshopSkillNode> nodes() => _nodes;
}
