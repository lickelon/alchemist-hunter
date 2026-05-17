import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemySetDefinition>
stage2BattleEnemySetDefinitions = <String, BattleEnemySetDefinition>{
  'enemy_set_stage_2_crossfire': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_crossfire',
    name: 'Crossfire Line',
    enemyIds: <String>['enemy_scout', 'enemy_stalker', 'enemy_bruiser'],
  ),
  'enemy_set_stage_2_ambush': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_ambush',
    name: 'Ambush Knot',
    enemyIds: <String>['enemy_scout', 'enemy_stalker', 'enemy_raider'],
  ),
  'enemy_set_stage_2_assault': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_assault',
    name: 'Assault Wedge',
    enemyIds: <String>['enemy_scout', 'enemy_bruiser', 'enemy_raider'],
  ),
  'enemy_set_stage_2_salvage': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_salvage',
    name: 'Salvage Guard',
    enemyIds: <String>['enemy_glassback', 'enemy_dust_mender', 'enemy_raider'],
  ),
  'enemy_set_stage_2_mix_5': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_5',
    name: 'Stage 2 Set 5',
    enemyIds: <String>['enemy_stalker', 'enemy_glassback', 'enemy_scout'],
  ),
  'enemy_set_stage_2_mix_6': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_6',
    name: 'Stage 2 Set 6',
    enemyIds: <String>['enemy_bruiser', 'enemy_dust_mender', 'enemy_scout'],
  ),
  'enemy_set_stage_2_mix_7': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_7',
    name: 'Stage 2 Set 7',
    enemyIds: <String>['enemy_glassback', 'enemy_stalker', 'enemy_dust_mender'],
  ),
  'enemy_set_stage_2_mix_8': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_8',
    name: 'Stage 2 Set 8',
    enemyIds: <String>['enemy_raider', 'enemy_stalker', 'enemy_dust_mender'],
  ),
  'enemy_set_stage_2_mix_9': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_9',
    name: 'Stage 2 Set 9',
    enemyIds: <String>['enemy_bruiser', 'enemy_glassback', 'enemy_raider'],
  ),
  'enemy_set_stage_2_mix_10': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_mix_10',
    name: 'Stage 2 Set 10',
    enemyIds: <String>['enemy_scout', 'enemy_glassback', 'enemy_dust_mender'],
  ),
};

const List<BattleStageEncounterDefinition> stage2BattleStageEncounters =
    <BattleStageEncounterDefinition>[
      BattleStageEncounterDefinition(
        id: 'stage_2_crossfire',
        enemySetId: 'enemy_set_stage_2_crossfire',
        chance: 0.16,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_ambush',
        enemySetId: 'enemy_set_stage_2_ambush',
        chance: 0.14,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_assault',
        enemySetId: 'enemy_set_stage_2_assault',
        chance: 0.13,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_salvage',
        enemySetId: 'enemy_set_stage_2_salvage',
        chance: 0.12,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_5',
        enemySetId: 'enemy_set_stage_2_mix_5',
        chance: 0.1,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_6',
        enemySetId: 'enemy_set_stage_2_mix_6',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_7',
        enemySetId: 'enemy_set_stage_2_mix_7',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_8',
        enemySetId: 'enemy_set_stage_2_mix_8',
        chance: 0.07,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_9',
        enemySetId: 'enemy_set_stage_2_mix_9',
        chance: 0.06,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_2_mix_10',
        enemySetId: 'enemy_set_stage_2_mix_10',
        chance: 0.04,
      ),
    ];
