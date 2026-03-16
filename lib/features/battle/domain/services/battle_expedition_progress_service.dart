import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';

class BattleExpeditionProgressService {
  const BattleExpeditionProgressService();

  BattleState syncExpeditions({
    required SessionState state,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
    required Duration battleCycle,
    required BattleExpeditionResolver battleExpeditionResolver,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    if (state.battle.stageExpeditions.isEmpty) {
      return state.battle;
    }

    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...state.battle.stageExpeditions};

    state.battle.stageExpeditions.forEach((
      String stageId,
      BattleExpeditionState expedition,
    ) {
      if (expedition.status != BattleExpeditionStatus.running) {
        return;
      }

      final DateTime baseTime = _laterOf(
        syncFrom,
        expedition.lastResolvedAt ?? syncFrom,
      );
      if (!now.isAfter(baseTime)) {
        nextExpeditions[stageId] = expedition.copyWith(lastResolvedAt: now);
        return;
      }

      final Duration totalElapsed =
          expedition.cycleProgress +
          _scaledDuration(now.difference(baseTime), speedMultiplier);
      final int cycleCount = totalElapsed.inSeconds ~/ battleCycle.inSeconds;
      final Duration nextProgress = Duration(
        seconds: totalElapsed.inSeconds % battleCycle.inSeconds,
      );

      BattlePendingClaim pendingClaim = expedition.pendingClaim;
      String summary = expedition.lastSummary;
      for (int index = 0; index < cycleCount; index++) {
        final BattleCycleResolution resolution = battleExpeditionResolver
            .resolveCycle(
              state: state,
              stageId: stageId,
              battleCatalogRepository: battleCatalogRepository,
            );
        pendingClaim = _mergePendingClaim(
          pendingClaim,
          resolution.pendingClaim,
        );
        summary = resolution.summary;
      }

      nextExpeditions[stageId] = expedition.copyWith(
        lastResolvedAt: now,
        cycleProgress: nextProgress,
        pendingClaim: pendingClaim,
        lastSummary: summary,
      );
    });

    return state.battle.copyWith(stageExpeditions: nextExpeditions);
  }

  BattlePendingClaim _mergePendingClaim(
    BattlePendingClaim left,
    BattlePendingClaim right,
  ) {
    final Map<String, int> mergedMaterials = <String, int>{...left.materials};
    right.materials.forEach((String key, int value) {
      mergedMaterials[key] = (mergedMaterials[key] ?? 0) + value;
    });
    final Map<String, int> mergedXp = <String, int>{...left.characterXp};
    right.characterXp.forEach((String key, int value) {
      mergedXp[key] = (mergedXp[key] ?? 0) + value;
    });
    return BattlePendingClaim(
      materials: mergedMaterials,
      gold: left.gold + right.gold,
      essence: left.essence + right.essence,
      characterXp: mergedXp,
    );
  }

  DateTime _laterOf(DateTime left, DateTime right) {
    return left.isAfter(right) ? left : right;
  }

  Duration _scaledDuration(Duration source, double multiplier) {
    if (multiplier <= 1) {
      return source;
    }
    return Duration(microseconds: (source.inMicroseconds * multiplier).round());
  }
}
