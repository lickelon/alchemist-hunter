import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/presentation/widgets/workshop_hatch_card.dart';
import '../../../../../support/catalog_fixtures.dart';

void main() {
  testWidgets('workshop hatch sheet enqueues homunculus hatch job', (
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
        essence: 120,
        arcaneDust: 2,
        materialInventory: const <String, int>{'m_1': 2, 'm_3': 1},
      ),
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{'t_hp': 0.8},
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: WorkshopHatchCard(recipeCount: 3)),
        ),
      ),
    );

    await tester.tap(find.text('호문쿨루스'));
    await tester.pumpAndSettle();

    expect(find.text('호문쿨루스 부화'), findsOneWidget);
    expect(find.text('Nigredo 마법사'), findsOneWidget);
    expect(find.text('지원'), findsNothing);

    await tester.tap(find.text('Nigredo 마법사'));
    await tester.pumpAndSettle();

    expect(find.text('재료'), findsOneWidget);
    await tester.tap(find.text('닫기').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '등록').first);
    await tester.pumpAndSettle();

    expect(session.state.characters.homunculi, hasLength(1));
    expect(session.state.workshop.queue, hasLength(1));
    expect(session.state.workshop.queue.first.type, WorkshopJobType.hatch);
    expect(session.state.workshop.queue.first.completedHomunculus?.name, '마법사');
    expect(session.state.player.essence, 80);
    expect(session.state.workshop.logs.first, '부화 등록 / Nigredo 마법사');
  });

  testWidgets('workshop hatch sheet shows toast when queue is full', (
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
        essence: 120,
        arcaneDust: 2,
        materialInventory: const <String, int>{'m_1': 2, 'm_3': 1},
      ),
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{'t_hp': 0.8},
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
          home: Scaffold(body: WorkshopHatchCard(recipeCount: 3)),
        ),
      ),
    );

    await tester.tap(find.text('호문쿨루스'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '등록').first);
    await tester.pump();

    expect(find.text('작업실 큐가 가득 찼습니다'), findsOneWidget);
    expect(find.text('호문쿨루스 부화'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2000));
  });
}
