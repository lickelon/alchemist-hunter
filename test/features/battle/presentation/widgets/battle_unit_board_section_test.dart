import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_unit_board_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'battle unit board shows resource bars shield and active effects',
    (WidgetTester tester) async {
      const BattleRunUnitState unit = BattleRunUnitState(
        unitId: 'enemy_weaver',
        name: 'Bloom Weaver',
        team: BattleTeam.enemy,
        faction: CombatFaction.homunculus,
        stats: BattleCombatStats(
          maxHp: 100,
          maxMp: 10,
          physicalAttack: 8,
          physicalDefense: 6,
          magicalAttack: 14,
          magicalDefense: 10,
          speed: 11,
          critChance: 0,
          critDamage: 0.5,
          accuracy: 1,
          evasion: 0,
          statusAccuracy: 0,
          statusResistance: 0,
          physicalPenetration: 0,
          magicalPenetration: 0,
          lifesteal: 0,
          healingPower: 0,
          regen: 0,
          mpRegen: 3,
        ),
        activeModifiers: <BattleTimedModifier>[
          BattleTimedModifier(
            modifier: BattleModifier(
              type: BattleModifierType.damageTaken,
              mode: BattleModifierMode.percent,
              value: 0.12,
              sourceId: 'test_expose',
            ),
            remainingLifecycles: 1,
          ),
        ],
        statuses: <BattleStatusEffect>[
          BattleStatusEffect(
            type: BattleStatusType.poison,
            sourceId: 'test_poison',
            remainingLifecycles: 2,
            power: 6,
          ),
        ],
        shield: 18,
        currentHp: 64,
        currentMp: 4,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BattleUnitBoardSection(
              units: <BattleRunUnitState>[unit],
              enemy: true,
            ),
          ),
        ),
      );

      expect(find.text('Bloom Weaver'), findsOneWidget);
      expect(find.text('체력'), findsNothing);
      expect(find.text('마나'), findsNothing);
      expect(find.text('HP 64 / 100'), findsNothing);
      expect(find.text('마나 4 / 10'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
      final List<LinearProgressIndicator> bars = tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .toList(growable: false);
      expect(bars[0].color, Colors.redAccent);
      expect(bars[1].color, Colors.blueAccent);
      expect(find.text('보호막 18'), findsOneWidget);
      expect(find.text('중독 6 / 2행동'), findsOneWidget);
      expect(find.text('받는 피해 +12% / 1행동'), findsOneWidget);
    },
  );
}
