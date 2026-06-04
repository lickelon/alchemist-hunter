import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/presentation/widgets/workshop_skill_tree_card.dart';
import '../../../../../support/catalog_fixtures.dart';

void main() {
  testWidgets('workshop skill tree sheet upgrades root node', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: testCatalogProviderOverrides(),
    );
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

    await tester.tap(find.text('스킬트리'));
    await tester.pumpAndSettle();

    expect(find.text('작업실 스킬트리'), findsOneWidget);
    expect(find.text('Alembic Array'), findsOneWidget);
    expect(find.text('레벨 0/2'), findsWidgets);
    expect(find.text('강화 가능'), findsOneWidget);
    expect(find.textContaining('Queue Matrix'), findsOneWidget);

    await tester.tap(find.text('Alembic Array'));
    await tester.pumpAndSettle();

    expect(find.text('현재 효과 없음'), findsOneWidget);
    expect(find.text('다음 추출 수율 +8%'), findsOneWidget);
    expect(find.textContaining('루트 노드'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '강화').first);
    await tester.pumpAndSettle();

    expect(session.state.player.arcaneDust, 1);
    expect(session.state.workshop.skillTree.nodeLevels['workshop_alembic'], 1);
    expect(find.textContaining('레벨 1/2'), findsWidgets);
  });
}
