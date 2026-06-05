import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/widgets/workshop_support_card.dart';
import '../../../../../support/catalog_fixtures.dart';

void main() {
  testWidgets('workshop support sheet assigns homunculus to extraction slot', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: testCatalogProviderOverrides(),
    );
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    final SessionState seededState = createTestInitialSessionState(
      DateTime(2026, 1, 1, 10),
    );
    session.state = seededState.copyWith(
      battle: seededState.battle.copyWith(
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
            body: WorkshopSupportCard(assignedCount: 0, slotLimit: 3),
          ),
        ),
      ),
    );

    await tester.tap(find.text('작업실 지원'));
    await tester.pumpAndSettle();

    expect(find.text('작업실 보조 슬롯'), findsOneWidget);
    expect(find.text('추출 슬롯'), findsOneWidget);
    expect(find.text('비어 있음'), findsWidgets);
    expect(find.text('추출 수율 +5%'), findsWidgets);

    await tester.tap(find.byTooltip('상세').first);
    await tester.pumpAndSettle();

    expect(find.text('보조 효과는 배치 슬롯에 따라 적용'), findsOneWidget);
    await tester.tap(find.text('닫기').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nigredo 마법사').first);
    await tester.pumpAndSettle();

    expect(
      session.state.workshop.supportAssignmentsByFunction,
      const <String, String>{'extraction': 'homo_1'},
    );
    expect(session.state.battle.stageAssignments['stage_1'], <String>[
      'merc_1',
    ]);
    expect(session.state.workshop.logs.first, 'Nigredo 마법사 / 작업실 추출 배치');
  });
}
