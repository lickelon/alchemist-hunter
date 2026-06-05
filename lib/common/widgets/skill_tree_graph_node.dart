enum SkillTreeNodeState { maxed, upgradable, locked, insufficient }

class SkillTreeGraphNode {
  const SkillTreeGraphNode({
    required this.id,
    required this.parentIds,
    required this.title,
    required this.description,
    required this.levelLabel,
    required this.costLabels,
    required this.currentEffectLabels,
    required this.nextEffectLabels,
    required this.prerequisiteLabel,
    required this.statusLabel,
    required this.state,
  });

  final String id;
  final List<String> parentIds;
  final String title;
  final String description;
  final String levelLabel;
  final List<String> costLabels;
  final List<String> currentEffectLabels;
  final List<String> nextEffectLabels;
  final String prerequisiteLabel;
  final String statusLabel;
  final SkillTreeNodeState state;
}
