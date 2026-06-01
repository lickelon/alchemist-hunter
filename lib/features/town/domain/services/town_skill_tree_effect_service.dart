part of 'town_skill_tree_service.dart';

double townSkillPercentModifierTotal({
  required TownSkillTreeService service,
  required SessionState state,
  required List<TownSkillNode> nodes,
  required TownSkillEffectType effectType,
}) {
  double total = 0;
  for (final TownSkillNode node in nodes) {
    final int level = service.levelOf(state.town.skillTree, node.id);
    if (level <= 0) {
      continue;
    }
    for (final TownSkillEffect effect in node.effects) {
      if (effect.type != effectType ||
          effect.modifierType != TownSkillModifierType.percent) {
        continue;
      }
      total += effect.value * level;
    }
  }
  return total;
}
