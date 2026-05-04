import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_combat_stat_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/screens/characters_screen.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('character screen shows rank and tier unlock hints', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    final CharacterProgress target = session.state.characters.mercenaries.first;
    final CharacterProgress leveledTarget = target.copyWith(
      rank: target.maxRankForCurrentTier,
      level: target.maxLevelForRank,
    );
    final BattleCombatStats expectedStats = const BattleCombatStatService()
        .buildStats(leveledTarget);
    final int expectedPower = const BattleCombatStatService()
        .summaryPowerForStats(expectedStats);
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'tier_mat_mercenary_2': 1},
      ),
      town: session.state.town.copyWith(
        equipmentInventory: <EquipmentInstance>[
          EquipmentInstance(
            id: 'eq_instance_1',
            blueprintId: 'eq_1',
            name: 'Bronze Sword',
            slot: EquipmentSlot.weapon,
            attack: 12,
            defense: 0,
            health: 0,
            createdAt: DateTime(2026, 1, 1, 10),
          ),
        ],
      ),
      characters: session.state.characters.copyWith(
        mercenaries: <CharacterProgress>[leveledTarget],
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: CharactersScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('배치 상태: Stage 1'), findsAtLeastNWidgets(1));
    expect(find.text('Rank Up'), findsNothing);
    expect(find.text('Tier Up'), findsNothing);
    expect(find.text('상세'), findsNothing);

    await tester.tap(find.text(target.name));
    await tester.pumpAndSettle();

    expect(find.text('현재 성장'), findsOneWidget);
    expect(find.text('총합 스탯'), findsOneWidget);
    expect(find.text('ATK 0 / DEF 0 / HP 0'), findsOneWidget);
    expect(find.text('전투 스탯'), findsOneWidget);
    expect(
      find.text(
        '전투력 $expectedPower / 전투 직군 ${_disciplineLabel(leveledTarget)}',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'HP ${expectedStats.maxHp} / 물공 ${expectedStats.physicalAttack} / 물방 ${expectedStats.physicalDefense}',
      ),
      findsOneWidget,
    );
    expect(find.text('다음 목표'), findsOneWidget);
    expect(find.text('현재 티어 최대 랭크 도달'), findsOneWidget);
    expect(find.text('티어업 가능'), findsOneWidget);
    expect(find.text('승급 재료: tier_mat_mercenary_2 1/1'), findsOneWidget);
    expect(find.text('배치 변경은 전투/작업실 화면에서 진행'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('무기: 미장착'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('무기: 미장착'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '장착').first);
    await tester.pumpAndSettle();

    expect(find.text('Bronze Sword'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '장착').last);
    await tester.pumpAndSettle();

    expect(find.text('무기: Bronze Sword'), findsOneWidget);
    expect(find.text('ATK 12 / DEF 0 / HP 0'), findsOneWidget);
  });

  testWidgets(
    'character screen shows homunculus origin role and support details',
    (WidgetTester tester) async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SessionController session = container.read(
        sessionControllerProvider.notifier,
      );
      final CharacterProgress target = session.state.characters.homunculi.first;
      final BattleCombatStats expectedStats = const BattleCombatStatService()
          .buildStats(target);
      final int expectedPower = const BattleCombatStatService()
          .summaryPowerForStats(expectedStats);
      session.state = session.state.copyWith(
        characters: session.state.characters.copyWith(
          homunculi: <CharacterProgress>[
            target.copyWith(
              name: 'Vital Nigredo',
              homunculusOrigin: 'Vital Seed Flask',
              homunculusRole: '지원',
              homunculusSupportEffect: '파티 생존력 보조',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: CharactersScreen())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vital Nigredo'), findsOneWidget);
      expect(find.text('배치 상태: Stage 1'), findsAtLeastNWidgets(1));
      expect(find.text('지원 / 파티 생존력 보조'), findsNothing);

      await tester.tap(find.text('Vital Nigredo'));
      await tester.pumpAndSettle();

      expect(find.text('총합 스탯'), findsOneWidget);
      expect(find.text('ATK 0 / DEF 0 / HP 0'), findsOneWidget);
      expect(find.text('전투 스탯'), findsOneWidget);
      expect(
        find.text('전투력 $expectedPower / 전투 직군 ${_disciplineLabel(target)}'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('출처 Vital Seed Flask'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      expect(find.text('출처 Vital Seed Flask'), findsOneWidget);
      expect(find.text('역할 지원'), findsOneWidget);
      expect(find.text('보조효과 파티 생존력 보조'), findsOneWidget);
    },
  );
}

String _disciplineLabel(CharacterProgress character) {
  return switch (const BattleCombatStatService().disciplineFor(
    character.resolvedCombatJobId,
  )) {
    CombatDiscipline.warrior => '전사',
    CombatDiscipline.mage => '마법사',
    CombatDiscipline.rogue => '도적',
    CombatDiscipline.archer => '궁수',
  };
}
