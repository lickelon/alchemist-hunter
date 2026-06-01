import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_resource_selectors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/catalog_fixtures.dart';

void main() {
  test('town skill selectors expose fame and node counts', () {
    final ProviderContainer container = ProviderContainer(
      overrides: testCatalogProviderOverrides(),
    );
    addTearDown(container.dispose);

    expect(container.read(townInsightProvider), 2);
    expect(container.read(townSkillNodeCountProvider), greaterThan(0));
    expect(container.read(townUnlockedSkillNodeCountProvider), 1);
  });
}
