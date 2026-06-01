part of 'workshop_skill_tree_service.dart';

bool workshopSkillRequirementsMet(SessionState state, WorkshopSkillNode node) {
  for (final WorkshopSkillRequirement requirement in node.requirements) {
    final int progress = switch (requirement.type) {
      WorkshopSkillRequirementType.extractionCount =>
        state.workshop.extractionCount,
      WorkshopSkillRequirementType.potionCraftCount =>
        state.workshop.potionCraftCount,
      WorkshopSkillRequirementType.enchantCount => state.workshop.enchantCount,
    };
    if (progress < requirement.threshold) {
      return false;
    }
  }
  return true;
}

bool workshopSkillPrerequisitesMet(
  WorkshopSkillTreeService service,
  SessionState state,
  WorkshopSkillNode node,
) {
  for (final String nodeId in node.prerequisiteNodeIds) {
    if (service.levelOf(state.workshop.skillTree, nodeId) <= 0) {
      return false;
    }
  }
  return true;
}

Set<String> workshopSkillResolveUnlockedNodes(
  WorkshopSkillTreeService service,
  SessionState state,
  List<WorkshopSkillNode> nodes,
) {
  final Set<String> unlocked = <String>{
    ...state.workshop.skillTree.unlockedNodes,
  };
  for (final WorkshopSkillNode node in nodes) {
    if (service.levelOf(state.workshop.skillTree, node.id) > 0 ||
        (service.prerequisitesMet(state, node) &&
            service.requirementsMet(state, node))) {
      unlocked.add(node.id);
    }
  }
  return unlocked;
}
