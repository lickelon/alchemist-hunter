import '../battle_catalog_dtos.dart';

const Map<String, BattleEnemySetDefinitionDto>
stage3BattleEnemySetDefinitionDtos = <String, BattleEnemySetDefinitionDto>{
  'enemy_set_stage_3_furnace': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_3_furnace',
    name: 'Furnace Front',
    enemyIds: <String>['enemy_sentinel', 'enemy_crucible', 'enemy_apprentice'],
  ),
  'enemy_set_stage_3_relay': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_3_relay',
    name: 'Arcane Relay',
    enemyIds: <String>['enemy_sentinel', 'enemy_apprentice', 'enemy_distiller'],
  ),
  'enemy_set_stage_3_overheat': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_3_overheat',
    name: 'Overheat Wing',
    enemyIds: <String>['enemy_crucible', 'enemy_apprentice', 'enemy_distiller'],
  ),
  'enemy_set_stage_3_engraving': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_3_engraving',
    name: 'Cinder Engraving',
    enemyIds: <String>[
      'enemy_furnace_leech',
      'enemy_cinder_scribe',
      'enemy_crucible',
    ],
  ),
  'enemy_set_stage_3_mix_5': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_3_mix_5',
    name: 'Stage 3 Set 5',
    enemyIds: <String>[
      'enemy_sentinel',
      'enemy_furnace_leech',
      'enemy_cinder_scribe',
    ],
  ),
  'enemy_set_stage_3_mix_6': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_3_mix_6',
    name: 'Stage 3 Set 6',
    enemyIds: <String>[
      'enemy_distiller',
      'enemy_furnace_leech',
      'enemy_apprentice',
    ],
  ),
  'enemy_set_stage_3_mix_7': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_3_mix_7',
    name: 'Stage 3 Set 7',
    enemyIds: <String>[
      'enemy_sentinel',
      'enemy_cinder_scribe',
      'enemy_distiller',
    ],
  ),
  'enemy_set_stage_3_mix_8': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_3_mix_8',
    name: 'Stage 3 Set 8',
    enemyIds: <String>[
      'enemy_crucible',
      'enemy_furnace_leech',
      'enemy_distiller',
    ],
  ),
  'enemy_set_stage_3_mix_9': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_3_mix_9',
    name: 'Stage 3 Set 9',
    enemyIds: <String>[
      'enemy_sentinel',
      'enemy_cinder_scribe',
      'enemy_apprentice',
    ],
  ),
  'enemy_set_stage_3_mix_10': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_3_mix_10',
    name: 'Stage 3 Set 10',
    enemyIds: <String>[
      'enemy_furnace_leech',
      'enemy_cinder_scribe',
      'enemy_distiller',
    ],
  ),
};

const List<BattleStageEncounterDefinitionDto> stage3BattleStageEncounterDtos =
    <BattleStageEncounterDefinitionDto>[
      BattleStageEncounterDefinitionDto(
        id: 'stage_3_furnace',
        enemySetId: 'enemy_set_stage_3_furnace',
        chance: 0.15,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_3_relay',
        enemySetId: 'enemy_set_stage_3_relay',
        chance: 0.14,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_3_overheat',
        enemySetId: 'enemy_set_stage_3_overheat',
        chance: 0.13,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_3_engraving',
        enemySetId: 'enemy_set_stage_3_engraving',
        chance: 0.12,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_3_mix_5',
        enemySetId: 'enemy_set_stage_3_mix_5',
        chance: 0.1,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_3_mix_6',
        enemySetId: 'enemy_set_stage_3_mix_6',
        chance: 0.09,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_3_mix_7',
        enemySetId: 'enemy_set_stage_3_mix_7',
        chance: 0.09,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_3_mix_8',
        enemySetId: 'enemy_set_stage_3_mix_8',
        chance: 0.07,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_3_mix_9',
        enemySetId: 'enemy_set_stage_3_mix_9',
        chance: 0.06,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_3_mix_10',
        enemySetId: 'enemy_set_stage_3_mix_10',
        chance: 0.05,
      ),
    ];
