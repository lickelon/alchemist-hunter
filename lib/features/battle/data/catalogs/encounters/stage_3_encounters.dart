import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemySetDefinition>
stage3BattleEnemySetDefinitions = <String, BattleEnemySetDefinition>{
  'enemy_set_stage_3_furnace': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_furnace',
    name: 'Furnace Front',
    enemyIds: <String>['enemy_sentinel', 'enemy_crucible', 'enemy_apprentice'],
    summary: '장갑 수호기와 돌진형이 전열을 잡는 표준 조합',
  ),
  'enemy_set_stage_3_relay': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_relay',
    name: 'Arcane Relay',
    enemyIds: <String>['enemy_sentinel', 'enemy_apprentice', 'enemy_distiller'],
    summary: '후열 화력이 강하게 몰리는 연성 조합',
  ),
  'enemy_set_stage_3_overheat': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_overheat',
    name: 'Overheat Wing',
    enemyIds: <String>['enemy_crucible', 'enemy_apprentice', 'enemy_distiller'],
    summary: '방어보다 화력 압박이 앞서는 고열 조합',
  ),
  'enemy_set_stage_3_engraving': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_engraving',
    name: 'Cinder Engraving',
    enemyIds: <String>[
      'enemy_furnace_leech',
      'enemy_cinder_scribe',
      'enemy_crucible',
    ],
    summary: '흡혈과 취약 표식을 겹쳐 장기전을 강요하는 조합',
  ),
  'enemy_set_stage_3_mix_5': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_5',
    name: 'Stage 3 Set 5',
    enemyIds: <String>[
      'enemy_sentinel',
      'enemy_furnace_leech',
      'enemy_cinder_scribe',
    ],
    summary: '3단계 추가 혼성 조합',
  ),
  'enemy_set_stage_3_mix_6': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_6',
    name: 'Stage 3 Set 6',
    enemyIds: <String>[
      'enemy_distiller',
      'enemy_furnace_leech',
      'enemy_apprentice',
    ],
    summary: '3단계 추가 혼성 조합',
  ),
  'enemy_set_stage_3_mix_7': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_7',
    name: 'Stage 3 Set 7',
    enemyIds: <String>[
      'enemy_sentinel',
      'enemy_cinder_scribe',
      'enemy_distiller',
    ],
    summary: '3단계 추가 혼성 조합',
  ),
  'enemy_set_stage_3_mix_8': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_8',
    name: 'Stage 3 Set 8',
    enemyIds: <String>[
      'enemy_crucible',
      'enemy_furnace_leech',
      'enemy_distiller',
    ],
    summary: '3단계 추가 혼성 조합',
  ),
  'enemy_set_stage_3_mix_9': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_9',
    name: 'Stage 3 Set 9',
    enemyIds: <String>[
      'enemy_sentinel',
      'enemy_cinder_scribe',
      'enemy_apprentice',
    ],
    summary: '3단계 추가 혼성 조합',
  ),
  'enemy_set_stage_3_mix_10': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_10',
    name: 'Stage 3 Set 10',
    enemyIds: <String>[
      'enemy_furnace_leech',
      'enemy_cinder_scribe',
      'enemy_distiller',
    ],
    summary: '3단계 추가 혼성 조합',
  ),
};

const List<BattleStageEncounterDefinition> stage3BattleStageEncounters =
    <BattleStageEncounterDefinition>[
      BattleStageEncounterDefinition(
        id: 'stage_3_furnace',
        name: '용광 전선 조합',
        enemySetId: 'enemy_set_stage_3_furnace',
        summary: '전열 버티기와 후열 화력이 균형 잡힌 전개',
        chance: 0.15,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_relay',
        name: '연성 릴레이 조합',
        enemySetId: 'enemy_set_stage_3_relay',
        summary: '후열 연성 화력이 몰리는 전개',
        chance: 0.14,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_overheat',
        name: '과열 조합',
        enemySetId: 'enemy_set_stage_3_overheat',
        summary: '방어보다 화력 압박이 앞서는 전개',
        chance: 0.13,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_engraving',
        name: '재각인 조합',
        enemySetId: 'enemy_set_stage_3_engraving',
        summary: '흡혈과 취약 표식이 누적되는 장기전 전개',
        chance: 0.12,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_5',
        name: '3단계 조합 5',
        enemySetId: 'enemy_set_stage_3_mix_5',
        summary: '3단계 추가 혼성 조합',
        chance: 0.1,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_6',
        name: '3단계 조합 6',
        enemySetId: 'enemy_set_stage_3_mix_6',
        summary: '3단계 추가 혼성 조합',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_7',
        name: '3단계 조합 7',
        enemySetId: 'enemy_set_stage_3_mix_7',
        summary: '3단계 추가 혼성 조합',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_8',
        name: '3단계 조합 8',
        enemySetId: 'enemy_set_stage_3_mix_8',
        summary: '3단계 추가 혼성 조합',
        chance: 0.07,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_9',
        name: '3단계 조합 9',
        enemySetId: 'enemy_set_stage_3_mix_9',
        summary: '3단계 추가 혼성 조합',
        chance: 0.06,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_10',
        name: '3단계 조합 10',
        enemySetId: 'enemy_set_stage_3_mix_10',
        summary: '3단계 추가 혼성 조합',
        chance: 0.05,
      ),
    ];
