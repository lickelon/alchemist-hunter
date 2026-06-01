import 'package:flutter_test/flutter_test.dart';
import '../../../support/catalog_fixtures.dart';

void main() {
  test('static town skill tree repository exposes nodes and root', () {
    final repository = testTownSkillTreeRepository;

    final nodes = repository.nodes();

    expect(nodes, isNotEmpty);
    expect(nodes.first.id, 'town_trade_ledger');
    expect(repository.findById('town_hiring_board')?.name, 'Hiring Board');
  });
}
