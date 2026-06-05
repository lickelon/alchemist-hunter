import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_research_card.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../support/catalog_fixtures.dart';

void main() {
  testWidgets('brew experiment resolves immediately without queue reward', (
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
    expect(find.text('S'), findsOneWidget);
    expect(find.text('100점'), findsOneWidget);
    expect(find.text('레시피 신규 발견'), findsOneWidget);
  });

  testWidgets('known brew experiment can pin current ratio', (
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
        extractedTraitInventory: const <String, double>{
          't_hp': 1.0,
          't_atk': 1.0,
        },
        discoveredPotionRecipes: const <String, DiscoveredPotionRecipe>{
          'p_1': DiscoveredPotionRecipe(
            potionId: 'p_1',
            discoveredTraits: <String, double>{'t_hp': 0.6, 't_atk': 0.4},
            bestKnownGrade: PotionQualityGrade.s,
          ),
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
      find.byKey(const ValueKey<String>('brew_experiment_trait_t_hp')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('brew_experiment_trait_t_atk')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('brew_experiment_submit_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('이 비율로 레시피 고정'), findsOneWidget);

    await tester.tap(find.text('이 비율로 레시피 고정'));
    await tester.pumpAndSettle();

    final DiscoveredPotionRecipe recipe =
        session.state.workshop.discoveredPotionRecipes['p_1']!;
    expect(recipe.bestKnownGrade, PotionQualityGrade.a);
    expect(recipe.discoveredTraits['t_hp'], closeTo(0.55, 0.0001));
    expect(recipe.discoveredTraits['t_atk'], closeTo(0.45, 0.0001));
    expect(find.text('레시피 비율을 고정했습니다'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2000));
  });
}
