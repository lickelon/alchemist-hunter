import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemySetDefinition>
stage4BattleEnemySetDefinitions = <String, BattleEnemySetDefinition>{
  'enemy_set_stage_4_lattice': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_lattice',
    name: 'Storm Lattice',
    enemyIds: <String>['enemy_sniper', 'enemy_weaver', 'enemy_tempest'],
    summary: '필중 견제와 연속 주문이 겹치는 기본 고압 조합',
  ),
  'enemy_set_stage_4_volley': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_volley',
    name: 'Phantom Volley',
    enemyIds: <String>['enemy_sniper', 'enemy_weaver', 'enemy_mirage'],
    summary: '회피 교란 비중이 높은 원거리 압박 조합',
  ),
  'enemy_set_stage_4_hunt': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_hunt',
    name: 'Chain Hunt',
    enemyIds: <String>['enemy_sniper', 'enemy_tempest', 'enemy_mirage'],
    summary: '기동 교전과 후속 타격이 강한 추격 조합',
  ),
  'enemy_set_stage_4_conduit': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_conduit',
    name: 'Storm Conduit',
    enemyIds: <String>[
      'enemy_thunder_moth',
      'enemy_gale_channeler',
      'enemy_tempest',
    ],
    summary: '광역 번개와 마법 증폭이 겹치는 폭풍 증폭 조합',
  ),
  'enemy_set_stage_4_mix_5': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_5',
    name: 'Stage 4 Set 5',
    enemyIds: <String>[
      'enemy_sniper',
      'enemy_thunder_moth',
      'enemy_gale_channeler',
    ],
    summary: '4단계 추가 혼성 조합',
  ),
  'enemy_set_stage_4_mix_6': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_6',
    name: 'Stage 4 Set 6',
    enemyIds: <String>['enemy_weaver', 'enemy_thunder_moth', 'enemy_mirage'],
    summary: '4단계 추가 혼성 조합',
  ),
  'enemy_set_stage_4_mix_7': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_7',
    name: 'Stage 4 Set 7',
    enemyIds: <String>['enemy_gale_channeler', 'enemy_sniper', 'enemy_mirage'],
    summary: '4단계 추가 혼성 조합',
  ),
  'enemy_set_stage_4_mix_8': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_8',
    name: 'Stage 4 Set 8',
    enemyIds: <String>['enemy_tempest', 'enemy_thunder_moth', 'enemy_mirage'],
    summary: '4단계 추가 혼성 조합',
  ),
  'enemy_set_stage_4_mix_9': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_9',
    name: 'Stage 4 Set 9',
    enemyIds: <String>['enemy_weaver', 'enemy_gale_channeler', 'enemy_sniper'],
    summary: '4단계 추가 혼성 조합',
  ),
  'enemy_set_stage_4_mix_10': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_10',
    name: 'Stage 4 Set 10',
    enemyIds: <String>[
      'enemy_thunder_moth',
      'enemy_gale_channeler',
      'enemy_mirage',
    ],
    summary: '4단계 추가 혼성 조합',
  ),
};

const List<BattleStageEncounterDefinition> stage4BattleStageEncounters =
    <BattleStageEncounterDefinition>[
      BattleStageEncounterDefinition(
        id: 'stage_4_lattice',
        name: '폭풍 조합',
        enemySetId: 'enemy_set_stage_4_lattice',
        summary: '필중 견제와 연속 주문이 겹치는 기본 전개',
        chance: 0.15,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_volley',
        name: '교란 조합',
        enemySetId: 'enemy_set_stage_4_volley',
        summary: '회피 교란 비중이 높은 원거리 전개',
        chance: 0.14,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_hunt',
        name: '추격 조합',
        enemySetId: 'enemy_set_stage_4_hunt',
        summary: '기동 교전과 후속 타격이 강한 전개',
        chance: 0.13,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_conduit',
        name: '폭풍 증폭 조합',
        enemySetId: 'enemy_set_stage_4_conduit',
        summary: '광역 번개와 마법 증폭이 겹치는 전개',
        chance: 0.12,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_5',
        name: '4단계 조합 5',
        enemySetId: 'enemy_set_stage_4_mix_5',
        summary: '4단계 추가 혼성 조합',
        chance: 0.1,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_6',
        name: '4단계 조합 6',
        enemySetId: 'enemy_set_stage_4_mix_6',
        summary: '4단계 추가 혼성 조합',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_7',
        name: '4단계 조합 7',
        enemySetId: 'enemy_set_stage_4_mix_7',
        summary: '4단계 추가 혼성 조합',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_8',
        name: '4단계 조합 8',
        enemySetId: 'enemy_set_stage_4_mix_8',
        summary: '4단계 추가 혼성 조합',
        chance: 0.07,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_9',
        name: '4단계 조합 9',
        enemySetId: 'enemy_set_stage_4_mix_9',
        summary: '4단계 추가 혼성 조합',
        chance: 0.06,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_10',
        name: '4단계 조합 10',
        enemySetId: 'enemy_set_stage_4_mix_10',
        summary: '4단계 추가 혼성 조합',
        chance: 0.05,
      ),
    ];
