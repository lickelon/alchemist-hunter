import '../battle_catalog_dtos.dart';

import 'stage_1_enemies.dart';
import 'stage_2_enemies.dart';
import 'stage_3_enemies.dart';
import 'stage_4_enemies.dart';
import 'stage_5_enemies.dart';

const Map<String, BattleEnemyDefinitionDto> battleEnemyDefinitionDtos =
    <String, BattleEnemyDefinitionDto>{
      ...stage1BattleEnemyDefinitionDtos,
      ...stage2BattleEnemyDefinitionDtos,
      ...stage3BattleEnemyDefinitionDtos,
      ...stage4BattleEnemyDefinitionDtos,
      ...stage5BattleEnemyDefinitionDtos,
    };
