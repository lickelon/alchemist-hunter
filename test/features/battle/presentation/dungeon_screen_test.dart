import 'package:alchemist_hunter/features/battle/presentation/screens/dungeon_screen.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dungeon screen shows locked reason for later stages', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    final CharacterProgress merc = session.state.characters.mercenaries.first;
    session.state = session.state.copyWith(
      characters: session.state.characters.copyWith(
        mercenaries: <CharacterProgress>[
          merc.copyWith(
            equipment: CharacterEquipmentLoadout(
              weapon: EquipmentInstance(
                id: 'eq_instance_1',
                blueprintId: 'eq_1',
                name: 'Bronze Sword',
                slot: EquipmentSlot.weapon,
                attack: 12,
                defense: 0,
                health: 0,
                createdAt: DateTime(2026, 1, 1, 10),
              ),
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DungeonScreen())),
      ),
    );
    await tester.pumpAndSettle();

    final int expectedPower = const BattlePartyPowerService().totalPower(
      session.state.characters,
      assignedCharacterIds: session.state.battle.stageAssignments['stage_1'],
    );

    expect(find.text('2단계'), findsOneWidget);
    expect(find.textContaining('편성 2명 / 전투력 $expectedPower'), findsOneWidget);
    expect(find.textContaining('잠금 조건: 1단계 클리어 필요'), findsOneWidget);
    expect(find.text('잠김'), findsWidgets);
    expect(find.text('편성'), findsWidgets);

    await tester.tap(find.text('1단계'));
    await tester.pumpAndSettle();

    expect(find.text('1단계 전투 현황'), findsOneWidget);
    expect(find.text('현재 상태'), findsOneWidget);
    expect(find.text('대기'), findsOneWidget);
    expect(find.text('적 구성 / 드롭'), findsOneWidget);

    await tester.tap(find.text('적 구성 / 드롭'));
    await tester.pumpAndSettle();

    expect(find.text('1단계 적 정보'), findsOneWidget);
    expect(find.text('Ruin Scavenger'), findsWidgets);
    expect(find.text('전투 스탯'), findsNothing);

    await tester.tap(find.text('Ruin Scavenger').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Emberroot'), findsOneWidget);
    expect(find.text('전투 스탯'), findsWidgets);
    expect(find.textContaining('물방 9'), findsOneWidget);
    expect(find.textContaining('받는 피해 -5%'), findsOneWidget);

    Navigator.of(tester.element(find.text('1단계 적 정보'))).pop();
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.text('1단계 전투 현황'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('편성').first);
    await tester.pumpAndSettle();

    expect(find.text('1단계 편성'), findsOneWidget);
    expect(find.text('배치 2/3명 / 전투력 $expectedPower'), findsOneWidget);
  });

  testWidgets('dungeon screen opens recent battle result sheet', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );

    session.state = session.state.copyWith(
      battle: session.state.battle.copyWith(
        stageExpeditions: <String, BattleExpeditionState>{
          'stage_1': BattleExpeditionState(
            status: BattleExpeditionStatus.idle,
            lastProgressedAt: DateTime(2026, 1, 1, 10, 13, 42),
            phaseProgress: Duration.zero,
            recentLogs: <BattleLogEntry>[
              BattleLogEntry(
                resolvedAt: DateTime(2026, 1, 1, 10, 13, 42),
                success: true,
                gold: 35,
                essence: 6,
                materials: const <String, int>{'m_1': 2},
                turns: 4,
                usedLoadoutFallback: true,
                actions: const <BattleActionLog>[
                  BattleActionLog(
                    lifecycle: 1,
                    turn: 1,
                    type: BattleActionType.attack,
                    actorId: 'merc_1',
                    actorName: 'Rookie Swordsman',
                    actorTeam: BattleTeam.ally,
                    targetId: 'enemy_scavenger',
                    targetName: 'Ruin Scavenger',
                    targetTeam: BattleTeam.enemy,
                    school: DamageSchool.physical,
                    hit: true,
                    critical: false,
                    damage: 12,
                    actorHpAfter: 52,
                    targetHpAfter: 20,
                  ),
                ],
              ),
            ],
          ),
        },
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DungeonScreen())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('1단계'));
    await tester.pumpAndSettle();

    expect(find.textContaining('포션 미적용'), findsWidgets);

    await tester.tap(find.text('최근 결과').last);
    await tester.pumpAndSettle();

    expect(find.text('1단계 전투 기록'), findsOneWidget);
    expect(find.text('포션 재고 부족으로 로드아웃이 적용되지 않았습니다.'), findsOneWidget);
    expect(find.textContaining('획득 재료: Emberroot x2'), findsOneWidget);
    expect(
      find.textContaining('Rookie Swordsman -> Ruin Scavenger 물리 12'),
      findsOneWidget,
    );
  });
}
