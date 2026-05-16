import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemySetDefinition> stage1BattleEnemySetDefinitions =
    <String, BattleEnemySetDefinition>{
      'enemy_set_stage_1_patrol': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_patrol',
        name: 'Ruins Patrol',
        enemyIds: <String>['enemy_scavenger', 'enemy_mite'],
        summary: '기본 약재를 긁어모으는 순찰조',
      ),
      'enemy_set_stage_1_haunt': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_haunt',
        name: 'Crystal Haunt',
        enemyIds: <String>['enemy_scavenger', 'enemy_wisp'],
        summary: '희귀 촉매를 품은 부유체가 섞인 초입 조합',
      ),
      'enemy_set_stage_1_swarm': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_swarm',
        name: 'Mite Swarm',
        enemyIds: <String>['enemy_mite', 'enemy_wisp'],
        summary: '빠른 군체와 부유체가 엮이는 초반 혼성 조합',
      ),
      'enemy_set_stage_1_resin': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_resin',
        name: 'Resin Patch',
        enemyIds: <String>[
          'enemy_rust_slug',
          'enemy_glowcap',
          'enemy_scavenger',
        ],
        summary: '산성 점액과 포자가 섞여 초입을 늦추는 조합',
      ),
      'enemy_set_stage_1_mix_5': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_5',
        name: 'Stage 1 Set 5',
        enemyIds: <String>['enemy_scavenger', 'enemy_rust_slug', 'enemy_wisp'],
        summary: '1단계 추가 혼성 조합',
      ),
      'enemy_set_stage_1_mix_6': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_6',
        name: 'Stage 1 Set 6',
        enemyIds: <String>['enemy_mite', 'enemy_glowcap', 'enemy_wisp'],
        summary: '1단계 추가 혼성 조합',
      ),
      'enemy_set_stage_1_mix_7': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_7',
        name: 'Stage 1 Set 7',
        enemyIds: <String>['enemy_rust_slug', 'enemy_mite', 'enemy_glowcap'],
        summary: '1단계 추가 혼성 조합',
      ),
      'enemy_set_stage_1_mix_8': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_8',
        name: 'Stage 1 Set 8',
        enemyIds: <String>['enemy_scavenger', 'enemy_glowcap'],
        summary: '1단계 추가 혼성 조합',
      ),
      'enemy_set_stage_1_mix_9': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_9',
        name: 'Stage 1 Set 9',
        enemyIds: <String>['enemy_rust_slug', 'enemy_wisp'],
        summary: '1단계 추가 혼성 조합',
      ),
      'enemy_set_stage_1_mix_10': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_10',
        name: 'Stage 1 Set 10',
        enemyIds: <String>['enemy_scavenger', 'enemy_mite', 'enemy_glowcap'],
        summary: '1단계 추가 혼성 조합',
      ),
    };

const List<BattleStageEncounterDefinition> stage1BattleStageEncounters =
    <BattleStageEncounterDefinition>[
      BattleStageEncounterDefinition(
        id: 'stage_1_patrol',
        enemySetId: 'enemy_set_stage_1_patrol',
        summary: '기본 약재 중심의 순찰조',
        chance: 0.16,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_haunt',
        enemySetId: 'enemy_set_stage_1_haunt',
        summary: '희귀 촉매가 섞인 초입 조합',
        chance: 0.13,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_swarm',
        enemySetId: 'enemy_set_stage_1_swarm',
        summary: '빠른 교전 위주의 군체 조합',
        chance: 0.11,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_resin',
        enemySetId: 'enemy_set_stage_1_resin',
        summary: '방어 약화와 포자 중독이 섞인 초입 변형 조합',
        chance: 0.11,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_5',
        enemySetId: 'enemy_set_stage_1_mix_5',
        summary: '1단계 추가 혼성 조합',
        chance: 0.1,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_6',
        enemySetId: 'enemy_set_stage_1_mix_6',
        summary: '1단계 추가 혼성 조합',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_7',
        enemySetId: 'enemy_set_stage_1_mix_7',
        summary: '1단계 추가 혼성 조합',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_8',
        enemySetId: 'enemy_set_stage_1_mix_8',
        summary: '1단계 추가 혼성 조합',
        chance: 0.08,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_9',
        enemySetId: 'enemy_set_stage_1_mix_9',
        summary: '1단계 추가 혼성 조합',
        chance: 0.07,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_10',
        enemySetId: 'enemy_set_stage_1_mix_10',
        summary: '1단계 추가 혼성 조합',
        chance: 0.06,
      ),
    ];
