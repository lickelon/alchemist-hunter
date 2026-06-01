import 'package:alchemist_hunter/features/town/data/catalogs/town_skill_nodes.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';

class StaticTownSkillTreeRepository implements TownSkillTreeRepository {
  const StaticTownSkillTreeRepository({List<TownSkillNode>? nodes})
    : _nodes = nodes;

  final List<TownSkillNode>? _nodes;

  List<TownSkillNode> get _catalog => _nodes ?? townSkillNodes;

  @override
  TownSkillNode? findById(String nodeId) {
    return _catalog
        .where((TownSkillNode node) => node.id == nodeId)
        .firstOrNull;
  }

  @override
  List<TownSkillNode> nodes() => _catalog;
}
