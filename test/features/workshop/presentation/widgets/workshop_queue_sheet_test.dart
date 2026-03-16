import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_queue_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workshop queue sheet shows generic queued jobs and claim panel', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        queue: <CraftQueueJob>[
          CraftQueueJob(
            id: 'job_extract',
            type: WorkshopJobType.extraction,
            status: QueueJobStatus.processing,
            queuedAt: DateTime(2026, 1, 1, 10),
            startedAt: DateTime(2026, 1, 1, 10),
            duration: const Duration(seconds: 20),
            eta: const Duration(seconds: 12),
            title: 'Emberroot',
            materialId: 'm_1',
            quantity: 2,
          ),
          CraftQueueJob(
            id: 'job_craft',
            type: WorkshopJobType.craft,
            status: QueueJobStatus.queued,
            queuedAt: DateTime(2026, 1, 1, 10),
            duration: const Duration(seconds: 30),
            eta: const Duration(seconds: 30),
            title: 'Potion 1',
            potionId: 'p_1',
            repeatCount: 2,
          ),
        ],
        pendingClaim: WorkshopPendingClaim(
          arcaneDust: 1,
          potionStacks: const <String, int>{'p_1|a': 1},
        ),
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

    expect(find.text('작업실 보상 수령'), findsOneWidget);
    expect(find.text('통합 수령'), findsOneWidget);
    expect(find.text('Emberroot x2'), findsOneWidget);
    expect(find.text('추출 / 진행 중 / 남은 시간 12s'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Potion 1 x2'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Potion 1 x2'), findsOneWidget);
    expect(find.text('제조 / 대기 중 / 예상 30s'), findsOneWidget);
  });
}
