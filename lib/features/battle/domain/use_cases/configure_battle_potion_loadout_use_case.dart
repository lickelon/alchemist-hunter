import 'package:alchemist_hunter/app/session/app_session.dart';

class ConfigureBattlePotionLoadoutUseCase {
  const ConfigureBattlePotionLoadoutUseCase();

  SessionState setPotionCount({
    required SessionState state,
    required String stageId,
    required String potionStackKey,
    required int count,
    required int maxOwned,
  }) {
    final int nextCount = count.clamp(0, maxOwned);
    final Map<String, Map<String, int>> nextLoadouts =
        <String, Map<String, int>>{
          ...state.battle.stagePotionLoadouts.map(
            (String key, Map<String, int> value) =>
                MapEntry<String, Map<String, int>>(key, <String, int>{...value}),
          ),
        };
    final Map<String, int> stageLoadout = <String, int>{
      ...nextLoadouts[stageId] ?? const <String, int>{},
    };

    if (nextCount == 0) {
      stageLoadout.remove(potionStackKey);
    } else {
      stageLoadout[potionStackKey] = nextCount;
    }

    if (stageLoadout.isEmpty) {
      nextLoadouts.remove(stageId);
    } else {
      nextLoadouts[stageId] = stageLoadout;
    }

    return state.copyWith(
      battle: state.battle.copyWith(stagePotionLoadouts: nextLoadouts),
    );
  }
}
