import 'package:alchemist_hunter/features/battle/domain/models.dart';

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
    return progress.clearedStageIds.contains(condition.requiredStageId);
  }

  String lockReason(BattleStageDefinition stage) {
    return stage.unlockCondition?.label ?? '';
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
