import '../battle_catalog_dtos.dart';

import 'stage_1_encounters.dart';
import 'stage_2_encounters.dart';
import 'stage_3_encounters.dart';
import 'stage_4_encounters.dart';
import 'stage_5_encounters.dart';

const Map<String, BattleEnemySetDefinitionDto> battleEnemySetDefinitionDtos =
    <String, BattleEnemySetDefinitionDto>{
      ...stage1BattleEnemySetDefinitionDtos,
      ...stage2BattleEnemySetDefinitionDtos,
      ...stage3BattleEnemySetDefinitionDtos,
      ...stage4BattleEnemySetDefinitionDtos,
      ...stage5BattleEnemySetDefinitionDtos,
    };
