import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
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
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 1, 'm_2': 1},
      ),
      workshop: session.state.workshop.copyWith(
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
    expect(find.text('상태 진행 불가, 재료 보충 후 재개 가능'), findsOneWidget);
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
          home: Scaffold(body: WorkshopMaterialCard(materialTypeCount: 1, totalCount: 2)),
        ),
      ),
    );

    await tester.tap(find.text('Items'));
    await tester.pumpAndSettle();

    expect(find.text('Material 1'), findsOneWidget);
    expect(find.text('common / Vital / Swift'), findsOneWidget);
    expect(find.text('x2'), findsOneWidget);
  });
}
