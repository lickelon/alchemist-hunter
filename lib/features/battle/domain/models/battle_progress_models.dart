import 'package:flutter/foundation.dart';

enum SessionPhase { early, mid, late }

@immutable
class ProgressState {
  const ProgressState({
    required this.unlockFlags,
    required this.clearedStageIds,
    this.unlockedStageIds = const <String>{},
    this.stageCurrentWinStreaks = const <String, int>{},
    this.stageBestWinStreaks = const <String, int>{},
    required this.automationTier,
    required this.sessionPhase,
  });

  final Set<String> unlockFlags;
  final Set<String> clearedStageIds;
  final Set<String> unlockedStageIds;
  final Map<String, int> stageCurrentWinStreaks;
  final Map<String, int> stageBestWinStreaks;
  final int automationTier;
  final SessionPhase sessionPhase;

  ProgressState copyWith({
    Set<String>? unlockFlags,
    Set<String>? clearedStageIds,
    Set<String>? unlockedStageIds,
    Map<String, int>? stageCurrentWinStreaks,
    Map<String, int>? stageBestWinStreaks,
    int? automationTier,
    SessionPhase? sessionPhase,
  }) {
    return ProgressState(
      unlockFlags: unlockFlags ?? this.unlockFlags,
      clearedStageIds: clearedStageIds ?? this.clearedStageIds,
      unlockedStageIds: unlockedStageIds ?? this.unlockedStageIds,
      stageCurrentWinStreaks:
          stageCurrentWinStreaks ?? this.stageCurrentWinStreaks,
      stageBestWinStreaks: stageBestWinStreaks ?? this.stageBestWinStreaks,
      automationTier: automationTier ?? this.automationTier,
      sessionPhase: sessionPhase ?? this.sessionPhase,
    );
  }
}
