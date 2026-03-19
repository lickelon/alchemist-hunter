import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_queue_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workshop queue sheet shows queued and completed jobs in one list', (
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
            status: QueueJobStatus.completed,
            queuedAt: DateTime(2026, 1, 1, 10),
            duration: const Duration(seconds: 30),
            eta: Duration.zero,
            title: 'Potion 1',
            potionId: 'p_1',
            repeatCount: 2,
            completedPotionStackKey: 'p_1|a',
            completedPotion: CraftedPotion(
              id: 'cp_1',
              typePotionId: 'p_1',
              qualityGrade: PotionQualityGrade.a,
              qualityScore: 0.84,
              traits: const <String, double>{'t_hp': 0.5, 't_atk': 0.5},
              createdAt: DateTime(2026, 1, 1, 10),
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopQueueCard(
              jobCount: 2,
              description: '진행 Emberroot / 슬롯 2/3 / 포션 1개',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Craft Queue'));
    await tester.pumpAndSettle();

    expect(find.text('Emberroot x2'), findsOneWidget);
    expect(find.text('추출 / 진행 중 / 남은 시간 12s'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Potion 1 x2'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Potion 1 x2'), findsOneWidget);
    expect(find.textContaining('수령 대기'), findsOneWidget);
    expect(find.textContaining('제조 완료'), findsOneWidget);
    expect(find.text('수령'), findsOneWidget);
  });
}
