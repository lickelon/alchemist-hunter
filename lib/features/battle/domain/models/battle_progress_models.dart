import 'package:flutter/foundation.dart';

enum SessionPhase { early, mid, late }

@immutable
class ProgressState {
  const ProgressState({
    required this.unlockFlags,
    required this.clearedStageIds,
    required this.automationTier,
    required this.sessionPhase,
  });

  final Set<String> unlockFlags;
  final Set<String> clearedStageIds;
  final int automationTier;
  final SessionPhase sessionPhase;

  ProgressState copyWith({
    Set<String>? unlockFlags,
    Set<String>? clearedStageIds,
    int? automationTier,
    SessionPhase? sessionPhase,
  }) {
    return ProgressState(
      unlockFlags: unlockFlags ?? this.unlockFlags,
      clearedStageIds: clearedStageIds ?? this.clearedStageIds,
      automationTier: automationTier ?? this.automationTier,
      sessionPhase: sessionPhase ?? this.sessionPhase,
    );
  }
}
