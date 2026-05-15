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
    List<BattleSkillDefinition> skills = const <BattleSkillDefinition>[],
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
      skills: skills,
      power: power,
    );
  }

  BattleCombatStats stats({
    required int maxHp,
    required int speed,
    int maxMp = 0,
    int mpRegen = 0,
    int physicalAttack = 1,
    int physicalDefense = 50,
    double accuracy = 1,
    double evasion = 0,
  }) {
    return BattleCombatStats(
      maxHp: maxHp,
      maxMp: maxMp,
      physicalAttack: physicalAttack,
      physicalDefense: physicalDefense,
      magicalAttack: 0,
      magicalDefense: physicalDefense,
      speed: speed,
      critChance: 0,
      critDamage: 0.5,
      accuracy: accuracy,
      evasion: evasion,
      statusAccuracy: 0,
      statusResistance: 0,
      physicalPenetration: 0,
      magicalPenetration: 0,
      lifesteal: 0,
      healingPower: 0,
      regen: 0,
      mpRegen: mpRegen,
    );
  }

  BattleRunUnitState unit({
    required String id,
    required BattleTeam team,
    required int speed,
    int maxMp = 0,
    int currentMp = 0,
    int mpRegen = 0,
    double accuracy = 1,
    double evasion = 0,
    int physicalAttack = 1,
    List<BattlePassiveEffect> passives = const <BattlePassiveEffect>[],
    List<BattleSkillDefinition> skills = const <BattleSkillDefinition>[],
  }) {
    return BattleRunUnitState(
      unitId: id,
      name: id,
      team: team,
      faction: CombatFaction.homunculus,
      stats: stats(
        maxHp: 200,
        maxMp: maxMp,
        mpRegen: mpRegen,
        speed: speed,
        physicalAttack: physicalAttack,
        accuracy: accuracy,
        evasion: evasion,
      ),
      passives: passives,
      skills: skills,
      currentHp: 200,
      currentMp: currentMp,
    );
  }

  test('run unit state carries mp and skills from hero profile', () {
    final BattleService service = BattleService(random: Random(1));
    const BattleSkillDefinition skill = BattleSkillDefinition(
      id: 'skill_firebolt',
      name: 'Firebolt',
      summary: '단일 마법 피해',
      cooldownLifecycles: 2,
      targetType: BattleSkillTargetType.randomEnemy,
      effectType: BattleSkillEffectType.damage,
      school: DamageSchool.magical,
      powerMultiplier: 1.4,
    );

    final List<BattleRunUnitState> allies = service.createRunAllies(
      party: <HeroProfile>[
        hero(
          id: 'hero_1',
          faction: CombatFaction.mercenary,
          discipline: CombatDiscipline.mage,
          stats: stats(maxHp: 100, maxMp: 40, speed: 10),
          skills: const <BattleSkillDefinition>[skill],
          power: 1,
        ),
      ],
    );

    expect(allies.single.maxMp, 40);
    expect(allies.single.currentMp, 0);
    expect(allies.single.skills.single.id, 'skill_firebolt');
    expect(allies.single.hasUsableSkill, isFalse);
  });

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
        searchDuration: Duration(seconds: 8),
        encounters: <BattleStageEncounterDefinition>[
          BattleStageEncounterDefinition(
            id: 'encounter_1',
            name: 'Encounter 1',
            enemySetId: 'enemy_set_1',
            summary: '기본 조합',
            chance: 1,
          ),
        ],
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
        searchDuration: Duration(seconds: 14),
        encounters: <BattleStageEncounterDefinition>[
          BattleStageEncounterDefinition(
            id: 'encounter_5',
            name: 'Encounter 5',
            enemySetId: 'enemy_set_5',
            summary: '보스 조합',
            chance: 1,
          ),
        ],
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
    expect(result.failurePenalty, 0);
    expect(result.loot, isEmpty);
    expect(result.actions, isNotEmpty);
  });

  test('extra attack does not recursively grant another extra attack', () {
    final BattleService service = BattleService(random: Random(1));
    final BattleEncounterRuntimeState encounter = BattleEncounterRuntimeState(
      encounterId: 'encounter_1',
      encounterName: 'Encounter 1',
      encounterIndex: 1,
      enemySetId: 'enemy_set_1',
      enemies: <BattleRunUnitState>[
        unit(
          id: 'enemy_stalker',
          team: BattleTeam.enemy,
          speed: 30,
          passives: const <BattlePassiveEffect>[
            BattlePassiveEffect(
              trigger: BattlePassiveTrigger.afterAction,
              type: BattlePassiveEffectType.extraAttack,
              sourceId: 'stalker_flurry',
              value: 1,
            ),
          ],
        ),
        unit(id: 'enemy_other', team: BattleTeam.enemy, speed: 20),
      ],
    );
    final List<BattleRunUnitState> allies = <BattleRunUnitState>[
      unit(id: 'ally', team: BattleTeam.ally, speed: 10),
    ];

    final BattleEncounterStepResult first = service.runEncounterStep(
      allies: allies,
      encounter: encounter,
      potionBoost: 0,
    );
    final BattleEncounterStepResult second = service.runEncounterStep(
      allies: first.allies,
      encounter: first.encounter,
      potionBoost: 0,
    );

    expect(
      first.lifecycleActions
          .where(
            (BattleActionLog action) => action.type == BattleActionType.attack,
          )
          .map((BattleActionLog action) => action.actorId),
      <String>['enemy_stalker', 'enemy_stalker'],
    );
    expect(
      first.lifecycleActions
          .where(
            (BattleActionLog action) => action.type == BattleActionType.attack,
          )
          .map((BattleActionLog action) => action.lifecycle),
      <int>[1, 2],
    );
    expect(first.encounter.pendingActorIds, <String>['enemy_other', 'ally']);
    expect(second.lifecycleActions.single.actorId, 'enemy_other');
  });

  test('counter attack runs as derived lifecycle without queue insert', () {
    final BattleService service = BattleService(random: Random(1));
    final BattleEncounterRuntimeState encounter = BattleEncounterRuntimeState(
      encounterId: 'encounter_1',
      encounterName: 'Encounter 1',
      encounterIndex: 1,
      enemySetId: 'enemy_set_1',
      enemies: <BattleRunUnitState>[
        unit(
          id: 'enemy_counter',
          team: BattleTeam.enemy,
          speed: 10,
          passives: const <BattlePassiveEffect>[
            BattlePassiveEffect(
              trigger: BattlePassiveTrigger.onDamaged,
              type: BattlePassiveEffectType.counterAttack,
              sourceId: 'counter_guard',
              value: 1,
            ),
          ],
        ),
      ],
    );
    final List<BattleRunUnitState> allies = <BattleRunUnitState>[
      unit(id: 'ally', team: BattleTeam.ally, speed: 20),
    ];

    final BattleEncounterStepResult first = service.runEncounterStep(
      allies: allies,
      encounter: encounter,
      potionBoost: 0,
    );
    final BattleEncounterStepResult second = service.runEncounterStep(
      allies: first.allies,
      encounter: first.encounter,
      potionBoost: 0,
    );

    expect(
      first.lifecycleActions
          .where(
            (BattleActionLog action) => action.type == BattleActionType.attack,
          )
          .map((BattleActionLog action) => action.actorId),
      <String>['ally', 'enemy_counter'],
    );
    expect(
      first.lifecycleActions
          .where(
            (BattleActionLog action) => action.type == BattleActionType.attack,
          )
          .map((BattleActionLog action) => action.lifecycle),
      <int>[1, 2],
    );
    expect(first.encounter.pendingActorIds, <String>['enemy_counter']);
    expect(second.lifecycleActions.single.actorId, 'enemy_counter');
  });

  test('first strike only changes initial encounter turn order', () {
    final BattleService service = BattleService(random: Random(1));
    final BattleEncounterRuntimeState encounter = BattleEncounterRuntimeState(
      encounterId: 'encounter_1',
      encounterName: 'Encounter 1',
      encounterIndex: 1,
      enemySetId: 'enemy_set_1',
      enemies: <BattleRunUnitState>[
        unit(id: 'enemy_fast', team: BattleTeam.enemy, speed: 30),
      ],
    );
    final List<BattleRunUnitState> allies = <BattleRunUnitState>[
      unit(
        id: 'ally_slow',
        team: BattleTeam.ally,
        speed: 1,
        passives: const <BattlePassiveEffect>[
          BattlePassiveEffect(
            trigger: BattlePassiveTrigger.battleStart,
            type: BattlePassiveEffectType.firstStrike,
            sourceId: 'opening_move',
          ),
        ],
      ),
    ];

    final BattleEncounterStepResult first = service.runEncounterStep(
      allies: allies,
      encounter: encounter,
      potionBoost: 0,
    );
    final BattleEncounterStepResult second = service.runEncounterStep(
      allies: first.allies,
      encounter: first.encounter,
      potionBoost: 0,
    );
    final BattleEncounterStepResult third = service.runEncounterStep(
      allies: second.allies,
      encounter: second.encounter,
      potionBoost: 0,
    );

    expect(first.lifecycleActions.single.actorId, 'ally_slow');
    expect(second.lifecycleActions.single.actorId, 'enemy_fast');
    expect(third.lifecycleActions.single.actorId, 'enemy_fast');
  });

  test(
    'grant modifier passive applies debuff and expires on owner turn end',
    () {
      final BattleService service = BattleService(random: Random(1));
      final BattleEncounterRuntimeState encounter = BattleEncounterRuntimeState(
        encounterId: 'encounter_1',
        encounterName: 'Encounter 1',
        encounterIndex: 1,
        enemySetId: 'enemy_set_1',
        enemies: <BattleRunUnitState>[
          unit(id: 'enemy', team: BattleTeam.enemy, speed: 1),
        ],
      );
      final List<BattleRunUnitState> allies = <BattleRunUnitState>[
        unit(
          id: 'debuffer',
          team: BattleTeam.ally,
          speed: 30,
          passives: const <BattlePassiveEffect>[
            BattlePassiveEffect(
              trigger: BattlePassiveTrigger.afterHit,
              type: BattlePassiveEffectType.grantModifier,
              sourceId: 'mark',
              durationLifecycles: 1,
              modifier: BattleModifier(
                type: BattleModifierType.damageTaken,
                mode: BattleModifierMode.percent,
                value: 1,
                sourceId: 'mark_damage_taken',
              ),
            ),
          ],
        ),
        unit(
          id: 'striker',
          team: BattleTeam.ally,
          speed: 20,
          physicalAttack: 40,
        ),
      ];

      final BattleEncounterStepResult first = service.runEncounterStep(
        allies: allies,
        encounter: encounter,
        potionBoost: 0,
      );
      final BattleEncounterStepResult second = service.runEncounterStep(
        allies: first.allies,
        encounter: first.encounter,
        potionBoost: 0,
      );
      final BattleEncounterStepResult third = service.runEncounterStep(
        allies: second.allies,
        encounter: second.encounter,
        potionBoost: 0,
      );

      expect(first.encounter.enemies.single.activeModifiers, hasLength(1));
      expect(
        first.lifecycleActions.any(
          (BattleActionLog action) => action.type == BattleActionType.modifier,
        ),
        isTrue,
      );
      expect(second.lifecycleActions.single.damage, greaterThan(10));
      expect(third.encounter.enemies.single.activeModifiers, isEmpty);
    },
  );

  test('status passive applies poison damage and expires on turn end', () {
    final BattleService service = BattleService(random: Random(1));
    final BattleEncounterRuntimeState encounter = BattleEncounterRuntimeState(
      encounterId: 'encounter_1',
      encounterName: 'Encounter 1',
      encounterIndex: 1,
      enemySetId: 'enemy_set_1',
      enemies: <BattleRunUnitState>[
        unit(id: 'enemy', team: BattleTeam.enemy, speed: 1),
      ],
    );
    final List<BattleRunUnitState> allies = <BattleRunUnitState>[
      unit(
        id: 'poisoner',
        team: BattleTeam.ally,
        speed: 20,
        passives: const <BattlePassiveEffect>[
          BattlePassiveEffect(
            trigger: BattlePassiveTrigger.afterHit,
            type: BattlePassiveEffectType.grantStatus,
            sourceId: 'poison_blade',
            statusType: BattleStatusType.poison,
            durationLifecycles: 1,
            value: 7,
          ),
        ],
      ),
    ];

    final BattleEncounterStepResult first = service.runEncounterStep(
      allies: allies,
      encounter: encounter,
      potionBoost: 0,
    );
    final BattleEncounterStepResult second = service.runEncounterStep(
      allies: first.allies,
      encounter: first.encounter,
      potionBoost: 0,
    );

    expect(
      first.encounter.enemies.single.statuses.single.type,
      BattleStatusType.poison,
    );
    expect(
      second.lifecycleActions.any(
        (BattleActionLog action) =>
            action.type == BattleActionType.status && action.damage == 7,
      ),
      isTrue,
    );
    expect(second.encounter.enemies.single.statuses, isEmpty);
  });

  test('always hit only applies on before hit check trigger', () {
    final BattleEncounterRuntimeState encounter = BattleEncounterRuntimeState(
      encounterId: 'encounter_1',
      encounterName: 'Encounter 1',
      encounterIndex: 1,
      enemySetId: 'enemy_set_1',
      enemies: <BattleRunUnitState>[
        unit(id: 'enemy', team: BattleTeam.enemy, speed: 1, evasion: 1),
      ],
    );
    final BattleRunUnitState wrongTriggerAlly = unit(
      id: 'ally',
      team: BattleTeam.ally,
      speed: 20,
      accuracy: 0,
      passives: const <BattlePassiveEffect>[
        BattlePassiveEffect(
          trigger: BattlePassiveTrigger.beforeAction,
          type: BattlePassiveEffectType.alwaysHit,
          sourceId: 'wrong_hook',
        ),
      ],
    );
    final BattleRunUnitState correctTriggerAlly = unit(
      id: 'ally',
      team: BattleTeam.ally,
      speed: 20,
      accuracy: 0,
      passives: const <BattlePassiveEffect>[
        BattlePassiveEffect(
          trigger: BattlePassiveTrigger.beforeHitCheck,
          type: BattlePassiveEffectType.alwaysHit,
          sourceId: 'right_hook',
        ),
      ],
    );

    final BattleEncounterStepResult wrongTriggerResult =
        BattleService(random: _FixedRandom(0.99)).runEncounterStep(
          allies: <BattleRunUnitState>[wrongTriggerAlly],
          encounter: encounter,
          potionBoost: 0,
        );
    final BattleEncounterStepResult correctTriggerResult =
        BattleService(random: _FixedRandom(0.99)).runEncounterStep(
          allies: <BattleRunUnitState>[correctTriggerAlly],
          encounter: encounter,
          potionBoost: 0,
        );

    expect(wrongTriggerResult.lifecycleActions.first.hit, isFalse);
    expect(correctTriggerResult.lifecycleActions.first.hit, isTrue);
  });

  test('normal attack restores fixed mp regen after lifecycle', () {
    final BattleService service = BattleService(random: Random(1));
    final BattleEncounterRuntimeState encounter = BattleEncounterRuntimeState(
      encounterId: 'encounter_1',
      encounterName: 'Encounter 1',
      encounterIndex: 1,
      enemySetId: 'enemy_set_1',
      enemies: <BattleRunUnitState>[
        unit(id: 'enemy', team: BattleTeam.enemy, speed: 1),
      ],
    );
    final List<BattleRunUnitState> allies = <BattleRunUnitState>[
      unit(id: 'ally', team: BattleTeam.ally, speed: 20, maxMp: 10, mpRegen: 4),
    ];

    final BattleEncounterStepResult result = service.runEncounterStep(
      allies: allies,
      encounter: encounter,
      potionBoost: 0,
    );

    expect(result.allies.single.currentMp, 4);
    expect(
      result.lifecycleActions.map((BattleActionLog action) => action.type),
      containsAllInOrder(<BattleActionType>[
        BattleActionType.attack,
        BattleActionType.mpRegen,
      ]),
    );
    expect(result.lifecycleActions.last.healing, 4);
    expect(result.lifecycleActions.last.actorMpAfter, 4);
  });

  test('unit at max mp uses active skill and spends all mp', () {
    final BattleService service = BattleService(random: Random(1));
    const BattleSkillDefinition skill = BattleSkillDefinition(
      id: 'skill_burst',
      name: 'Burst',
      summary: '강한 단일 공격',
      cooldownLifecycles: 2,
      powerMultiplier: 2,
    );
    final BattleEncounterRuntimeState encounter = BattleEncounterRuntimeState(
      encounterId: 'encounter_1',
      encounterName: 'Encounter 1',
      encounterIndex: 1,
      enemySetId: 'enemy_set_1',
      enemies: <BattleRunUnitState>[
        unit(id: 'enemy', team: BattleTeam.enemy, speed: 1),
      ],
    );
    final List<BattleRunUnitState> allies = <BattleRunUnitState>[
      unit(
        id: 'ally',
        team: BattleTeam.ally,
        speed: 20,
        maxMp: 10,
        currentMp: 10,
        mpRegen: 4,
        skills: const <BattleSkillDefinition>[skill],
      ),
    ];

    final BattleEncounterStepResult result = service.runEncounterStep(
      allies: allies,
      encounter: encounter,
      potionBoost: 0,
    );
    final BattleActionLog skillAction = result.lifecycleActions.first;

    expect(skillAction.type, BattleActionType.skill);
    expect(skillAction.skillId, 'skill_burst');
    expect(skillAction.mpSpent, 10);
    expect(skillAction.actorMpAfter, 0);
    expect(result.allies.single.currentMp, 0);
    expect(result.allies.single.skillCooldowns['skill_burst'], 2);
    expect(
      result.lifecycleActions.any(
        (BattleActionLog action) => action.type == BattleActionType.mpRegen,
      ),
      isFalse,
    );
  });
}

class _FixedRandom implements Random {
  const _FixedRandom(this.value);

  final double value;

  @override
  bool nextBool() {
    return value < 0.5;
  }

  @override
  double nextDouble() {
    return value;
  }

  @override
  int nextInt(int max) {
    return 0;
  }
}
