import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';

class StaticWorkshopSkillTreeRepository implements WorkshopSkillTreeRepository {
  const StaticWorkshopSkillTreeRepository({
    required WorkshopCatalogAssets catalog,
  }) : _catalog = catalog;

  final WorkshopCatalogAssets _catalog;

  List<WorkshopSkillNode> get _nodes => _catalog.skillNodes;

  @override
  WorkshopSkillNode? findById(String nodeId) {
    return _nodes
        .where((WorkshopSkillNode node) => node.id == nodeId)
        .firstOrNull;
  }

  @override
  List<WorkshopSkillNode> nodes() => _nodes;
}
