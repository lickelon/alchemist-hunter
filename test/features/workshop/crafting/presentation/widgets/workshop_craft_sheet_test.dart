import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_enqueue_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workshop craft sheet shows potion registration options', (
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
          't_hp': 1.0,
          't_atk': 1.0,
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
    expect(find.widgetWithText(FilledButton, '등록'), findsWidgets);
  });

  testWidgets('workshop craft sheet shows queue-full notice once in header', (
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

    final Iterable<FilledButton> registerButtons = tester
        .widgetList<FilledButton>(find.widgetWithText(FilledButton, '등록'));
    expect(registerButtons, isNotEmpty);
    expect(
      registerButtons.every((FilledButton button) => button.onPressed == null),
      true,
    );
  });

  testWidgets('workshop craft tab opens recipe detail from icon grid', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        essence: 100,
        arcaneDust: 2,
        materialInventory: const <String, int>{
          'm_3': 3,
          'promo_core_mercenary_2': 1,
        },
      ),
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{
          't_atk': 2,
          't_focus': 1,
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
    expect(find.text('소요 시간 45초'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '등록'), findsOneWidget);
  });

  testWidgets('workshop craft sheet shows toast when queue is full', (
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
