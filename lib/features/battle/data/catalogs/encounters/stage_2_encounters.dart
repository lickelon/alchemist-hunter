import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemySetDefinition>
stage2BattleEnemySetDefinitions = <String, BattleEnemySetDefinition>{
  'enemy_set_stage_2_crossfire': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_crossfire',
    name: 'Crossfire Line',
    enemyIds: <String>['enemy_scout', 'enemy_stalker', 'enemy_bruiser'],
    summary: '정찰, 연타, 압박이 모두 들어오는 기본 전개',
  ),
  'enemy_set_stage_2_ambush': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_ambush',
    name: 'Ambush Knot',
    enemyIds: <String>['enemy_scout', 'enemy_stalker', 'enemy_raider'],
    summary: '고속 접근과 기습이 겹치는 교란 조합',
  ),
  'enemy_set_stage_2_assault': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_assault',
    name: 'Assault Wedge',
    enemyIds: <String>['enemy_scout', 'enemy_bruiser', 'enemy_raider'],
    summary: '전열 압박 비중이 높은 돌격 조합',
  ),
  'enemy_set_stage_2_salvage': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_salvage',
    name: 'Salvage Guard',
    enemyIds: <String>['enemy_glassback', 'enemy_dust_mender', 'enemy_raider'],
    summary: '방벽과 긴급 회복으로 교전을 늘리는 회수조',
  ),
  'enemy_set_stage_2_mix_5': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_5',
    name: 'Stage 2 Set 5',
    enemyIds: <String>['enemy_stalker', 'enemy_glassback', 'enemy_scout'],
    summary: '2단계 추가 혼성 조합',
  ),
  'enemy_set_stage_2_mix_6': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_6',
    name: 'Stage 2 Set 6',
    enemyIds: <String>['enemy_bruiser', 'enemy_dust_mender', 'enemy_scout'],
    summary: '2단계 추가 혼성 조합',
  ),
  'enemy_set_stage_2_mix_7': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_7',
    name: 'Stage 2 Set 7',
    enemyIds: <String>['enemy_glassback', 'enemy_stalker', 'enemy_dust_mender'],
    summary: '2단계 추가 혼성 조합',
  ),
  'enemy_set_stage_2_mix_8': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_8',
    name: 'Stage 2 Set 8',
    enemyIds: <String>['enemy_raider', 'enemy_stalker', 'enemy_dust_mender'],
    summary: '2단계 추가 혼성 조합',
  ),
  'enemy_set_stage_2_mix_9': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_9',
    name: 'Stage 2 Set 9',
    enemyIds: <String>['enemy_bruiser', 'enemy_glassback', 'enemy_raider'],
    summary: '2단계 추가 혼성 조합',
  ),
  'enemy_set_stage_2_mix_10': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_10',
    name: 'Stage 2 Set 10',
    enemyIds: <String>['enemy_scout', 'enemy_glassback', 'enemy_dust_mender'],
    summary: '2단계 추가 혼성 조합',
  ),
};

const List<BattleStageEncounterDefinition> stage2BattleStageEncounters =
    <BattleStageEncounterDefinition>[
      BattleStageEncounterDefinition(
        id: 'stage_2_crossfire',
        name: '교차 화력 조합',
        enemySetId: 'enemy_set_stage_2_crossfire',
        summary: '정찰과 연타, 압박이 고르게 섞인 전개',
        chance: 0.16,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_ambush',
        name: '기습 조합',
        enemySetId: 'enemy_set_stage_2_ambush',
        summary: '고속 접근과 후열 압박 비중이 높은 전개',
        chance: 0.14,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_assault',
        name: '돌격 조합',
        enemySetId: 'enemy_set_stage_2_assault',
        summary: '전열 압박이 강한 정면 돌파 전개',
        chance: 0.13,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_salvage',
        name: '회수 방벽 조합',
        enemySetId: 'enemy_set_stage_2_salvage',
        summary: '방벽과 회복이 섞여 전투 시간을 늘리는 전개',
        chance: 0.12,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_5',
        name: '2단계 조합 5',
        enemySetId: 'enemy_set_stage_2_mix_5',
        summary: '2단계 추가 혼성 조합',
        chance: 0.1,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_6',
        name: '2단계 조합 6',
        enemySetId: 'enemy_set_stage_2_mix_6',
        summary: '2단계 추가 혼성 조합',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_7',
        name: '2단계 조합 7',
        enemySetId: 'enemy_set_stage_2_mix_7',
        summary: '2단계 추가 혼성 조합',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_8',
        name: '2단계 조합 8',
        enemySetId: 'enemy_set_stage_2_mix_8',
        summary: '2단계 추가 혼성 조합',
        chance: 0.07,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_9',
        name: '2단계 조합 9',
        enemySetId: 'enemy_set_stage_2_mix_9',
        summary: '2단계 추가 혼성 조합',
        chance: 0.06,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_10',
        name: '2단계 조합 10',
        enemySetId: 'enemy_set_stage_2_mix_10',
        summary: '2단계 추가 혼성 조합',
        chance: 0.04,
      ),
    ];
