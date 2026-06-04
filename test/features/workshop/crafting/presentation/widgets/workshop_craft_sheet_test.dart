import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_enqueue_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../support/catalog_fixtures.dart';

void main() {
  testWidgets('workshop craft sheet shows potion registration options', (
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
            bestKnownGrade: PotionQualityGrade.a,
          ),
        },
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopCraftCard(
              brewCraftableCount: 1,
              materialCraftableCount: 0,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('연금술'));
    await tester.pumpAndSettle();

    expect(find.text('양조'), findsOneWidget);
    expect(find.text('제작'), findsWidgets);
    expect(
      find.byKey(const ValueKey<String>('brew_recipe_p_1')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey<String>('brew_recipe_p_1')));
    await tester.pumpAndSettle();

    expect(find.text('활력 포션'), findsWidgets);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('최고 등급 A'), findsNothing);
    expect(find.text('발견 비율'), findsOneWidget);
    expect(find.textContaining('메인 Vital 60 / 서브 Aggro 40'), findsOneWidget);
  });

  testWidgets('workshop craft sheet shows queue-full notice once in header', (
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
            bestKnownGrade: PotionQualityGrade.a,
          ),
        },
        queue: List<CraftQueueJob>.generate(
          4,
          (int index) => CraftQueueJob(
            id: 'job_$index',
            type: WorkshopJobType.craft,
            status: QueueJobStatus.queued,
            queuedAt: DateTime(2026, 1, 1, 10),
            duration: const Duration(seconds: 15),
            eta: const Duration(seconds: 15),
            title: '활력 포션',
            potionId: 'p_1',
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopCraftCard(
              brewCraftableCount: 0,
              materialCraftableCount: 0,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('연금술'));
    await tester.pumpAndSettle();

    expect(find.text('작업실 큐 가득 참 (4/4)'), findsOneWidget);
    expect(find.text('큐 가득 참 (4/4)'), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('brew_recipe_p_1')));
    await tester.pumpAndSettle();

    expect(find.text('활력 포션'), findsWidgets);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('최고 등급 A'), findsNothing);
  });

  testWidgets('workshop recipe book registers repeated brew', (
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
          't_hp': 1.2,
          't_atk': 0.8,
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
          home: Scaffold(
            body: WorkshopCraftCard(
              brewCraftableCount: 2,
              materialCraftableCount: 0,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('연금술'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('brew_recipe_p_1')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider).last, const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '등록'));
    await tester.pump();

    expect(session.state.workshop.queue, hasLength(1));
    expect(session.state.workshop.queue.single.potionId, 'p_1');
    expect(session.state.workshop.queue.single.repeatCount, 2);
    expect(session.state.workshop.extractedTraitInventory, isEmpty);
  });

  testWidgets('workshop craft tab opens recipe detail from icon grid', (
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
      player: session.state.player.copyWith(
        essence: 100,
        arcaneDust: 2,
        materialInventory: const <String, int>{
          'm_3': 6,
          'promo_core_mercenary_2': 2,
        },
      ),
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{
          't_atk': 4,
          't_focus': 2,
        },
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopCraftCard(
              brewCraftableCount: 0,
              materialCraftableCount: 1,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('연금술'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('제작').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey<String>('craft_recipe_craft_tier_mat_mercenary_2'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('용병 승급 재료 2'), findsWidgets);
    expect(find.text('최대 2개'), findsOneWidget);
    expect(find.text('6/3'), findsOneWidget);
    expect(find.text('시간 45초'), findsOneWidget);
    expect(find.text('소요 시간 1회 45초 / 총 45초'), findsNothing);
    expect(find.widgetWithText(FilledButton, '등록'), findsOneWidget);
  });

  testWidgets('workshop craft sheet shows toast when queue is full', (
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
        queue: List<CraftQueueJob>.generate(
          4,
          (int index) => CraftQueueJob(
            id: 'job_$index',
            type: WorkshopJobType.craft,
            status: QueueJobStatus.queued,
            queuedAt: DateTime(2026, 1, 1, 10),
            duration: const Duration(seconds: 15),
            eta: const Duration(seconds: 15),
            title: '활력 포션',
            potionId: 'p_1',
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopEnqueueOptionsDialog(
              potionId: 'p_1',
              title: '활력 포션',
              maxCraftableCount: 1,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, '등록').first);
    await tester.pump();

    expect(find.text('작업실 큐가 가득 찼습니다'), findsOneWidget);
    expect(find.text('활력 포션'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 2000));
  });
}
