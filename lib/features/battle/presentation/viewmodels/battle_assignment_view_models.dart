class BattleAssignmentCharacterView {
  const BattleAssignmentCharacterView({
    required this.id,
    required this.name,
    required this.typeLabel,
    required this.power,
    required this.assigned,
    required this.assignable,
    required this.assignmentHint,
  });

  final String id;
  final String name;
  final String typeLabel;
  final int power;
  final bool assigned;
  final bool assignable;
  final String assignmentHint;
}

class BattleAssignmentPotionView {
  const BattleAssignmentPotionView({
    required this.stackKey,
    required this.potionId,
    required this.label,
    required this.ownedCount,
    required this.selectedCount,
  });

  final String stackKey;
  final String potionId;
  final String label;
  final int ownedCount;
  final int selectedCount;
}
