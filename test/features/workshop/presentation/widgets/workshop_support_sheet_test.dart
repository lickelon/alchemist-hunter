import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_support_card.dart';

void main() {
  testWidgets('workshop support sheet assigns homunculus to extraction slot', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      battle: session.state.battle.copyWith(
        stageAssignments: const <String, List<String>>{
          'stage_1': <String>['merc_1'],
        },
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopSupportCard(
              assignedCount: 0,
              slotLimit: 3,
              summary: '보조 효과 없음',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Workshop Support'));
    await tester.pumpAndSettle();

    expect(find.text('작업실 보조 슬롯'), findsOneWidget);
    expect(find.text('추출 슬롯'), findsOneWidget);
    expect(find.textContaining('현재 비어 있음 / 효과 추출 수율 +5%'), findsOneWidget);

    await tester.tap(find.text('Nigredo Seed').first);
    await tester.pumpAndSettle();

    expect(
      session.state.workshop.supportAssignmentsByFunction,
      const <String, String>{'extraction': 'homo_1'},
    );
    expect(session.state.battle.stageAssignments['stage_1'], <String>['merc_1']);
    expect(
      session.state.workshop.logs.first,
      'Assigned Nigredo Seed to workshop 추출',
    );
  });
}
