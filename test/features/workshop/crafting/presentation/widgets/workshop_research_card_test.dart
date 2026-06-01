import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_research_card.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('brew experiment resolves immediately without queue reward', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{
          't_crit': 1.0,
          't_focus': 1.0,
        },
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: WorkshopResearchCard(traitTypeCount: 2)),
        ),
      ),
    );

    await tester.tap(find.text('연구'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('brew_experiment_trait_t_crit')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('brew_experiment_trait_t_focus')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('brew_experiment_submit_button')),
    );
    await tester.pumpAndSettle();

    expect(session.state.workshop.queue, isEmpty);
    expect(session.state.workshop.craftedPotionStacks, isEmpty);
    expect(session.state.workshop.discoveredPotionRecipes['p_3'], isNotNull);
    expect(
      session.state.workshop.discoveredPotionRecipes['p_3']?.bestKnownGrade,
      PotionQualityGrade.s,
    );
    expect(find.text('투지 포션'), findsOneWidget);
    expect(find.text('품질 S'), findsOneWidget);
    expect(find.text('레시피 신규 발견'), findsOneWidget);
  });
}
