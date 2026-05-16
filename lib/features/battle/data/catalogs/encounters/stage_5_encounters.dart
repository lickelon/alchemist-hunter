import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemySetDefinition> stage5BattleEnemySetDefinitions =
    <String, BattleEnemySetDefinition>{
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
        enemyIds: <String>[
          'enemy_moonvault_aegis',
          'enemy_warden',
          'enemy_herald',
        ],
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

const List<BattleStageEncounterDefinition> stage5BattleStageEncounters =
    <BattleStageEncounterDefinition>[
      BattleStageEncounterDefinition(
        id: 'stage_5_guarded',
        enemySetId: 'enemy_set_stage_5_guarded',
        summary: '보스와 중장갑 호위체가 버티는 전개',
        chance: 0.22,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_5_signal',
        enemySetId: 'enemy_set_stage_5_signal',
        summary: '보스와 후열 화력이 동시에 몰아치는 전개',
        chance: 0.17,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_5_awakened',
        enemySetId: 'enemy_set_stage_5_awakened',
        summary: '최종 구간 완전체 전개',
        chance: 0.12,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_5_core_line',
        enemySetId: 'enemy_set_stage_5_core_line',
        summary: '핵 흡수와 보호막이 겹치는 일반 고난도 전개',
        chance: 0.1,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_5_mix_5',
        enemySetId: 'enemy_set_stage_5_mix_5',
        summary: '5단계 추가 혼성 조합',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_5_mix_6',
        enemySetId: 'enemy_set_stage_5_mix_6',
        summary: '5단계 추가 혼성 조합',
        chance: 0.08,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_5_mix_7',
        enemySetId: 'enemy_set_stage_5_mix_7',
        summary: '5단계 추가 혼성 조합',
        chance: 0.07,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_5_mix_8',
        enemySetId: 'enemy_set_stage_5_mix_8',
        summary: '5단계 추가 혼성 조합',
        chance: 0.06,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_5_mix_9',
        enemySetId: 'enemy_set_stage_5_mix_9',
        summary: '5단계 추가 혼성 조합',
        chance: 0.05,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_5_mix_10',
        enemySetId: 'enemy_set_stage_5_mix_10',
        summary: '5단계 추가 혼성 조합',
        chance: 0.04,
      ),
    ];
