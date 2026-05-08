part of 'battle_service.dart';

class _BattleRewardResolver {
  const _BattleRewardResolver({required Random random}) : _random = random;

  final Random _random;

  Map<String, int> resolve({
    required bool success,
    required BattleDropTable table,
  }) {
    if (!success) {
      return const <String, int>{};
    }

    final Map<String, int> rewards = <String, int>{};

    for (final BattleDropEntry entry in table.normalDrops) {
      if (_random.nextDouble() <= entry.chance) {
        rewards[entry.materialId] =
            entry.min + _random.nextInt(entry.max - entry.min + 1);
      }
    }

    for (final BattleDropEntry entry in table.specialDrops) {
      if (_random.nextDouble() <= entry.chance) {
        rewards[entry.materialId] =
            (rewards[entry.materialId] ?? 0) +
            (entry.min + _random.nextInt(entry.max - entry.min + 1));
      }
    }

    return rewards;
  }
}
