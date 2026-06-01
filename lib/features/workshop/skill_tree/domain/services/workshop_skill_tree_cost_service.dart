part of 'workshop_skill_tree_service.dart';

List<WorkshopSkillCost> workshopSkillCostsForNextLevel(
  WorkshopSkillNode node,
  int currentLevel,
) {
  if (currentLevel >= node.maxLevel) {
    return const <WorkshopSkillCost>[];
  }
  return node.costsByLevel[currentLevel];
}

bool workshopSkillCanAfford(SessionState state, List<WorkshopSkillCost> costs) {
  for (final WorkshopSkillCost cost in costs) {
    final double owned = switch (cost.type) {
      WorkshopSkillCostType.arcaneDust => state.player.arcaneDust.toDouble(),
      WorkshopSkillCostType.element =>
        state.workshop.extractedTraitInventory[cost.elementId] ?? 0,
    };
    if (owned < cost.amount) {
      return false;
    }
  }
  return true;
}
