import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/town_skill_tree_card.dart';

void main() {
  testWidgets('town skill tree sheet upgrades root node', (
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
            body: TownSkillTreeCard(unlockedCount: 1, totalCount: 3),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Town Skill Tree'));
    await tester.pumpAndSettle();

    expect(find.text('마을 스킬트리'), findsOneWidget);
    expect(find.textContaining('Trade Ledger'), findsOneWidget);
    expect(find.textContaining('현재 효과 효과 없음'), findsWidgets);
    expect(find.textContaining('다음 효과 포션 판매가 +5%'), findsOneWidget);
    expect(find.textContaining('↳ Hiring Board'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '강화').first);
    await tester.pumpAndSettle();

    expect(session.state.player.townInsight, 1);
    expect(session.state.town.skillTree.nodeLevels['town_trade_ledger'], 1);
    expect(find.textContaining('Lv 1/2'), findsOneWidget);
  });
}
