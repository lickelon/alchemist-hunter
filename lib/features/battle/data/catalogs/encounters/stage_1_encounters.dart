import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemySetDefinition> stage1BattleEnemySetDefinitions =
    <String, BattleEnemySetDefinition>{
      'enemy_set_stage_1_patrol': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_patrol',
        name: 'Ruins Patrol',
        enemyIds: <String>['enemy_scavenger', 'enemy_mite'],
      ),
      'enemy_set_stage_1_haunt': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_haunt',
        name: 'Crystal Haunt',
        enemyIds: <String>['enemy_scavenger', 'enemy_wisp'],
      ),
      'enemy_set_stage_1_swarm': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_swarm',
        name: 'Mite Swarm',
        enemyIds: <String>['enemy_mite', 'enemy_wisp'],
      ),
      'enemy_set_stage_1_resin': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_resin',
        name: 'Resin Patch',
        enemyIds: <String>[
          'enemy_rust_slug',
          'enemy_glowcap',
          'enemy_scavenger',
        ],
      ),
      'enemy_set_stage_1_mix_5': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_5',
        name: 'Stage 1 Set 5',
        enemyIds: <String>['enemy_scavenger', 'enemy_rust_slug', 'enemy_wisp'],
      ),
      'enemy_set_stage_1_mix_6': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_6',
        name: 'Stage 1 Set 6',
        enemyIds: <String>['enemy_mite', 'enemy_glowcap', 'enemy_wisp'],
      ),
      'enemy_set_stage_1_mix_7': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_7',
        name: 'Stage 1 Set 7',
        enemyIds: <String>['enemy_rust_slug', 'enemy_mite', 'enemy_glowcap'],
      ),
      'enemy_set_stage_1_mix_8': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_8',
        name: 'Stage 1 Set 8',
        enemyIds: <String>['enemy_scavenger', 'enemy_glowcap'],
      ),
      'enemy_set_stage_1_mix_9': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_9',
        name: 'Stage 1 Set 9',
        enemyIds: <String>['enemy_rust_slug', 'enemy_wisp'],
      ),
      'enemy_set_stage_1_mix_10': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1_mix_10',
        name: 'Stage 1 Set 10',
        enemyIds: <String>['enemy_scavenger', 'enemy_mite', 'enemy_glowcap'],
      ),
    };

const List<BattleStageEncounterDefinition> stage1BattleStageEncounters =
    <BattleStageEncounterDefinition>[
      BattleStageEncounterDefinition(
        id: 'stage_1_patrol',
        enemySetId: 'enemy_set_stage_1_patrol',
        chance: 0.16,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_haunt',
        enemySetId: 'enemy_set_stage_1_haunt',
        chance: 0.13,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_swarm',
        enemySetId: 'enemy_set_stage_1_swarm',
        chance: 0.11,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_resin',
        enemySetId: 'enemy_set_stage_1_resin',
        chance: 0.11,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_5',
        enemySetId: 'enemy_set_stage_1_mix_5',
        chance: 0.1,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_6',
        enemySetId: 'enemy_set_stage_1_mix_6',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_7',
        enemySetId: 'enemy_set_stage_1_mix_7',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_8',
        enemySetId: 'enemy_set_stage_1_mix_8',
        chance: 0.08,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_9',
        enemySetId: 'enemy_set_stage_1_mix_9',
        chance: 0.07,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_1_mix_10',
        enemySetId: 'enemy_set_stage_1_mix_10',
        chance: 0.06,
      ),
    ];
