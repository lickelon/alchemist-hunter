import 'package:alchemist_hunter/features/battle/domain/models.dart';

import 'enemies/battle_enemy_definitions.dart';

const Map<String, BattleEnemySetDefinition>
battleEnemySetDefinitions = <String, BattleEnemySetDefinition>{
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
    enemyIds: <String>['enemy_rust_slug', 'enemy_glowcap', 'enemy_scavenger'],
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
  'enemy_set_stage_5_guarded': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_guarded',
    name: 'Core Keeper',
    enemyIds: <String>['enemy_chimera', 'enemy_warden'],
    summary: '보스와 중장갑 호위체가 함께 버티는 기본 조합',
  ),
  'enemy_set_stage_5_signal': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_signal',
    name: 'Signal Choir',
    enemyIds: <String>['enemy_chimera', 'enemy_herald'],
    summary: '보스와 후열 화력이 동시에 압박하는 조합',
  ),
  'enemy_set_stage_5_awakened': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_awakened',
    name: 'Full Awakening',
    enemyIds: <String>['enemy_chimera', 'enemy_herald', 'enemy_warden'],
    summary: '최종 구간의 완전체 조합',
  ),
  'enemy_set_stage_5_core_line': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_core_line',
    name: 'Core Line',
    enemyIds: <String>[
      'enemy_core_siphon',
      'enemy_moonvault_aegis',
      'enemy_herald',
    ],
    summary: '핵 흡수체와 방어체가 장기전을 만드는 일반 고난도 조합',
  ),
  'enemy_set_stage_5_mix_5': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_mix_5',
    name: 'Stage 5 Set 5',
    enemyIds: <String>['enemy_chimera', 'enemy_core_siphon'],
    summary: '5단계 추가 혼성 조합',
  ),
  'enemy_set_stage_5_mix_6': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_mix_6',
    name: 'Stage 5 Set 6',
    enemyIds: <String>['enemy_moonvault_aegis', 'enemy_warden', 'enemy_herald'],
    summary: '5단계 추가 혼성 조합',
  ),
  'enemy_set_stage_5_mix_7': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_mix_7',
    name: 'Stage 5 Set 7',
    enemyIds: <String>[
      'enemy_chimera',
      'enemy_core_siphon',
      'enemy_moonvault_aegis',
    ],
    summary: '5단계 추가 혼성 조합',
  ),
  'enemy_set_stage_5_mix_8': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_mix_8',
    name: 'Stage 5 Set 8',
    enemyIds: <String>['enemy_core_siphon', 'enemy_herald'],
    summary: '5단계 추가 혼성 조합',
  ),
  'enemy_set_stage_5_mix_9': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_mix_9',
    name: 'Stage 5 Set 9',
    enemyIds: <String>[
      'enemy_moonvault_aegis',
      'enemy_chimera',
      'enemy_warden',
    ],
    summary: '5단계 추가 혼성 조합',
  ),
  'enemy_set_stage_5_mix_10': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_mix_10',
    name: 'Stage 5 Set 10',
    enemyIds: <String>[
      'enemy_core_siphon',
      'enemy_herald',
      'enemy_moonvault_aegis',
    ],
    summary: '5단계 추가 혼성 조합',
  ),
};

