import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';

class StaticWorkshopSkillTreeRepository implements WorkshopSkillTreeRepository {
  const StaticWorkshopSkillTreeRepository({
    required List<WorkshopSkillNode> nodes,
  }) : _nodes = nodes;

  final List<WorkshopSkillNode> _nodes;

  @override
  WorkshopSkillNode? findById(String nodeId) {
    return _nodes
        .where((WorkshopSkillNode node) => node.id == nodeId)
        .firstOrNull;
  }

  @override
  List<WorkshopSkillNode> nodes() => _nodes;
}
