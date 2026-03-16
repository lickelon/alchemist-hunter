import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_skill_tree_card.dart';

void main() {
  testWidgets('workshop skill tree sheet upgrades root node', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopSkillTreeCard(unlockedCount: 1, totalCount: 3),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Workshop Skill Tree'));
    await tester.pumpAndSettle();

    expect(find.text('작업실 스킬트리'), findsOneWidget);
    expect(find.textContaining('Alembic Array'), findsOneWidget);
    expect(find.textContaining('현재 효과 효과 없음'), findsWidgets);
    expect(find.textContaining('다음 효과 추출 수율 +8%'), findsOneWidget);
    expect(find.textContaining('↳ Queue Matrix'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '강화').first);
    await tester.pumpAndSettle();

    expect(session.state.player.arcaneDust, 1);
    expect(session.state.workshop.skillTree.nodeLevels['workshop_alembic'], 1);
    expect(find.textContaining('Lv 1/2'), findsOneWidget);
  });
}
