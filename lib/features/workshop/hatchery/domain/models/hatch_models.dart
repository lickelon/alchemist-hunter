import 'package:flutter/foundation.dart';

@immutable
class HomunculusHatchRecipe {
  const HomunculusHatchRecipe({
    required this.id,
    required this.combatJobId,
    required this.essenceCost,
    required this.arcaneDustCost,
    required this.materialCosts,
    required this.traitCosts,
    this.duration = const Duration(seconds: 45),
  });

  final String id;
  final String combatJobId;
  final int essenceCost;
  final int arcaneDustCost;
  final Map<String, int> materialCosts;
  final Map<String, double> traitCosts;
  final Duration duration;
}
