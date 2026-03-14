import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_hatch_card.dart';

void main() {
  testWidgets('workshop hatch sheet hatches homunculus from recipe', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        essence: 120,
        arcaneDust: 2,
        materialInventory: const <String, int>{'m_1': 2, 'm_3': 1},
      ),
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{'t_hp': 0.8},
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopHatchCard(recipeCount: 3, homunculusCount: 1),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Homunculus Hatch'));
    await tester.pumpAndSettle();

    expect(find.text('호문쿨루스 부화'), findsOneWidget);
    expect(find.text('Vital Seed Flask'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '부화').first);
    await tester.pumpAndSettle();

    expect(session.state.characters.homunculi, hasLength(2));
    expect(session.state.characters.homunculi.last.name, 'Vital Nigredo');
    expect(session.state.player.essence, 80);
    expect(session.state.workshop.logs.first, 'Hatched Vital Nigredo');
  });
}
