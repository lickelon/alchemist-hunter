import 'package:flutter/foundation.dart';

@immutable
class HomunculusHatchRecipe {
  const HomunculusHatchRecipe({
    required this.id,
    required this.name,
    required this.description,
    required this.resultName,
    required this.essenceCost,
    required this.arcaneDustCost,
    required this.materialCosts,
    required this.traitCosts,
  });

  final String id;
  final String name;
  final String description;
  final String resultName;
  final int essenceCost;
  final int arcaneDustCost;
  final Map<String, int> materialCosts;
  final Map<String, double> traitCosts;
}
