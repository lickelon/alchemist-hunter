import 'package:alchemist_hunter/features/battle/data/repositories/static_battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_progression_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const BattleProgressionService service = BattleProgressionService();
  const StaticBattleCatalogRepository repository = StaticBattleCatalogRepository();

  test('stage unlocks depend on cleared stage ids instead of unlock flags', () {
    const ProgressState progress = ProgressState(
      unlockFlags: <String>{'stage_2'},
      clearedStageIds: <String>{},
      automationTier: 1,
      sessionPhase: SessionPhase.early,
    );

    final bool unlocked = service.isStageUnlocked(
      progress: progress,
      stage: repository.stageDefinition('stage_2'),
    );

    expect(unlocked, isFalse);
  });

  test('stage clear records cleared stage and only non-stage unlock flags', () {
    const ProgressState progress = ProgressState(
      unlockFlags: <String>{},
      clearedStageIds: <String>{'stage_1', 'stage_2'},
      automationTier: 1,
      sessionPhase: SessionPhase.early,
    );

    final ProgressState nextProgress = service.applyStageClearUnlocks(
      currentProgress: progress,
      clearedStage: repository.stageDefinition('stage_3'),
      success: true,
    );

    expect(nextProgress.clearedStageIds, contains('stage_3'));
    expect(nextProgress.unlockFlags, contains('potion_special_1'));
    expect(nextProgress.unlockFlags, isNot(contains('stage_4')));
  });
}
