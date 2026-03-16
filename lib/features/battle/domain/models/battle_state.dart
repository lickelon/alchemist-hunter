import 'battle_models.dart';

class BattleState {
  const BattleState({
    required this.progress,
    this.stageAssignments = const <String, List<String>>{},
    this.stageExpeditions = const <String, BattleExpeditionState>{},
  });

  final ProgressState progress;
  final Map<String, List<String>> stageAssignments;
  final Map<String, BattleExpeditionState> stageExpeditions;

  BattleState copyWith({
    ProgressState? progress,
    Map<String, List<String>>? stageAssignments,
    Map<String, BattleExpeditionState>? stageExpeditions,
  }) {
    return BattleState(
      progress: progress ?? this.progress,
      stageAssignments: stageAssignments ?? this.stageAssignments,
      stageExpeditions: stageExpeditions ?? this.stageExpeditions,
    );
  }
}
