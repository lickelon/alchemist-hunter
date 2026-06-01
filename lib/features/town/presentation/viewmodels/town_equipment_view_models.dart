class TownEquipmentBlueprintView {
  const TownEquipmentBlueprintView({
    required this.id,
    required this.name,
    required this.slotLabel,
    required this.statLabel,
    required this.materialCostLabel,
    required this.durationLabel,
    required this.canCraft,
  });

  final String id;
  final String name;
  final String slotLabel;
  final String statLabel;
  final String materialCostLabel;
  final String durationLabel;
  final bool canCraft;
}

class TownEquipmentInventoryView {
  const TownEquipmentInventoryView({
    required this.id,
    required this.blueprintId,
    required this.name,
    required this.slotLabel,
    required this.statLabel,
  });

  final String id;
  final String blueprintId;
  final String name;
  final String slotLabel;
  final String statLabel;
}

class TownForgeJobView {
  const TownForgeJobView({
    required this.id,
    required this.name,
    required this.statusLabel,
    required this.remainingLabel,
    required this.canClaim,
  });

  final String id;
  final String name;
  final String statusLabel;
  final String remainingLabel;
  final bool canClaim;
}
