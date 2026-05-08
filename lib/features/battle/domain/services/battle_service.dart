import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/models.dart';

part 'battle_loop_runner.dart';
part 'battle_attack_resolver.dart';
part 'battle_modifier_resolver.dart';
part 'battle_recovery_resolver.dart';
part 'battle_reward_resolver.dart';
part 'battle_unit.dart';

class BattleService {
  BattleService({Random? random}) : _random = random ?? Random();

  final Random _random;

  BattleResult runAutoBattle({
    required AutoBattleConfig config,
    required BattleStageDefinition stage,
    required List<BattleEnemyDefinition> enemies,
    required BattleDropTable dropTable,
  }) {
    final _BattleLoopResult loopResult = _BattleLoopRunner(
      random: _random,
    ).run(config: config, enemies: enemies);
    final Map<String, int> loot = resolveRewards(
      success: loopResult.success,
      table: dropTable,
    );
    return BattleResult(
      success: loopResult.success,
      turns: loopResult.turns,
      loot: loot,
      failurePenalty: 0,
      actions: loopResult.actions,
    );
  }

  Map<String, int> resolveRewards({
    required bool success,
    required BattleDropTable table,
  }) {
    return _BattleRewardResolver(
      random: _random,
    ).resolve(success: success, table: table);
  }
}
