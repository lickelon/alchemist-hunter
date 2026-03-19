import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_shared_selectors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('workshop skill selectors expose arcane dust and node counts', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(workshopArcaneDustProvider), 2);
    expect(container.read(workshopSkillNodeCountProvider), greaterThan(0));
    expect(container.read(workshopUnlockedSkillNodeCountProvider), 1);
    expect(
      container.read(workshopDashboardSummaryProvider).essenceLabel,
      'Essence 120',
    );
    expect(
      container.read(workshopDashboardSummaryProvider).arcaneDustLabel,
      'ArcaneDust 2',
    );
    expect(
      container.read(workshopInventorySummaryProvider).description,
      contains('재료'),
    );
  });
}
