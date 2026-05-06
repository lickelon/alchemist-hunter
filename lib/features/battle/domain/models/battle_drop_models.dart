import 'package:flutter/foundation.dart';

@immutable
class BattleDropEntry {
  const BattleDropEntry({
    required this.materialId,
    required this.min,
    required this.max,
    required this.chance,
  });

  final String materialId;
  final int min;
  final int max;
  final double chance;
}

@immutable
class BattleDropTable {
  const BattleDropTable({
    required this.stageId,
    required this.normalDrops,
    required this.specialDrops,
  });

  final String stageId;
  final List<BattleDropEntry> normalDrops;
  final List<BattleDropEntry> specialDrops;
}
