import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';

class BattleProgressionService {
  const BattleProgressionService();

  bool isStageUnlocked({
    required ProgressState progress,
    required BattleStageDefinition stage,
  }) {
    final BattleStageUnlockCondition? condition = stage.unlockCondition;
    if (condition == null) {
      return true;
    }
    if (progress.unlockedStageIds.contains(stage.id)) {
      return true;
    }
    return (progress.stageBestWinStreaks[condition.requiredStageId] ?? 0) >=
        condition.requiredWinStreakCount;
  }

  String lockReason(BattleStageDefinition stage, {ProgressState? progress}) {
    final BattleStageUnlockCondition? condition = stage.unlockCondition;
    if (condition == null) {
      return '';
    }
    if (progress == null) {
      return condition.label;
    }
    final int current =
        progress.stageCurrentWinStreaks[condition.requiredStageId] ?? 0;
    return '${condition.label} (현재 $current/${condition.requiredWinStreakCount})';
  }

  ProgressState applyStageEncounterResult({
    required ProgressState currentProgress,
    required BattleStageDefinition stage,
    required bool success,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    final Map<String, int> currentStreaks = <String, int>{
      ...currentProgress.stageCurrentWinStreaks,
    };
    final Map<String, int> bestStreaks = <String, int>{
      ...currentProgress.stageBestWinStreaks,
    };
    final int nextCurrentStreak = success
        ? (currentStreaks[stage.id] ?? 0) + 1
        : 0;
    currentStreaks[stage.id] = nextCurrentStreak;
    if (success) {
      final int previousBest = bestStreaks[stage.id] ?? 0;
      if (nextCurrentStreak > previousBest) {
        bestStreaks[stage.id] = nextCurrentStreak;
      }
    }

    ProgressState nextProgress = currentProgress.copyWith(
      clearedStageIds: success
          ? <String>{...currentProgress.clearedStageIds, stage.id}
          : currentProgress.clearedStageIds,
      unlockFlags: success
          ? <String>{
              ...currentProgress.unlockFlags,
              ...stage.clearUnlockFlags.where(
                (String flag) => !flag.startsWith('stage_'),
              ),
            }
          : currentProgress.unlockFlags,
      stageCurrentWinStreaks: currentStreaks,
      stageBestWinStreaks: bestStreaks,
    );

    final Set<String> unlockedStageIds = <String>{
      ...nextProgress.unlockedStageIds,
    };
    for (final String stageId in battleCatalogRepository.stageCatalog()) {
      final BattleStageDefinition candidate = battleCatalogRepository
          .stageDefinition(stageId);
      if (candidate.unlockCondition == null) {
        continue;
      }
      if (isStageUnlocked(progress: nextProgress, stage: candidate)) {
        unlockedStageIds.add(candidate.id);
      }
    }
    nextProgress = nextProgress.copyWith(unlockedStageIds: unlockedStageIds);
    return nextProgress;
  }

  ProgressState applyStageClearUnlocks({
    required ProgressState currentProgress,
    required BattleStageDefinition clearedStage,
    required bool success,
  }) {
    if (!success) {
      return currentProgress;
    }
    return currentProgress.copyWith(
      clearedStageIds: <String>{
        ...currentProgress.clearedStageIds,
        clearedStage.id,
      },
      unlockFlags: <String>{
        ...currentProgress.unlockFlags,
        ...clearedStage.clearUnlockFlags.where(
          (String flag) => !flag.startsWith('stage_'),
        ),
      },
    );
  }
}
