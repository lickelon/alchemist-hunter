import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_craft_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_enqueue_options_sheet.dart';
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
              description: '즉시 제작 가능 1종 / 해금 포션 10종',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Craft'));
    await tester.pumpAndSettle();

    expect(find.text('포션 제조'), findsOneWidget);
    expect(find.text('Potion 1'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '등록'), findsWidgets);
  });

  testWidgets('workshop craft sheet shows snackbar when queue is full', (
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
            body: WorkshopEnqueueOptionsSheet(
              potionId: 'p_1',
              title: 'Potion 1',
              maxCraftableCount: 1,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, '등록').first);
    await tester.pump();

    expect(find.text('작업실 큐가 가득 찼습니다'), findsOneWidget);
    expect(find.text('Potion 1'), findsWidgets);
  });
}
