import 'package:alchemist_hunter/features/battle/domain/models.dart';

class BattleExpeditionProgressHelpers {
  const BattleExpeditionProgressHelpers();

  BattlePendingClaim mergePendingClaim(
    BattlePendingClaim left,
    BattlePendingClaim right,
  ) {
    final Map<String, int> mergedMaterials = <String, int>{...left.materials};
    right.materials.forEach((String key, int value) {
      mergedMaterials[key] = (mergedMaterials[key] ?? 0) + value;
    });
    return BattlePendingClaim(
      materials: mergedMaterials,
      gold: left.gold + right.gold,
      essence: left.essence + right.essence,
      xp: left.xp + right.xp,
      hasSuccessfulBattle:
          left.hasSuccessfulBattle || right.hasSuccessfulBattle,
    );
  }

  List<BattleRunUnitState> applySearchRecovery(
    List<BattleRunUnitState> allies,
  ) {
    return allies
        .map((BattleRunUnitState unit) {
          if (!unit.isAlive) {
            return unit;
          }
          final int healing = (unit.maxHp * (0.08 + unit.stats.regen)).ceil();
          final int nextHp = (unit.currentHp + healing).clamp(0, unit.maxHp);
          return unit.copyWith(currentHp: nextHp);
        })
        .toList(growable: false);
  }

  DateTime laterOf(DateTime left, DateTime right) {
    return left.isAfter(right) ? left : right;
  }

  Duration scaledDuration(Duration source, double multiplier) {
    if (multiplier <= 1) {
      return source;
    }
    return Duration(microseconds: (source.inMicroseconds * multiplier).round());
  }

  Duration unscaledDuration(Duration source, double multiplier) {
    if (multiplier <= 1) {
      return source;
    }
    return Duration(microseconds: (source.inMicroseconds / multiplier).round());
  }

  Duration minDuration(Duration left, Duration right) {
    return left <= right ? left : right;
  }

  List<BattleLogEntry> mergeRecentLogs(
    List<BattleLogEntry> current,
    BattleLogEntry next,
  ) {
    final List<BattleLogEntry> merged = <BattleLogEntry>[next, ...current];
    if (merged.length <= 10) {
      return merged;
    }
    return merged.sublist(0, 10);
  }
}
