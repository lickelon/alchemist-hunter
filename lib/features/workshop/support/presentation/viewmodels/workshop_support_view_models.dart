class WorkshopSupportSlotView {
  const WorkshopSupportSlotView({
    required this.slotId,
    required this.slotLabel,
    required this.effectLabel,
    required this.assignedCharacterId,
    required this.assignedCharacterName,
  });

  final String slotId;
  final String slotLabel;
  final String effectLabel;
  final String? assignedCharacterId;
  final String assignedCharacterName;
}

class WorkshopSupportCandidateView {
  const WorkshopSupportCandidateView({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.supportEffectLabel,
    required this.assignedToSlotLabel,
    required this.selectedForSlot,
    required this.assignable,
  });

  final String id;
  final String name;
  final String roleLabel;
  final String supportEffectLabel;
  final String? assignedToSlotLabel;
  final bool selectedForSlot;
  final bool assignable;
}
