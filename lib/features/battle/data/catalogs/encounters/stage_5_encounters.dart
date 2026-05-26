import '../battle_catalog_dtos.dart';

const Map<String, BattleEnemySetDefinitionDto>
stage5BattleEnemySetDefinitionDtos = <String, BattleEnemySetDefinitionDto>{
  'enemy_set_stage_5_guarded': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_5_guarded',
    name: 'Core Keeper',
    enemyIds: <String>['enemy_chimera', 'enemy_warden'],
  ),
  'enemy_set_stage_5_signal': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_5_signal',
    name: 'Signal Choir',
    enemyIds: <String>['enemy_chimera', 'enemy_herald'],
  ),
  'enemy_set_stage_5_awakened': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_5_awakened',
    name: 'Full Awakening',
    enemyIds: <String>['enemy_chimera', 'enemy_herald', 'enemy_warden'],
  ),
  'enemy_set_stage_5_core_line': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_5_core_line',
    name: 'Core Line',
    enemyIds: <String>[
      'enemy_core_siphon',
      'enemy_moonvault_aegis',
      'enemy_herald',
    ],
  ),
  'enemy_set_stage_5_mix_5': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_5_mix_5',
    name: 'Stage 5 Set 5',
    enemyIds: <String>['enemy_chimera', 'enemy_core_siphon'],
  ),
  'enemy_set_stage_5_mix_6': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_5_mix_6',
    name: 'Stage 5 Set 6',
    enemyIds: <String>['enemy_moonvault_aegis', 'enemy_warden', 'enemy_herald'],
  ),
  'enemy_set_stage_5_mix_7': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_5_mix_7',
    name: 'Stage 5 Set 7',
    enemyIds: <String>[
      'enemy_chimera',
      'enemy_core_siphon',
      'enemy_moonvault_aegis',
    ],
  ),
  'enemy_set_stage_5_mix_8': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_5_mix_8',
    name: 'Stage 5 Set 8',
    enemyIds: <String>['enemy_core_siphon', 'enemy_herald'],
  ),
  'enemy_set_stage_5_mix_9': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_5_mix_9',
    name: 'Stage 5 Set 9',
    enemyIds: <String>[
      'enemy_moonvault_aegis',
      'enemy_chimera',
      'enemy_warden',
    ],
  ),
  'enemy_set_stage_5_mix_10': BattleEnemySetDefinitionDto(
    id: 'enemy_set_stage_5_mix_10',
    name: 'Stage 5 Set 10',
    enemyIds: <String>[
      'enemy_core_siphon',
      'enemy_herald',
      'enemy_moonvault_aegis',
    ],
  ),
};

const List<BattleStageEncounterDefinitionDto> stage5BattleStageEncounterDtos =
    <BattleStageEncounterDefinitionDto>[
      BattleStageEncounterDefinitionDto(
        id: 'stage_5_guarded',
        enemySetId: 'enemy_set_stage_5_guarded',
        chance: 0.22,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_5_signal',
        enemySetId: 'enemy_set_stage_5_signal',
        chance: 0.17,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_5_awakened',
        enemySetId: 'enemy_set_stage_5_awakened',
        chance: 0.12,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_5_core_line',
        enemySetId: 'enemy_set_stage_5_core_line',
        chance: 0.1,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_5_mix_5',
        enemySetId: 'enemy_set_stage_5_mix_5',
        chance: 0.09,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_5_mix_6',
        enemySetId: 'enemy_set_stage_5_mix_6',
        chance: 0.08,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_5_mix_7',
        enemySetId: 'enemy_set_stage_5_mix_7',
        chance: 0.07,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_5_mix_8',
        enemySetId: 'enemy_set_stage_5_mix_8',
        chance: 0.06,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_5_mix_9',
        enemySetId: 'enemy_set_stage_5_mix_9',
        chance: 0.05,
      ),
      BattleStageEncounterDefinitionDto(
        id: 'stage_5_mix_10',
        enemySetId: 'enemy_set_stage_5_mix_10',
        chance: 0.04,
      ),
    ];
