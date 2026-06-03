import 'package:alchemist_hunter/features/workshop/dashboard/presentation/viewmodels/workshop_dashboard_selectors.dart';
import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_resource_selectors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../support/catalog_fixtures.dart';

void main() {
  test('workshop skill selectors expose resource labels and node counts', () {
    final ProviderContainer container = ProviderContainer(
      overrides: testCatalogProviderOverrides(),
    );
    addTearDown(container.dispose);

    expect(container.read(workshopArcaneDustProvider), 2);
    expect(container.read(workshopSkillNodeCountProvider), greaterThan(0));
    expect(container.read(workshopUnlockedSkillNodeCountProvider), 1);
    expect(
      container.read(workshopDashboardSummaryProvider).essenceLabel,
      '정수 120',
    );
    expect(
      container.read(workshopDashboardSummaryProvider).arcaneDustLabel,
      '신비 2',
    );
    expect(
      container.read(workshopInventorySummaryProvider).description,
      contains('재료'),
    );
  });
}
