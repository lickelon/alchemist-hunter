import 'package:alchemist_hunter/features/town/data/repositories/static_town_skill_tree_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('static town skill tree repository exposes nodes and root', () {
    const StaticTownSkillTreeRepository repository =
        StaticTownSkillTreeRepository();

    final nodes = repository.nodes();

    expect(nodes, isNotEmpty);
    expect(nodes.first.id, 'town_trade_ledger');
    expect(repository.findById('town_hiring_board')?.name, 'Hiring Board');
  });
}
