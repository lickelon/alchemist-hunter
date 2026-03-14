import 'package:alchemist_hunter/features/town/data/catalogs/town_skill_nodes.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';

class StaticTownSkillTreeRepository implements TownSkillTreeRepository {
  const StaticTownSkillTreeRepository();

  @override
  TownSkillNode? findById(String nodeId) {
    return townSkillNodes
        .where((TownSkillNode node) => node.id == nodeId)
        .firstOrNull;
  }

  @override
  List<TownSkillNode> nodes() => townSkillNodes;
}
