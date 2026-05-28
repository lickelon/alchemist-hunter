enum SkillTreeNodeState { maxed, upgradable, locked, insufficient }

class SkillTreeGraphNode {
  const SkillTreeGraphNode({
    required this.id,
    required this.parentIds,
    required this.title,
    required this.description,
    required this.levelLabel,
    required this.costLabel,
    required this.currentEffectLabel,
    required this.nextEffectLabel,
    required this.prerequisiteLabel,
    required this.statusLabel,
    required this.state,
  });

  final String id;
  final List<String> parentIds;
  final String title;
  final String description;
  final String levelLabel;
  final String costLabel;
  final String currentEffectLabel;
  final String nextEffectLabel;
  final String prerequisiteLabel;
  final String statusLabel;
  final SkillTreeNodeState state;
}
