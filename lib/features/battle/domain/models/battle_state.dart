import 'battle_models.dart';

class BattleState {
  const BattleState({
    required this.progress,
    this.stageAssignments = const <String, List<String>>{},
  });

  final ProgressState progress;
  final Map<String, List<String>> stageAssignments;

  BattleState copyWith({
    ProgressState? progress,
    Map<String, List<String>>? stageAssignments,
  }) {
    return BattleState(
      progress: progress ?? this.progress,
      stageAssignments: stageAssignments ?? this.stageAssignments,
    );
  }
}
