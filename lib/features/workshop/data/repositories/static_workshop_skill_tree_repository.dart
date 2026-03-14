import 'package:alchemist_hunter/features/workshop/data/catalogs/workshop_skill_nodes.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';

class StaticWorkshopSkillTreeRepository
    implements WorkshopSkillTreeRepository {
  const StaticWorkshopSkillTreeRepository();

  @override
  WorkshopSkillNode? findById(String nodeId) {
    return workshopSkillNodes
        .where((WorkshopSkillNode node) => node.id == nodeId)
        .firstOrNull;
  }

  @override
  List<WorkshopSkillNode> nodes() => workshopSkillNodes;
}
