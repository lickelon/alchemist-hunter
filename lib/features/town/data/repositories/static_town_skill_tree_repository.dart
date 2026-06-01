import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';

class StaticTownSkillTreeRepository implements TownSkillTreeRepository {
  const StaticTownSkillTreeRepository({required List<TownSkillNode> nodes})
    : _nodes = nodes;

  final List<TownSkillNode> _nodes;

  @override
  TownSkillNode? findById(String nodeId) {
    return _nodes.where((TownSkillNode node) => node.id == nodeId).firstOrNull;
  }

  @override
  List<TownSkillNode> nodes() => _nodes;
}
