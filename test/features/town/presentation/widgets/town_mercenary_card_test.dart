import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/town_mercenary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/catalog_fixtures.dart';

void main() {
  testWidgets('town mercenary sheet shows hire candidates', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: testCatalogProviderOverrides(),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: TownMercenaryHireCard(candidateCount: 3)),
        ),
      ),
    );

    await tester.tap(find.text('용병 고용'));
    await tester.pumpAndSettle();

    expect(find.text('용병 고용'), findsWidgets);
    expect(find.text('Rookie 전사'), findsOneWidget);
    expect(find.text('Rookie 마법사'), findsOneWidget);
    expect(find.text('Rookie 도적'), findsOneWidget);
    expect(find.text('후보 갱신'), findsOneWidget);
  });

  testWidgets('hiring from mercenary sheet updates session state', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: testCatalogProviderOverrides(),
    );
    addTearDown(container.dispose);
    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: TownMercenaryHireCard(candidateCount: 3)),
        ),
      ),
    );

    await tester.tap(find.text('용병 고용'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '고용').first);
    await tester.pumpAndSettle();

    expect(session.state.player.gold, 1330);
    expect(session.state.characters.mercenaries, hasLength(2));
    expect(session.state.characters.mercenaries.last.name, '전사');
    expect(session.state.town.mercenaryCandidates, hasLength(2));
  });
}
