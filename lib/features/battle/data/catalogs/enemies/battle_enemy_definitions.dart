import 'package:alchemist_hunter/features/battle/domain/models.dart';

import 'stage_1_enemies.dart';
import 'stage_2_enemies.dart';
import 'stage_3_enemies.dart';
import 'stage_4_enemies.dart';
import 'stage_5_enemies.dart';

const Map<String, BattleEnemyDefinition> battleEnemyDefinitions =
    <String, BattleEnemyDefinition>{
      ...stage1BattleEnemyDefinitions,
      ...stage2BattleEnemyDefinitions,
      ...stage3BattleEnemyDefinitions,
      ...stage4BattleEnemyDefinitions,
      ...stage5BattleEnemyDefinitions,
    };
