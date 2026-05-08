import 'battle_models.dart';

class BattleState {
  const BattleState({
    required this.progress,
    this.stageAssignments = const <String, List<String>>{},
    this.stagePotionLoadouts = const <String, Map<String, int>>{},
    this.stageExpeditions = const <String, BattleExpeditionState>{},
  });

  final ProgressState progress;
  final Map<String, List<String>> stageAssignments;
  final Map<String, Map<String, int>> stagePotionLoadouts;
  final Map<String, BattleExpeditionState> stageExpeditions;

  BattleState copyWith({
    ProgressState? progress,
    Map<String, List<String>>? stageAssignments,
    Map<String, Map<String, int>>? stagePotionLoadouts,
    Map<String, BattleExpeditionState>? stageExpeditions,
  }) {
    return BattleState(
      progress: progress ?? this.progress,
      stageAssignments: stageAssignments ?? this.stageAssignments,
      stagePotionLoadouts: stagePotionLoadouts ?? this.stagePotionLoadouts,
      stageExpeditions: stageExpeditions ?? this.stageExpeditions,
    );
  }
}
