part of 'town_skill_tree_service.dart';

int townSkillDiscountedGoldCost({
  required int baseCost,
  required double discountRate,
}) {
  if (baseCost <= 0 || discountRate <= 0) {
    return baseCost;
  }
  return max(0, (baseCost * (1 - discountRate)).round());
}

Map<String, int> townSkillAdjustedMaterialCosts({
  required Map<String, int> baseCosts,
  required double efficiencyRate,
}) {
  if (efficiencyRate <= 0 || baseCosts.isEmpty) {
    return <String, int>{...baseCosts};
  }

  final Map<String, int> adjusted = <String, int>{...baseCosts};
  final int totalCost = adjusted.values.fold<int>(
    0,
    (int sum, int value) => sum + value,
  );
  final int minimumTotal = adjusted.length;
  final int maxReducible = totalCost - minimumTotal;
  if (maxReducible <= 0) {
    return adjusted;
  }

  int remainingReduction = min(
    maxReducible,
    max(1, (totalCost * efficiencyRate).round()),
  );

  while (remainingReduction > 0) {
    final List<MapEntry<String, int>> entries = adjusted.entries.toList()
      ..sort(
        (MapEntry<String, int> left, MapEntry<String, int> right) =>
            right.value.compareTo(left.value),
      );

    bool changed = false;
    for (final MapEntry<String, int> entry in entries) {
      if (entry.value <= 1) {
        continue;
      }
      adjusted[entry.key] = entry.value - 1;
      remainingReduction -= 1;
      changed = true;
      if (remainingReduction <= 0) {
        break;
      }
    }
    if (!changed) {
      break;
    }
  }

  return adjusted;
}
