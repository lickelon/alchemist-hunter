import 'package:flutter/foundation.dart';

enum WorkshopCraftRecipeCategory { promotionMaterial }

@immutable
class WorkshopCraftRecipe {
  const WorkshopCraftRecipe({
    required this.id,
    required this.name,
    required this.category,
    this.materialCosts = const <String, int>{},
    this.traitCosts = const <String, double>{},
    this.essenceCost = 0,
    this.arcaneDustCost = 0,
    required this.duration,
    required this.resultMaterials,
  });

  final String id;
  final String name;
  final WorkshopCraftRecipeCategory category;
  final Map<String, int> materialCosts;
  final Map<String, double> traitCosts;
  final int essenceCost;
  final int arcaneDustCost;
  final Duration duration;
  final Map<String, int> resultMaterials;
}
