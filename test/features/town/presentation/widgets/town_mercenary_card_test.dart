import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/town_mercenary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('town mercenary sheet shows hire candidates', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: TownMercenaryHireCard(candidateCount: 3, mercenaryCount: 1),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mercenary Hire'));
    await tester.pumpAndSettle();

    expect(find.text('용병 고용'), findsOneWidget);
    expect(find.text('Apprentice Sellsword'), findsOneWidget);
    expect(find.text('Hedge Guard'), findsOneWidget);
    expect(find.text('후보 갱신'), findsOneWidget);
  });

  testWidgets('hiring from mercenary sheet updates session state', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: TownMercenaryHireCard(candidateCount: 3, mercenaryCount: 1),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mercenary Hire'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '고용').first);
    await tester.pumpAndSettle();

    expect(session.state.player.gold, 1320);
    expect(session.state.characters.mercenaries, hasLength(2));
    expect(session.state.characters.mercenaries.last.name, 'Apprentice Sellsword');
    expect(session.state.town.mercenaryCandidates, hasLength(2));
  });
}
