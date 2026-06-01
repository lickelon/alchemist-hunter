part of 'workshop_skill_tree_service.dart';

double workshopSkillPercentModifierTotal(
  WorkshopSkillTreeService service,
  SessionState state,
  List<WorkshopSkillNode> nodes,
  WorkshopSkillEffectType effectType,
) {
  double total = 0;
  for (final WorkshopSkillNode node in nodes) {
    final int level = service.levelOf(state.workshop.skillTree, node.id);
    if (level <= 0) {
      continue;
    }
    for (final WorkshopSkillEffect effect in node.effects) {
      if (effect.type != effectType ||
          effect.modifierType != WorkshopSkillModifierType.percent) {
        continue;
      }
      total += effect.value * level;
    }
  }
  return total;
}

int workshopSkillFlatModifierTotal(
  WorkshopSkillTreeService service,
  SessionState state,
  List<WorkshopSkillNode> nodes,
  WorkshopSkillEffectType effectType,
) {
  int total = 0;
  for (final WorkshopSkillNode node in nodes) {
    final int level = service.levelOf(state.workshop.skillTree, node.id);
    if (level <= 0) {
      continue;
    }
    for (final WorkshopSkillEffect effect in node.effects) {
      if (effect.type != effectType ||
          effect.modifierType != WorkshopSkillModifierType.flat) {
        continue;
      }
      total += (effect.value * level).round();
    }
  }
  return total;
}
