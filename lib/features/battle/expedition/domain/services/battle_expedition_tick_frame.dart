part of 'battle_expedition_tick_service.dart';

class _BattleExpeditionTickFrame {
  _BattleExpeditionTickFrame({
    required this.state,
    required this.stageId,
    required this.assignedCharacterIds,
    required this.stageDefinition,
    required this.battleActionInterval,
    required this.speedMultiplier,
    required this.battleExpeditionResolver,
    required this.battleCatalogRepository,
    required this.nextCharacters,
    required this.nextProgress,
    required this.nextStatus,
    required this.nextPhaseProgress,
    required this.runState,
    required this.pendingClaim,
    required this.recentLogs,
    required this.remainingElapsed,
    required this.cursorTime,
  }) : pendingClaimElapsedRealTime = pendingClaim.elapsedRealTime;

  final SessionState state;
  final String stageId;
  final List<String> assignedCharacterIds;
  final BattleStageDefinition stageDefinition;
  final Duration battleActionInterval;
  final double speedMultiplier;
  final BattleExpeditionResolver battleExpeditionResolver;
  final BattleCatalogRepository battleCatalogRepository;
  final Map<String, int> consumedPotionStacks = <String, int>{};

  CharactersState nextCharacters;
  ProgressState nextProgress;
  BattleExpeditionStatus nextStatus;
  Duration nextPhaseProgress;
  BattleRunState? runState;
  BattlePendingClaim pendingClaim;
  Duration pendingClaimElapsedRealTime;
  List<BattleLogEntry> recentLogs;
  Duration remainingElapsed;
  DateTime cursorTime;

  Duration advancePhase({
    required Duration targetDuration,
    required BattleExpeditionProgressHelpers helpers,
  }) {
    final Duration consumed = helpers.minDuration(
      remainingElapsed,
      targetDuration - nextPhaseProgress,
    );
    nextPhaseProgress += consumed;
    remainingElapsed -= consumed;
    pendingClaimElapsedRealTime += consumed;
    cursorTime = cursorTime.add(
      helpers.unscaledDuration(consumed, speedMultiplier),
    );
    return consumed;
  }

  void recordConsumedPotionLoadout(Map<String, int> loadout) {
    loadout.forEach((String stackKey, int quantity) {
      consumedPotionStacks[stackKey] =
          (consumedPotionStacks[stackKey] ?? 0) + quantity;
    });
  }
}
