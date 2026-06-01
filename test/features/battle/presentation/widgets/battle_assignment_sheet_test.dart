import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_assignment_sheet.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import '../../../../support/catalog_fixtures.dart';

void main() {
  testWidgets('battle assignment sheet toggles character for stage', (
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

    expect(find.text('먼지 회랑 편성'), findsOneWidget);
    expect(find.text('배치 0/3명 / 전투력 0'), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Rookie Swordsman'));
    await tester.pumpAndSettle();

    expect(session.state.battle.stageAssignments['stage_2'], <String>[
      'merc_1',
    ]);
    final int expectedPower = const BattlePartyPowerService().totalPower(
      session.state.characters,
      assignedCharacterIds: const <String>['merc_1'],
    );
    expect(find.text('배치 1/3명 / 전투력 $expectedPower'), findsOneWidget);
  });

  testWidgets('battle assignment sheet stores stage potion loadout', (
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
      workshop: session.state.workshop.copyWith(
        craftedPotionStacks: const <String, int>{'p_1|a': 2},
        craftedPotionDetails: <String, CraftedPotion>{
          'p_1|a': CraftedPotion(
            id: 'cp_1',
            typePotionId: 'p_1',
            qualityGrade: PotionQualityGrade.a,
            qualityScore: 0.84,
            traits: const <String, double>{'t_atk': 0.7, 't_hp': 0.3},
            createdAt: DateTime(2026, 1, 1, 10),
          ),
        },
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

    expect(find.text('포션 로드아웃'), findsOneWidget);
    expect(find.text('활력 포션 A'), findsOneWidget);
    expect(find.text('보유 2 / 선택 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();

    expect(session.state.battle.stagePotionLoadouts['stage_2']?['p_1|a'], 1);
    expect(find.text('보유 2 / 선택 1'), findsOneWidget);
  });
}
