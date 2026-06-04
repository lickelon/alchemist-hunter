class WorkshopMaterialCraftRecipeView {
  const WorkshopMaterialCraftRecipeView({
    required this.recipeId,
    required this.title,
    required this.costHint,
    required this.extraCostHint,
    required this.resultMaterialId,
    required this.resultQuantity,
    required this.durationLabel,
    required this.duration,
    required this.materialCosts,
    required this.maxCraftableCount,
    required this.craftableNow,
    required this.queueFull,
  });

  final String recipeId;
  final String title;
  final String costHint;
  final String extraCostHint;
  final String resultMaterialId;
  final int resultQuantity;
  final String durationLabel;
  final Duration duration;
  final List<WorkshopMaterialCraftCostView> materialCosts;
  final int maxCraftableCount;
  final bool craftableNow;
  final bool queueFull;
}

class WorkshopMaterialCraftCostView {
  const WorkshopMaterialCraftCostView({
    required this.materialId,
    required this.name,
    required this.requiredQuantity,
    required this.ownedQuantity,
  });

  final String materialId;
  final String name;
  final int requiredQuantity;
  final int ownedQuantity;
}

extension WorkshopMaterialCraftRecipeDurationView
    on WorkshopMaterialCraftRecipeView {
  String totalDurationLabel(int repeatCount) {
    return materialCraftDurationLabel(duration * repeatCount);
  }
}

String materialCraftDurationLabel(Duration duration) {
  final int minutes = duration.inMinutes;
  final int seconds = duration.inSeconds.remainder(60);
  if (minutes > 0 && seconds > 0) {
    return '$minutes분 $seconds초';
  }
  if (minutes > 0) {
    return '$minutes분';
  }
  return '$seconds초';
}
