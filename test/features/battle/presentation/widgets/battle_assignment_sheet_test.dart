import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_assignment_sheet.dart';

void main() {
  testWidgets('battle assignment sheet toggles character for stage', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      battle: session.state.battle.copyWith(
        stageAssignments: const <String, List<String>>{},
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: BattleAssignmentSheet(stageId: 'stage_2')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stage 2 편성'), findsOneWidget);
    expect(find.text('배치 0/3명 / 전투력 0'), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Rookie Swordsman'));
    await tester.pumpAndSettle();

    expect(session.state.battle.stageAssignments['stage_2'], <String>['merc_1']);
    expect(find.text('배치 1/3명 / 전투력 120'), findsOneWidget);
  });
}
