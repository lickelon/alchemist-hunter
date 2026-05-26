import '../battle_catalog_dtos.dart';

const Map<String, BattleEnemySetDefinitionDto>
stage1BattleEnemySetDefinitionDtos = <String, BattleEnemySetDefinitionDto>{
  'enemy_set_stage_1_patrol': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_1_patrol',
    name: 'Ruins Patrol',
    enemyIds: <String>['enemy_scavenger', 'enemy_mite'],
  ),
  'enemy_set_stage_1_haunt': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_1_haunt',
    name: 'Crystal Haunt',
    enemyIds: <String>['enemy_scavenger', 'enemy_wisp'],
  ),
  'enemy_set_stage_1_swarm': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_1_swarm',
    name: 'Mite Swarm',
    enemyIds: <String>['enemy_mite', 'enemy_wisp'],
  ),
  'enemy_set_stage_1_resin': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_1_resin',
    name: 'Resin Patch',
    enemyIds: <String>['enemy_rust_slug', 'enemy_glowcap', 'enemy_scavenger'],
  ),
  'enemy_set_stage_1_mix_5': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_1_mix_5',
    name: 'Stage 1 Set 5',
    enemyIds: <String>['enemy_scavenger', 'enemy_rust_slug', 'enemy_wisp'],
  ),
  'enemy_set_stage_1_mix_6': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_1_mix_6',
    name: 'Stage 1 Set 6',
    enemyIds: <String>['enemy_mite', 'enemy_glowcap', 'enemy_wisp'],
  ),
  'enemy_set_stage_1_mix_7': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_1_mix_7',
    name: 'Stage 1 Set 7',
    enemyIds: <String>['enemy_rust_slug', 'enemy_mite', 'enemy_glowcap'],
  ),
  'enemy_set_stage_1_mix_8': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_1_mix_8',
    name: 'Stage 1 Set 8',
    enemyIds: <String>['enemy_scavenger', 'enemy_glowcap'],
  ),
  'enemy_set_stage_1_mix_9': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_1_mix_9',
    name: 'Stage 1 Set 9',
    enemyIds: <String>['enemy_rust_slug', 'enemy_wisp'],
  ),
  'enemy_set_stage_1_mix_10': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_1_mix_10',
    name: 'Stage 1 Set 10',
    enemyIds: <String>['enemy_scavenger', 'enemy_mite', 'enemy_glowcap'],
  ),
};

const List<BattleStageEncounterDefinitionDto> stage1BattleStageEncounterDtos =
    <BattleStageEncounterDefinitionDto>[
      BattleStageEncounterDefinitionDto(
        id: 'stage_1_patrol',
        enemySetId: 'enemy_set_stage_1_patrol',
        chance: 0.16,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_1_haunt',
        enemySetId: 'enemy_set_stage_1_haunt',
        chance: 0.13,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_1_swarm',
        enemySetId: 'enemy_set_stage_1_swarm',
        chance: 0.11,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_1_resin',
        enemySetId: 'enemy_set_stage_1_resin',
        chance: 0.11,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_1_mix_5',
        enemySetId: 'enemy_set_stage_1_mix_5',
        chance: 0.1,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_1_mix_6',
        enemySetId: 'enemy_set_stage_1_mix_6',
        chance: 0.09,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_1_mix_7',
        enemySetId: 'enemy_set_stage_1_mix_7',
        chance: 0.09,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_1_mix_8',
        enemySetId: 'enemy_set_stage_1_mix_8',
        chance: 0.08,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_1_mix_9',
        enemySetId: 'enemy_set_stage_1_mix_9',
        chance: 0.07,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_1_mix_10',
        enemySetId: 'enemy_set_stage_1_mix_10',
        chance: 0.06,
      ),
    ];
