import 'package:flutter_test/flutter_test.dart';
import '../../../../support/catalog_fixtures.dart';

void main() {
  test('static workshop skill tree repository exposes nodes and root', () {
    final repository = testWorkshopSkillTreeRepository;

    final nodes = repository.nodes();

    expect(nodes, isNotEmpty);
    expect(nodes.first.id, 'workshop_alembic');
    expect(repository.findById('workshop_sigil_press')?.name, 'Sigil Press');
  });
}
