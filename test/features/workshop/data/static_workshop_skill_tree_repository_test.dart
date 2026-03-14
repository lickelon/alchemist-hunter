import 'package:alchemist_hunter/features/workshop/data/repositories/static_workshop_skill_tree_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('static workshop skill tree repository exposes nodes and root', () {
    const StaticWorkshopSkillTreeRepository repository =
        StaticWorkshopSkillTreeRepository();

    final nodes = repository.nodes();

    expect(nodes, isNotEmpty);
    expect(nodes.first.id, 'workshop_alembic');
    expect(repository.findById('workshop_sigil_press')?.name, 'Sigil Press');
  });
}
