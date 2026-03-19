import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_extraction_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_inventory_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workshop inventory sheet shows materials traits and potions', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 2},
      ),
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{'t_hp': 0.85},
        craftedPotionStacks: const <String, int>{'p_1|a': 1},
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopInventoryCard(
              description: '재료 1종 / 특성 1종 / 포션 1스택',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();

    expect(find.text('작업실 인벤토리'), findsOneWidget);
    expect(find.text('Emberroot'), findsOneWidget);
    expect(find.text('common / Vital / Swift'), findsOneWidget);
    expect(find.text('x2'), findsOneWidget);

    await tester.tap(find.text('특성'));
    await tester.pumpAndSettle();

    expect(find.text('Vital'), findsOneWidget);
    expect(find.text('0.85'), findsOneWidget);

    await tester.tap(find.text('포션'));
    await tester.pumpAndSettle();

    expect(find.text('p_1|a x1'), findsOneWidget);
  });

  testWidgets(
    'workshop extraction sheet shows trait stock and extraction actions',
    (WidgetTester tester) async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SessionController session = container.read(
        sessionControllerProvider.notifier,
      );
      session.state = session.state.copyWith(
        player: session.state.player.copyWith(
          materialInventory: const <String, int>{'m_1': 2},
        ),
        workshop: session.state.workshop.copyWith(
          extractedTraitInventory: const <String, double>{'t_hp': 0.85},
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: WorkshopExtractionCard(
                materialTypeCount: 1,
                extractedTraitTypeCount: 1,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Extraction'));
      await tester.pumpAndSettle();

      expect(find.text('보유 추출 특성'), findsOneWidget);
      expect(find.textContaining('Vital 0.85'), findsOneWidget);
      expect(find.text('분석/추출'), findsOneWidget);

      await tester.tap(find.text('분석/추출'));
      await tester.pumpAndSettle();

      expect(find.text('보유 2개'), findsOneWidget);
      expect(find.text('추출 수량'), findsOneWidget);
      expect(find.text('최대'), findsOneWidget);
    },
  );

  testWidgets(
    'workshop extraction detail shows snackbar when queue is full',
    (WidgetTester tester) async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SessionController session = container.read(
        sessionControllerProvider.notifier,
      );
      session.state = session.state.copyWith(
        player: session.state.player.copyWith(
          materialInventory: const <String, int>{'m_1': 2},
        ),
        workshop: session.state.workshop.copyWith(
          queue: List<CraftQueueJob>.generate(
            4,
            (int index) => CraftQueueJob(
              id: 'job_$index',
              type: WorkshopJobType.craft,
              status: QueueJobStatus.queued,
              queuedAt: DateTime(2026, 1, 1, 10),
              duration: const Duration(seconds: 15),
              eta: const Duration(seconds: 15),
              title: 'Potion 1',
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
              body: WorkshopExtractionCard(
                materialTypeCount: 1,
                extractedTraitTypeCount: 0,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Extraction'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('분석/추출'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('등록').first);
      await tester.pump();

      expect(find.text('작업실 큐가 가득 찼습니다'), findsOneWidget);
      expect(find.text('보유 2개'), findsOneWidget);
    },
  );
}
