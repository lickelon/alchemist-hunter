import 'package:alchemist_hunter/features/battle/domain/models.dart';

import 'stage_1_encounters.dart';
import 'stage_2_encounters.dart';
import 'stage_3_encounters.dart';
import 'stage_4_encounters.dart';
import 'stage_5_encounters.dart';

const Map<String, BattleEnemySetDefinition> battleEnemySetDefinitions =
    <String, BattleEnemySetDefinition>{
      ...stage1BattleEnemySetDefinitions,
      ...stage2BattleEnemySetDefinitions,
      ...stage3BattleEnemySetDefinitions,
      ...stage4BattleEnemySetDefinitions,
      ...stage5BattleEnemySetDefinitions,
    };
