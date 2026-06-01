import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/expedition/domain/services/battle_progression_service.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<List<String>> unlockedStageListProvider = Provider<List<String>>(
  (Ref ref) {
    final List<String> stages = ref.watch(stageCatalogProvider);
    final ProgressState progress = ref.watch(battleProgressProvider);
    final BattleCatalogRepository battleCatalog = ref.watch(
      battleCatalogRepositoryProvider,
    );
    const BattleProgressionService progressionService =
        BattleProgressionService();
    return stages
        .where((String stageId) {
          final BattleStageDefinition stage = battleCatalog.stageDefinition(
            stageId,
          );
          return progressionService.isStageUnlocked(
            progress: progress,
            stage: stage,
          );
        })
        .toList(growable: false);
  },
);

final battleStageDisplayNameProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
  final BattleStageDefinition stage = ref
      .watch(battleCatalogRepositoryProvider)
      .stageDefinition(stageId);
  return battleStageDisplayName(stage.id, fallback: stage.name);
});

final Provider<int> battleGoldProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select((SessionState state) => state.player.gold),
  );
});

final Provider<int> battleEssenceProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.player.essence,
    ),
  );
});

final Provider<ProgressState> battleProgressProvider = Provider<ProgressState>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.battle.progress,
    ),
  );
});

final battleStageUnlockedProvider = Provider.family<bool, String>((
  Ref ref,
  String stageId,
) {
  final ProgressState progress = ref.watch(battleProgressProvider);
  final BattleStageDefinition stage = ref
      .watch(battleCatalogRepositoryProvider)
      .stageDefinition(stageId);
  return const BattleProgressionService().isStageUnlocked(
    progress: progress,
    stage: stage,
  );
});

final battleStageLockReasonProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
  final ProgressState progress = ref.watch(battleProgressProvider);
  final BattleStageDefinition stage = ref
      .watch(battleCatalogRepositoryProvider)
      .stageDefinition(stageId);
  return const BattleProgressionService().lockReason(stage, progress: progress);
});
