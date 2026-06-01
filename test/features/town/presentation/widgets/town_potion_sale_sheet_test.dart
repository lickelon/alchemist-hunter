import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/sheets/town_potion_sale_sheet.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/catalog_fixtures.dart';

void main() {
  testWidgets('town potion sale sheet shows potion name instead of stack key', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: testCatalogProviderOverrides(),
    );
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        craftedPotionStacks: const <String, int>{'p_1|a': 1},
        craftedPotionDetails: <String, CraftedPotion>{
          'p_1|a': CraftedPotion(
            id: 'cp_1',
            typePotionId: 'p_1',
            qualityGrade: PotionQualityGrade.a,
            qualityScore: 0.84,
            traits: const <String, double>{'t_atk': 0.7, 't_hp': 0.3},
            createdAt: DateTime(2026, 1, 1, 10),
          ),
        },
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: TownPotionSaleSheet())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('sale_potion_p_1|a')));
    await tester.pumpAndSettle();

    expect(find.text('활력 포션'), findsOneWidget);
    expect(find.text('품질 A'), findsOneWidget);
    expect(find.text('점수 0.84'), findsOneWidget);
    expect(find.text('p_1|a x1'), findsNothing);
  });
}
