import 'package:alchemist_hunter/features/battle/domain/models.dart';

class BattleProgressionService {
  const BattleProgressionService();

  bool isStageUnlocked({
    required ProgressState progress,
    required BattleStageDefinition stage,
  }) {
    if (stage.unlockCondition == null) {
      return true;
    }
    return progress.unlockFlags.contains(stage.id);
  }

  String lockReason(BattleStageDefinition stage) {
    return stage.unlockCondition?.label ?? '';
  }

  Set<String> applyStageClearUnlocks({
    required Set<String> currentUnlockFlags,
    required BattleStageDefinition clearedStage,
    required bool success,
  }) {
    if (!success) {
      return currentUnlockFlags;
    }
    return <String>{
      ...currentUnlockFlags,
      clearedStage.id,
      ...clearedStage.clearUnlockFlags,
    };
  }
}
