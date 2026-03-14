import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_extraction_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_material_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_queue_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workshop queue sheet shows blocked state and resume action', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(),
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{
          't_hp': 0.6,
          't_atk': 0.4,
        },
        queue: <CraftQueueJob>[
          const CraftQueueJob(
            id: 'job_1',
            potionId: 'p_1',
            repeatCount: 1,
            retryPolicy: CraftRetryPolicy(maxRetries: 2),
            status: QueueJobStatus.blocked,
            eta: Duration.zero,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: WorkshopQueueCard(jobCount: 1)),
        ),
      ),
    );

    await tester.tap(find.text('Craft Queue'));
    await tester.pumpAndSettle();

    expect(find.text('재개'), findsOneWidget);
    expect(find.text('Potion 1 0/1'), findsOneWidget);
    expect(find.text('상태 진행 불가, 추출 특성 보충 후 재개 가능'), findsOneWidget);
  });

  testWidgets('workshop material sheet shows material name and trait summary', (
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
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopMaterialCard(materialTypeCount: 1, totalCount: 2),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Items'));
    await tester.pumpAndSettle();

    expect(find.text('Emberroot'), findsOneWidget);
    expect(find.text('common / Vital / Swift'), findsOneWidget);
    expect(find.text('x2'), findsOneWidget);
  });

  testWidgets(
    'workshop queue sheet shows clear completed button and missing materials',
    (WidgetTester tester) async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SessionController session = container.read(
        sessionControllerProvider.notifier,
      );
      session.state = session.state.copyWith(
        player: session.state.player.copyWith(
          materialInventory: const <String, int>{'m_1': 1},
        ),
        workshop: session.state.workshop.copyWith(
          extractedTraitInventory: const <String, double>{'t_hp': 0.2},
          queue: <CraftQueueJob>[
            const CraftQueueJob(
              id: 'job_done',
              potionId: 'p_1',
              repeatCount: 1,
              retryPolicy: CraftRetryPolicy(maxRetries: 2),
              status: QueueJobStatus.completed,
              eta: Duration.zero,
              currentRepeat: 1,
            ),
            const CraftQueueJob(
              id: 'job_blocked',
              potionId: 'p_1',
              repeatCount: 1,
              retryPolicy: CraftRetryPolicy(maxRetries: 2),
              status: QueueJobStatus.blocked,
              eta: Duration.zero,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: WorkshopQueueCard(jobCount: 2)),
          ),
        ),
      );

      await tester.tap(find.text('Craft Queue'));
      await tester.pumpAndSettle();

      expect(find.text('완료 정리 (1)'), findsOneWidget);
      expect(find.textContaining('부족 특성:'), findsOneWidget);
      expect(find.text('Potion 1 0/1'), findsOneWidget);
      expect(find.text('Potion 1 1/1'), findsOneWidget);
    },
  );

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
    },
  );
}
