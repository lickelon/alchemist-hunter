import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'dart:math';

part 'workshop_skill_tree_cost_service.dart';
part 'workshop_skill_tree_unlock_service.dart';
part 'workshop_skill_tree_effect_service.dart';

class WorkshopSkillTreeService {
  const WorkshopSkillTreeService();

  int levelOf(WorkshopSkillTreeState state, String nodeId) {
    return state.nodeLevels[nodeId] ?? 0;
  }

  List<WorkshopSkillCost> costsForNextLevel(
    WorkshopSkillNode node,
    int currentLevel,
  ) => workshopSkillCostsForNextLevel(node, currentLevel);

  bool requirementsMet(SessionState state, WorkshopSkillNode node) =>
      workshopSkillRequirementsMet(state, node);

  bool prerequisitesMet(SessionState state, WorkshopSkillNode node) =>
      workshopSkillPrerequisitesMet(this, state, node);

  bool canAfford(SessionState state, List<WorkshopSkillCost> costs) =>
      workshopSkillCanAfford(state, costs);

  Set<String> resolveUnlockedNodes(
    SessionState state,
    List<WorkshopSkillNode> nodes,
  ) => workshopSkillResolveUnlockedNodes(this, state, nodes);

  double extractionYieldBonusRate(
    SessionState state,
    List<WorkshopSkillNode> nodes,
  ) => workshopSkillPercentModifierTotal(
    this,
    state,
    nodes,
    WorkshopSkillEffectType.extractionYield,
  );

  int craftQueueCapacity(
    SessionState state,
    List<WorkshopSkillNode> nodes, {
    int baseCapacity = 4,
  }) => max(
    1,
    baseCapacity +
        workshopSkillFlatModifierTotal(
          this,
          state,
          nodes,
          WorkshopSkillEffectType.craftQueueCapacity,
        ),
  );

  double enchantPotencyBonusRate(
    SessionState state,
    List<WorkshopSkillNode> nodes,
  ) => workshopSkillPercentModifierTotal(
    this,
    state,
    nodes,
    WorkshopSkillEffectType.enchantPotency,
  );
}
