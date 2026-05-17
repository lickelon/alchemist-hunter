import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemySetDefinition>
stage4BattleEnemySetDefinitions = <String, BattleEnemySetDefinition>{
  'enemy_set_stage_4_lattice': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_lattice',
    name: 'Storm Lattice',
    enemyIds: <String>['enemy_sniper', 'enemy_weaver', 'enemy_tempest'],
  ),
  'enemy_set_stage_4_volley': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_volley',
    name: 'Phantom Volley',
    enemyIds: <String>['enemy_sniper', 'enemy_weaver', 'enemy_mirage'],
  ),
  'enemy_set_stage_4_hunt': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_hunt',
    name: 'Chain Hunt',
    enemyIds: <String>['enemy_sniper', 'enemy_tempest', 'enemy_mirage'],
  ),
  'enemy_set_stage_4_conduit': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_conduit',
    name: 'Storm Conduit',
    enemyIds: <String>[
      'enemy_thunder_moth',
      'enemy_gale_channeler',
      'enemy_tempest',
    ],
  ),
  'enemy_set_stage_4_mix_5': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_5',
    name: 'Stage 4 Set 5',
    enemyIds: <String>[
      'enemy_sniper',
      'enemy_thunder_moth',
      'enemy_gale_channeler',
    ],
  ),
  'enemy_set_stage_4_mix_6': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_6',
    name: 'Stage 4 Set 6',
    enemyIds: <String>['enemy_weaver', 'enemy_thunder_moth', 'enemy_mirage'],
  ),
  'enemy_set_stage_4_mix_7': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_7',
    name: 'Stage 4 Set 7',
    enemyIds: <String>['enemy_gale_channeler', 'enemy_sniper', 'enemy_mirage'],
  ),
  'enemy_set_stage_4_mix_8': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_8',
    name: 'Stage 4 Set 8',
    enemyIds: <String>['enemy_tempest', 'enemy_thunder_moth', 'enemy_mirage'],
  ),
  'enemy_set_stage_4_mix_9': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_9',
    name: 'Stage 4 Set 9',
    enemyIds: <String>['enemy_weaver', 'enemy_gale_channeler', 'enemy_sniper'],
  ),
  'enemy_set_stage_4_mix_10': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_mix_10',
    name: 'Stage 4 Set 10',
    enemyIds: <String>[
      'enemy_thunder_moth',
      'enemy_gale_channeler',
      'enemy_mirage',
    ],
  ),
};

const List<BattleStageEncounterDefinition> stage4BattleStageEncounters =
    <BattleStageEncounterDefinition>[
      BattleStageEncounterDefinition(
        id: 'stage_4_lattice',
        enemySetId: 'enemy_set_stage_4_lattice',
        chance: 0.15,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_volley',
        enemySetId: 'enemy_set_stage_4_volley',
        chance: 0.14,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_hunt',
        enemySetId: 'enemy_set_stage_4_hunt',
        chance: 0.13,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_conduit',
        enemySetId: 'enemy_set_stage_4_conduit',
        chance: 0.12,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_5',
        enemySetId: 'enemy_set_stage_4_mix_5',
        chance: 0.1,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_6',
        enemySetId: 'enemy_set_stage_4_mix_6',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_7',
        enemySetId: 'enemy_set_stage_4_mix_7',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_8',
        enemySetId: 'enemy_set_stage_4_mix_8',
        chance: 0.07,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_9',
        enemySetId: 'enemy_set_stage_4_mix_9',
        chance: 0.06,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_4_mix_10',
        enemySetId: 'enemy_set_stage_4_mix_10',
        chance: 0.05,
      ),
    ];