const Map<String, BattleStageDefinition> battleStageDefinitions =
    <String, BattleStageDefinition>{
      'stage_1': BattleStageDefinition(
        id: 'stage_1',
        name: '폐허 입구',
        recommendedPower: 210,
        searchDuration: Duration(seconds: 7),
        recoveryDuration: Duration(seconds: 10),
        encounters: <BattleStageEncounterDefinition>[
          BattleStageEncounterDefinition(
            id: 'stage_1_patrol',
            name: '순찰 조합',
            enemySetId: 'enemy_set_stage_1_patrol',
            summary: '기본 약재 중심의 순찰조',
            chance: 0.16,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_haunt',
            name: '부유체 조합',
            enemySetId: 'enemy_set_stage_1_haunt',
            summary: '희귀 촉매가 섞인 초입 조합',
            chance: 0.13,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_swarm',
            name: '군체 조합',
            enemySetId: 'enemy_set_stage_1_swarm',
            summary: '빠른 교전 위주의 군체 조합',
            chance: 0.11,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_resin',
            name: '수지 포자 조합',
            enemySetId: 'enemy_set_stage_1_resin',
            summary: '방어 약화와 포자 중독이 섞인 초입 변형 조합',
            chance: 0.11,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_mix_5',
            name: '1단계 조합 5',
            enemySetId: 'enemy_set_stage_1_mix_5',
            summary: '1단계 추가 혼성 조합',
            chance: 0.1,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_mix_6',
            name: '1단계 조합 6',
            enemySetId: 'enemy_set_stage_1_mix_6',
            summary: '1단계 추가 혼성 조합',
            chance: 0.09,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_mix_7',
            name: '1단계 조합 7',
            enemySetId: 'enemy_set_stage_1_mix_7',
            summary: '1단계 추가 혼성 조합',
            chance: 0.09,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_mix_8',
            name: '1단계 조합 8',
            enemySetId: 'enemy_set_stage_1_mix_8',
            summary: '1단계 추가 혼성 조합',
            chance: 0.08,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_mix_9',
            name: '1단계 조합 9',
            enemySetId: 'enemy_set_stage_1_mix_9',
            summary: '1단계 추가 혼성 조합',
            chance: 0.07,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_mix_10',
            name: '1단계 조합 10',
            enemySetId: 'enemy_set_stage_1_mix_10',
            summary: '1단계 추가 혼성 조합',
            chance: 0.06,
          ),
        ],
        goldSuccess: 24,
        goldFailurePenalty: 0,
        essenceSuccess: 4,
        essenceFailure: 0,
        xpSuccessBase: 16,
        xpFailureBase: 0,
        clearUnlockFlags: <String>{'stage_2'},
      ),
      'stage_2': BattleStageDefinition(
        id: 'stage_2',
        name: '먼지 회랑',
        recommendedPower: 300,
        searchDuration: Duration(seconds: 9),
        recoveryDuration: Duration(seconds: 12),
        encounters: <BattleStageEncounterDefinition>[
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
        ],
        goldSuccess: 42,
        goldFailurePenalty: 0,
        essenceSuccess: 6,
        essenceFailure: 0,
        xpSuccessBase: 24,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_1',
          requiredWinStreakCount: 3,
          label: '잠금 조건: 1단계에서 실패 없이 3회 연속 승리',
        ),
        clearUnlockFlags: <String>{'stage_3'},
      ),
      'stage_3': BattleStageDefinition(
        id: 'stage_3',
        name: '재의 공방',
        recommendedPower: 390,
        searchDuration: Duration(seconds: 11),
        recoveryDuration: Duration(seconds: 14),
        encounters: <BattleStageEncounterDefinition>[
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
        ],
        goldSuccess: 60,
        goldFailurePenalty: 0,
        essenceSuccess: 9,
        essenceFailure: 0,
        xpSuccessBase: 34,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_2',
          requiredWinStreakCount: 3,
          label: '잠금 조건: 2단계에서 실패 없이 3회 연속 승리',
        ),
        clearUnlockFlags: <String>{'stage_4', 'potion_special_1'},
      ),
      'stage_4': BattleStageDefinition(
        id: 'stage_4',
        name: '폭풍 전시실',
        recommendedPower: 490,
        searchDuration: Duration(seconds: 14),
        recoveryDuration: Duration(seconds: 16),
        encounters: <BattleStageEncounterDefinition>[
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
        ],
        goldSuccess: 86,
        goldFailurePenalty: 0,
        essenceSuccess: 13,
        essenceFailure: 0,
        xpSuccessBase: 46,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_3',
          requiredWinStreakCount: 3,
          label: '잠금 조건: 3단계에서 실패 없이 3회 연속 승리',
        ),
        clearUnlockFlags: <String>{'stage_5'},
      ),
      'stage_5': BattleStageDefinition(
        id: 'stage_5',
        name: '문물의 핵',
        recommendedPower: 580,
        searchDuration: Duration(seconds: 15),
        recoveryDuration: Duration(seconds: 18),
        encounters: <BattleStageEncounterDefinition>[
          BattleStageEncounterDefinition(
            id: 'stage_5_guarded',
            name: '호위 조합',
            enemySetId: 'enemy_set_stage_5_guarded',
            summary: '보스와 중장갑 호위체가 버티는 전개',
            chance: 0.22,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_signal',
            name: '신호 조합',
            enemySetId: 'enemy_set_stage_5_signal',
            summary: '보스와 후열 화력이 동시에 몰아치는 전개',
            chance: 0.17,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_awakened',
            name: '각성 조합',
            enemySetId: 'enemy_set_stage_5_awakened',
            summary: '최종 구간 완전체 전개',
            chance: 0.12,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_core_line',
            name: '핵 방어선 조합',
            enemySetId: 'enemy_set_stage_5_core_line',
            summary: '핵 흡수와 보호막이 겹치는 일반 고난도 전개',
            chance: 0.1,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_mix_5',
            name: '5단계 조합 5',
            enemySetId: 'enemy_set_stage_5_mix_5',
            summary: '5단계 추가 혼성 조합',
            chance: 0.09,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_mix_6',
            name: '5단계 조합 6',
            enemySetId: 'enemy_set_stage_5_mix_6',
            summary: '5단계 추가 혼성 조합',
            chance: 0.08,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_mix_7',
            name: '5단계 조합 7',
            enemySetId: 'enemy_set_stage_5_mix_7',
            summary: '5단계 추가 혼성 조합',
            chance: 0.07,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_mix_8',
            name: '5단계 조합 8',
            enemySetId: 'enemy_set_stage_5_mix_8',
            summary: '5단계 추가 혼성 조합',
            chance: 0.06,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_mix_9',
            name: '5단계 조합 9',
            enemySetId: 'enemy_set_stage_5_mix_9',
            summary: '5단계 추가 혼성 조합',
            chance: 0.05,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_mix_10',
            name: '5단계 조합 10',
            enemySetId: 'enemy_set_stage_5_mix_10',
            summary: '5단계 추가 혼성 조합',
            chance: 0.04,
          ),
        ],
        goldSuccess: 112,
        goldFailurePenalty: 0,
        essenceSuccess: 18,
        essenceFailure: 0,
        xpSuccessBase: 58,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_4',
          requiredWinStreakCount: 3,
          label: '잠금 조건: 4단계에서 실패 없이 3회 연속 승리',
        ),
        clearUnlockFlags: <String>{'potion_special_2'},
      ),
    };

