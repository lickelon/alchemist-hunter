import 'package:flutter/foundation.dart';

enum SessionPhase { early, mid, late }

@immutable
class ProgressState {
  const ProgressState({
    required this.unlockFlags,
    required this.automationTier,
    required this.sessionPhase,
  });

  final Set<String> unlockFlags;
  final int automationTier;
  final SessionPhase sessionPhase;

  ProgressState copyWith({
    Set<String>? unlockFlags,
    int? automationTier,
    SessionPhase? sessionPhase,
  }) {
    return ProgressState(
      unlockFlags: unlockFlags ?? this.unlockFlags,
      automationTier: automationTier ?? this.automationTier,
      sessionPhase: sessionPhase ?? this.sessionPhase,
    );
  }
}
