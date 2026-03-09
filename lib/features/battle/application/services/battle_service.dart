import 'dart:math';

import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class BattleService {
  BattleService({Random? random}) : _random = random ?? Random();

  final Random _random;

  BattleResult runAutoBattle({
    required AutoBattleConfig config,
    required BattleDropTable dropTable,
  }) {
    final int partyPower = config.party.fold<int>(0, (int sum, HeroProfile h) => sum + h.power);
    final int potionBoost = config.potionLoadout.values.fold<int>(0, (int s, int v) => s + v);
    final int stagePower = 100 + (config.stageId.codeUnitAt(config.stageId.length - 1) * 3);
    final int score = partyPower + (potionBoost * 5);

    final bool success = score >= stagePower || _random.nextDouble() > 0.35;
    final int turns = success ? 8 + _random.nextInt(6) : 12 + _random.nextInt(8);
    final Map<String, int> loot = resolveRewards(success: success, table: dropTable);
    final int penalty = success ? 0 : 15;

    return BattleResult(
      success: success,
      turns: turns,
      loot: loot,
      failurePenalty: penalty,
    );
  }

  Map<String, int> resolveRewards({
    required bool success,
    required BattleDropTable table,
  }) {
    final Map<String, int> rewards = <String, int>{};

    for (final BattleDropEntry entry in table.normalDrops) {
      if (_random.nextDouble() <= entry.chance) {
        rewards[entry.materialId] = entry.min + _random.nextInt(entry.max - entry.min + 1);
      }
    }

    if (success) {
      for (final BattleDropEntry entry in table.specialDrops) {
        if (_random.nextDouble() <= entry.chance) {
          rewards[entry.materialId] =
              (rewards[entry.materialId] ?? 0) +
              (entry.min + _random.nextInt(entry.max - entry.min + 1));
        }
      }
    }

    return rewards;
  }
}
