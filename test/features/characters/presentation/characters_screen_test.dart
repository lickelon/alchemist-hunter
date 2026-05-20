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
    final CharacterProgress tierReadyTarget = target.copyWith(
      rank: target.maxRankForCurrentTier,
    );
    final CharacterProgress leveledTarget = tierReadyTarget.copyWith(
      level: tierReadyTarget.maxLevelForRank,
    );
    final BattleCombatStatService statService = const BattleCombatStatService();
    final BattleCombatStats expectedStats = statService.buildStats(
      leveledTarget,
    );
    final int expectedPower = statService.buildHeroProfile(leveledTarget).power;
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
            statModifiers: const <BattleStatModifier>[
              BattleStatModifier(
                type: BattleStatModifierType.accuracy,
                mode: BattleModifierMode.flat,
                value: 0.06,
                sourceId: 'test_accuracy',
              ),
            ],
            modifiers: const <BattleModifier>[
              BattleModifier(
                type: BattleModifierType.damageDealt,
                mode: BattleModifierMode.percent,
                value: 0.05,
                sourceId: 'test_damage',
              ),
            ],
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
    expect(find.text('랭크업'), findsNothing);
    expect(find.text('티어업'), findsNothing);
    expect(find.text('상세'), findsNothing);

    await tester.tap(find.text(target.name));
    await tester.pumpAndSettle();

    expect(find.text('현재 성장'), findsOneWidget);
    expect(find.text('총합 스탯'), findsNothing);
    expect(find.text('전투 스탯'), findsOneWidget);
    expect(
      find.text('전투력 $expectedPower / 직군 ${_disciplineLabel(leveledTarget)}'),
      findsOneWidget,
    );
    expect(find.text('체력'), findsOneWidget);
    expect(find.text('${expectedStats.maxHp}'), findsAtLeastNWidgets(1));
    expect(find.text('마나'), findsNothing);
    expect(find.text('마나재생'), findsNothing);
    expect(find.text('물공'), findsOneWidget);
    expect(
      find.text('${expectedStats.physicalAttack}'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('물방'), findsOneWidget);
    expect(
      find.text('${expectedStats.physicalDefense}'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('다음 목표'), findsNothing);
    expect(find.text('현재 티어 최대 랭크 도달'), findsNothing);
    expect(find.text('티어업 가능'), findsNothing);
    expect(find.text('승급 재료: 용병 승급 재료 2 1/1'), findsNothing);
    expect(find.text('직군 전사 / 전열 기본 전열'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('전투 효과'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('전투 효과'), findsOneWidget);
    expect(find.textContaining('스킬: 방패 강타'), findsOneWidget);
    expect(find.textContaining('마나 소모 ${expectedStats.maxMp}'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('배치 변경은 전투/작업실 화면에서 진행'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

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
    expect(find.textContaining('체력 0 / 물공 12 / 물방 0'), findsOneWidget);
    expect(find.textContaining('마공 0 / 마방 0 / 속도 0'), findsOneWidget);
    expect(find.text('주는 피해 +5%'), findsOneWidget);
    expect(find.text('명중 +6%'), findsNothing);
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
      final BattleCombatStatService statService =
          const BattleCombatStatService();
      final int expectedPower = statService.buildHeroProfile(target).power;
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

      expect(find.text('총합 스탯'), findsNothing);
      expect(find.text('전투 스탯'), findsOneWidget);
      expect(
        find.text('전투력 $expectedPower / 직군 ${_disciplineLabel(target)}'),
        findsOneWidget,
      );
      expect(find.text('출처 Vital Seed Flask'), findsNothing);
      expect(find.text('역할 지원'), findsNothing);
      expect(find.text('보조효과 파티 생존력 보조'), findsNothing);
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
