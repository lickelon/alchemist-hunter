class PlayerState {
  const PlayerState({
    required this.gold,
    required this.essence,
    required this.townInsight,
    required this.arcaneDust,
    required this.diamonds,
    required this.timeAcceleration,
    required this.materialInventory,
  });

  final int gold;
  final int essence;
  final int townInsight;
  final int arcaneDust;
  final int diamonds;
  final double timeAcceleration;
  final Map<String, int> materialInventory;

  PlayerState copyWith({
    int? gold,
    int? essence,
    int? townInsight,
    int? arcaneDust,
    int? diamonds,
    double? timeAcceleration,
    Map<String, int>? materialInventory,
  }) {
    return PlayerState(
      gold: gold ?? this.gold,
      essence: essence ?? this.essence,
      townInsight: townInsight ?? this.townInsight,
      arcaneDust: arcaneDust ?? this.arcaneDust,
      diamonds: diamonds ?? this.diamonds,
      timeAcceleration: timeAcceleration ?? this.timeAcceleration,
      materialInventory: materialInventory ?? this.materialInventory,
    );
  }
}
