import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const BattleDropTable emptyDropTable = BattleDropTable(
    stageId: 'stage_1',
    normalDrops: <BattleDropEntry>[],
    specialDrops: <BattleDropEntry>[],
  );

  HeroProfile hero({
    required String id,
    required CombatFaction faction,
    required CombatDiscipline discipline,
    required BattleCombatStats stats,
    required int power,
    List<BattleModifier> modifiers = const <BattleModifier>[],
    List<BattlePassiveEffect> passives = const <BattlePassiveEffect>[],
  }) {
    return HeroProfile(
      id: id,
      name: id,
      faction: faction,
      discipline: discipline,
      jobId: '${faction.name}_${discipline.name}',
      stats: stats,
      modifiers: modifiers,
      passives: passives,
      power: power,
    );
  }

  test('battle result uses combat stats even when power is zero', () {
    final BattleService service = BattleService(random: Random(1));

    final BattleResult result = service.runAutoBattle(
      config: AutoBattleConfig(
        party: <HeroProfile>[
          hero(
            id: 'hero_1',
            faction: CombatFaction.mercenary,
            discipline: CombatDiscipline.warrior,
            power: 0,
            stats: const BattleCombatStats(
              maxHp: 180,
              physicalAttack: 32,
              physicalDefense: 18,
              magicalAttack: 8,
              magicalDefense: 12,
              speed: 12,
              critChance: 0.1,
              critDamage: 0.6,
              accuracy: 0.95,
              evasion: 0.08,
              statusAccuracy: 0.05,
              statusResistance: 0.08,
              physicalPenetration: 0.08,
              magicalPenetration: 0.02,
              lifesteal: 0.04,
              healingPower: 0,
              regen: 0.02,
            ),
          ),
        ],
        potionLoadout: const <String, int>{},
        stageId: 'stage_1',
      ),
      stage: const BattleStageDefinition(
        id: 'stage_1',
        name: 'Stage 1',
        recommendedPower: 0,
        cycleDuration: Duration(seconds: 60),
        enemySetId: 'enemy_set_1',
        goldSuccess: 35,
        goldFailurePenalty: 15,
        essenceSuccess: 6,
        essenceFailure: 2,
        xpSuccessBase: 20,
        xpFailureBase: 8,
      ),
      enemies: const <BattleEnemyDefinition>[
        BattleEnemyDefinition(
          id: 'enemy_1',
          name: 'enemy_1',
          faction: CombatFaction.homunculus,
          summary: '기본 적',
          stats: BattleCombatStats(
            maxHp: 36,
            physicalAttack: 7,
            physicalDefense: 5,
            magicalAttack: 2,
            magicalDefense: 3,
            speed: 6,
            critChance: 0.03,
            critDamage: 0.4,
            accuracy: 0.8,
            evasion: 0.02,
            statusAccuracy: 0.01,
            statusResistance: 0.02,
            physicalPenetration: 0.01,
            magicalPenetration: 0,
            lifesteal: 0,
            healingPower: 0,
            regen: 0,
          ),
        ),
      ],
      dropTable: emptyDropTable,
    );

    expect(result.success, isTrue);
    expect(result.failurePenalty, 0);
    expect(result.turns, greaterThan(0));
    expect(result.actions, isNotEmpty);
    expect(
      result.actions.any(
        (BattleActionLog action) => action.type == BattleActionType.attack,
      ),
      isTrue,
    );
  });

  test('battle result no longer uses high power alone to force victory', () {
    final BattleService service = BattleService(random: Random(1));

    final BattleResult result = service.runAutoBattle(
      config: AutoBattleConfig(
        party: <HeroProfile>[
          hero(
            id: 'hero_weak',
            faction: CombatFaction.mercenary,
            discipline: CombatDiscipline.warrior,
            power: 999,
            stats: const BattleCombatStats(
              maxHp: 24,
              physicalAttack: 3,
              physicalDefense: 2,
              magicalAttack: 1,
              magicalDefense: 1,
              speed: 4,
              critChance: 0,
              critDamage: 0.5,
              accuracy: 0.7,
              evasion: 0.01,
              statusAccuracy: 0,
              statusResistance: 0,
              physicalPenetration: 0,
              magicalPenetration: 0,
              lifesteal: 0,
              healingPower: 0,
              regen: 0,
            ),
          ),
        ],
        potionLoadout: const <String, int>{},
        stageId: 'stage_5',
      ),
      stage: const BattleStageDefinition(
        id: 'stage_5',
        name: 'Stage 5',
        recommendedPower: 0,
        cycleDuration: Duration(seconds: 60),
        enemySetId: 'enemy_set_5',
        goldSuccess: 35,
        goldFailurePenalty: 15,
        essenceSuccess: 6,
        essenceFailure: 2,
        xpSuccessBase: 36,
        xpFailureBase: 16,
      ),
      enemies: const <BattleEnemyDefinition>[
        BattleEnemyDefinition(
          id: 'enemy_boss',
          name: 'enemy_boss',
          faction: CombatFaction.homunculus,
          summary: '보스 적',
          stats: BattleCombatStats(
            maxHp: 70,
            physicalAttack: 18,
            physicalDefense: 10,
            magicalAttack: 6,
            magicalDefense: 8,
            speed: 12,
            critChance: 0.08,
            critDamage: 0.5,
            accuracy: 0.92,
            evasion: 0.05,
            statusAccuracy: 0.03,
            statusResistance: 0.04,
            physicalPenetration: 0.04,
            magicalPenetration: 0.01,
            lifesteal: 0,
            healingPower: 0,
            regen: 0.01,
          ),
          modifiers: <BattleModifier>[
            BattleModifier(
              type: BattleModifierType.damageDealt,
              mode: BattleModifierMode.percent,
              value: 0.15,
              sourceId: 'rage',
            ),
          ],
          passives: <BattlePassiveEffect>[
            BattlePassiveEffect(
              trigger: BattlePassiveTrigger.afterAction,
              type: BattlePassiveEffectType.extraAttack,
              sourceId: 'double_strike',
              value: 1,
            ),
          ],
        ),
      ],
      dropTable: emptyDropTable,
    );

    expect(result.success, isFalse);
    expect(result.failurePenalty, 15);
    expect(result.actions, isNotEmpty);
  });
}
