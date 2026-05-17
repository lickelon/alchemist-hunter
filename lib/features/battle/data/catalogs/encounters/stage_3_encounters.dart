import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemySetDefinition>
stage3BattleEnemySetDefinitions = <String, BattleEnemySetDefinition>{
  'enemy_set_stage_3_furnace': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_furnace',
    name: 'Furnace Front',
    enemyIds: <String>['enemy_sentinel', 'enemy_crucible', 'enemy_apprentice'],
  ),
  'enemy_set_stage_3_relay': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_relay',
    name: 'Arcane Relay',
    enemyIds: <String>['enemy_sentinel', 'enemy_apprentice', 'enemy_distiller'],
  ),
  'enemy_set_stage_3_overheat': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_overheat',
    name: 'Overheat Wing',
    enemyIds: <String>['enemy_crucible', 'enemy_apprentice', 'enemy_distiller'],
  ),
  'enemy_set_stage_3_engraving': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_engraving',
    name: 'Cinder Engraving',
    enemyIds: <String>[
      'enemy_furnace_leech',
      'enemy_cinder_scribe',
      'enemy_crucible',
    ],
  ),
  'enemy_set_stage_3_mix_5': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_5',
    name: 'Stage 3 Set 5',
    enemyIds: <String>[
      'enemy_sentinel',
      'enemy_furnace_leech',
      'enemy_cinder_scribe',
    ],
  ),
  'enemy_set_stage_3_mix_6': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_6',
    name: 'Stage 3 Set 6',
    enemyIds: <String>[
      'enemy_distiller',
      'enemy_furnace_leech',
      'enemy_apprentice',
    ],
  ),
  'enemy_set_stage_3_mix_7': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_7',
    name: 'Stage 3 Set 7',
    enemyIds: <String>[
      'enemy_sentinel',
      'enemy_cinder_scribe',
      'enemy_distiller',
    ],
  ),
  'enemy_set_stage_3_mix_8': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_8',
    name: 'Stage 3 Set 8',
    enemyIds: <String>[
      'enemy_crucible',
      'enemy_furnace_leech',
      'enemy_distiller',
    ],
  ),
  'enemy_set_stage_3_mix_9': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_9',
    name: 'Stage 3 Set 9',
    enemyIds: <String>[
      'enemy_sentinel',
      'enemy_cinder_scribe',
      'enemy_apprentice',
    ],
  ),
  'enemy_set_stage_3_mix_10': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_mix_10',
    name: 'Stage 3 Set 10',
    enemyIds: <String>[
      'enemy_furnace_leech',
      'enemy_cinder_scribe',
      'enemy_distiller',
    ],
  ),
};

const List<BattleStageEncounterDefinition> stage3BattleStageEncounters =
    <BattleStageEncounterDefinition>[
      BattleStageEncounterDefinition(
        id: 'stage_3_furnace',
        enemySetId: 'enemy_set_stage_3_furnace',
        chance: 0.15,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_relay',
        enemySetId: 'enemy_set_stage_3_relay',
        chance: 0.14,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_overheat',
        enemySetId: 'enemy_set_stage_3_overheat',
        chance: 0.13,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_engraving',
        enemySetId: 'enemy_set_stage_3_engraving',
        chance: 0.12,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_5',
        enemySetId: 'enemy_set_stage_3_mix_5',
        chance: 0.1,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_6',
        enemySetId: 'enemy_set_stage_3_mix_6',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_7',
        enemySetId: 'enemy_set_stage_3_mix_7',
        chance: 0.09,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_8',
        enemySetId: 'enemy_set_stage_3_mix_8',
        chance: 0.07,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_9',
        enemySetId: 'enemy_set_stage_3_mix_9',
        chance: 0.06,
      ),
      BattleStageEncounterDefinition(
        id: 'stage_3_mix_10',
        enemySetId: 'enemy_set_stage_3_mix_10',
        chance: 0.05,
      ),
    ];
