import 'battle_models.dart';

class BattleState {
  const BattleState({required this.progress});

  final ProgressState progress;

  BattleState copyWith({ProgressState? progress}) {
    return BattleState(progress: progress ?? this.progress);
  }
}
