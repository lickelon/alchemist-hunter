import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/expedition/domain/services/battle_progression_service.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../support/catalog_fixtures.dart';

void main() {
  const BattleProgressionService service = BattleProgressionService();
  final repository = testBattleCatalogRepository;

  test('stage unlocks depend on previous stage win streak', () {
    const ProgressState progress = ProgressState(
      unlockFlags: <String>{'stage_2'},
      clearedStageIds: <String>{'stage_1'},
      stageBestWinStreaks: <String, int>{'stage_1': 2},
      automationTier: 1,
      sessionPhase: SessionPhase.early,
    );

    final bool unlocked = service.isStageUnlocked(
      progress: progress,
      stage: repository.stageDefinition('stage_2'),
    );

    expect(unlocked, isFalse);
  });

  test('stage unlocks after required previous stage streak', () {
    const ProgressState progress = ProgressState(
      unlockFlags: <String>{},
      clearedStageIds: <String>{'stage_1'},
      stageBestWinStreaks: <String, int>{'stage_1': 3},
      automationTier: 1,
      sessionPhase: SessionPhase.early,
    );

    final bool unlocked = service.isStageUnlocked(
      progress: progress,
      stage: repository.stageDefinition('stage_2'),
    );

    expect(unlocked, isTrue);
  });

  test('stage encounter result increments streak and unlocks next stage', () {
    const ProgressState progress = ProgressState(
      unlockFlags: <String>{},
      clearedStageIds: <String>{},
      stageCurrentWinStreaks: <String, int>{'stage_1': 2},
      stageBestWinStreaks: <String, int>{'stage_1': 2},
      automationTier: 1,
      sessionPhase: SessionPhase.early,
    );

    final ProgressState nextProgress = service.applyStageEncounterResult(
      currentProgress: progress,
      stage: repository.stageDefinition('stage_1'),
      success: true,
      battleCatalogRepository: repository,
    );

    expect(nextProgress.stageCurrentWinStreaks['stage_1'], 3);
    expect(nextProgress.stageBestWinStreaks['stage_1'], 3);
    expect(nextProgress.clearedStageIds, contains('stage_1'));
    expect(nextProgress.unlockedStageIds, contains('stage_2'));
    expect(nextProgress.unlockFlags, isNot(contains('stage_2')));
  });

  test('stage encounter failure resets current streak only', () {
    const ProgressState progress = ProgressState(
      unlockFlags: <String>{},
      clearedStageIds: <String>{'stage_1'},
      stageCurrentWinStreaks: <String, int>{'stage_1': 2},
      stageBestWinStreaks: <String, int>{'stage_1': 4},
      automationTier: 1,
      sessionPhase: SessionPhase.early,
    );

    final ProgressState nextProgress = service.applyStageEncounterResult(
      currentProgress: progress,
      stage: repository.stageDefinition('stage_1'),
      success: false,
      battleCatalogRepository: repository,
    );

    expect(nextProgress.stageCurrentWinStreaks['stage_1'], 0);
    expect(nextProgress.stageBestWinStreaks['stage_1'], 4);
    expect(nextProgress.clearedStageIds, contains('stage_1'));
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