const List<String> stageCatalog = <String>[
  'stage_1',
  'stage_2',
  'stage_3',
  'stage_4',
  'stage_5',
];

BattleStageDefinition stageDefinition(String stageId) {
  final BattleStageDefinition? definition = battleStageDefinitions[stageId];
  if (definition == null) {
    throw StateError('Unknown stage: $stageId');
  }
  return definition;
}

BattleEnemySetDefinition enemySetDefinition(String enemySetId) {
  final BattleEnemySetDefinition? definition =
      battleEnemySetDefinitions[enemySetId];
  if (definition == null) {
    throw StateError('Unknown enemy set: $enemySetId');
  }
  return definition;
}

List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
  String stageId,
) {
  return stageDefinition(stageId).encounters;
}

List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId) {
  final BattleEnemySetDefinition enemySet = enemySetDefinition(enemySetId);
  return enemySet.enemyIds
      .map((String enemyId) {
        final BattleEnemyDefinition? definition =
            battleEnemyDefinitions[enemyId];
        if (definition == null) {
          throw StateError('Unknown enemy: $enemyId');
        }
        return definition;
      })
      .toList(growable: false);
}

List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) {
  final Map<String, BattleEnemyDefinition> uniqueEnemies =
      <String, BattleEnemyDefinition>{};
  for (final BattleStageEncounterDefinition encounter
      in encounterDefinitionsForStage(stageId)) {
    for (final BattleEnemyDefinition enemy in enemyDefinitionsForSet(
      encounter.enemySetId,
    )) {
      uniqueEnemies[enemy.id] = enemy;
    }
  }
  return uniqueEnemies.values.toList(growable: false);
}

BattleDropTable dropTableForEnemySet({
  required String stageId,
  required String enemySetId,
}) {
  final List<BattleEnemyDefinition> enemies = enemyDefinitionsForSet(
    enemySetId,
  );
  return BattleDropTable(
    stageId: stageId,
    normalDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.normalDrops)
        .toList(growable: false),
    specialDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.specialDrops)
        .toList(growable: false),
  );
}

BattleDropTable stageDropTable(String stageId) {
  final List<BattleEnemyDefinition> enemies = enemyDefinitionsForStage(stageId);
  return BattleDropTable(
    stageId: stageId,
    normalDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.normalDrops)
        .toList(growable: false),
    specialDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.specialDrops)
        .toList(growable: false),
  );
}
