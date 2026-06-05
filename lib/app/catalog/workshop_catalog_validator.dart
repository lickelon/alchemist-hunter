import 'package:alchemist_hunter/app/catalog/catalog_validation_helpers.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_data.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

void validateWorkshopCatalog(
  WorkshopCatalogAssets catalog,
  BattleCatalogTables battle,
) {
  final Set<String> traitIds = catalogIds(catalog.traits, (TraitUnit trait) {
    requireNonEmpty('trait id', trait.id);
    requirePositive('trait ${trait.id} potency', trait.potency);
    requireNonNegativeDoubleMap(
      'trait ${trait.id} components',
      trait.components,
    );
    return trait.id;
  });
  final Set<String> materialIds = catalogIds(catalog.materials, (
    MaterialEntity material,
  ) {
    requireNonEmpty('material id', material.id);
    if (material.analyzable) {
      requireNonEmpty('material ${material.id} traits', material.traits);
    }
    for (final TraitUnit trait in material.traits) {
      requireKnown('material ${material.id} trait', trait.id, traitIds);
    }
    return material.id;
  });
  requireUnique(
    'extraction profile id',
    catalog.extractionProfiles.map((ExtractionProfile profile) {
      requireNonEmpty('extraction profile id', profile.id);
      requirePositive(
        'extraction profile ${profile.id} yield rate',
        profile.yieldRate,
      );
      requirePositive(
        'extraction profile ${profile.id} purity rate',
        profile.purityRate,
      );
      requirePositiveDuration(
        'extraction profile ${profile.id} time cost',
        profile.timeCost,
      );
      return profile.id;
    }),
  );
  final Set<String> potionIds = catalogIds(catalog.potions, (
    PotionBlueprint potion,
  ) {
    requireNonEmpty('potion id', potion.id);
    requirePositiveInt('potion ${potion.id} base value', potion.baseValue);
    requirePositiveDoubleMap(
      'potion ${potion.id} target traits',
      potion.targetTraits,
    );
    requireKnownKeys(
      'potion ${potion.id} target traits',
      potion.targetTraits.keys,
      traitIds,
    );
    return potion.id;
  });
  _validatePotionRecipes(catalog.potionRecipeRules, traitIds, potionIds);
  _validatePotionQuality(catalog.potionQualityRule);
  _validateWorkshopCraftRecipes(catalog.craftRecipes, materialIds, traitIds);
  _validateHatchRecipes(catalog.hatchRecipes, materialIds, traitIds, battle);

  final Set<String> nodeIds = catalogIds(
    catalog.skillNodes,
    (WorkshopSkillNode node) => node.id,
  );
  requireNonEmpty('workshop skill nodes', catalog.skillNodes);
  _validateWorkshopSkillNodes(catalog.skillNodes, nodeIds, traitIds);
}

void _validatePotionRecipes(
  List<PotionRecipeRule> recipes,
  Set<String> traitIds,
  Set<String> potionIds,
) {
  final Set<String> recipePairs = <String>{};
  requireUnique(
    'potion recipe id',
    recipes.map((PotionRecipeRule recipe) {
      requireKnown(
        'potion recipe ${recipe.id} main trait',
        recipe.mainTraitId,
        traitIds,
      );
      requireKnown(
        'potion recipe ${recipe.id} sub trait',
        recipe.subTraitId,
        traitIds,
      );
      requireKnown(
        'potion recipe ${recipe.id} result potion',
        recipe.resultPotionId,
        potionIds,
      );
      if (recipe.mainTraitId == recipe.subTraitId) {
        throw StateError('Potion recipe ${recipe.id} repeats the same trait');
      }
      if (recipe.mainPercent <= recipe.subPercent) {
        throw StateError(
          'Potion recipe ${recipe.id} main percent must exceed sub percent',
        );
      }
      if (recipe.mainPercent + recipe.subPercent != 100) {
        throw StateError(
          'Potion recipe ${recipe.id} percent total must be 100',
        );
      }
      final String pair = '${recipe.mainTraitId}:${recipe.subTraitId}';
      if (!recipePairs.add(pair)) {
        throw StateError('Duplicate potion recipe trait pair: $pair');
      }
      return recipe.id;
    }),
  );
}

void _validatePotionQuality(PotionQualityRule rule) {
  for (final PotionQualityGrade grade in PotionQualityGrade.values) {
    if (!rule.gradeThresholds.containsKey(grade)) {
      throw StateError('Missing potion quality threshold: ${grade.name}');
    }
  }
}

void _validateWorkshopCraftRecipes(
  List<WorkshopCraftRecipe> recipes,
  Set<String> materialIds,
  Set<String> traitIds,
) {
  requireUnique(
    'workshop craft recipe id',
    recipes.map((WorkshopCraftRecipe recipe) {
      requireNonEmpty('workshop craft recipe id', recipe.id);
      requirePositiveDuration(
        'workshop craft recipe ${recipe.id} duration',
        recipe.duration,
      );
      requireNonNegative(
        'workshop craft recipe ${recipe.id} essence cost',
        recipe.essenceCost,
      );
      requireNonNegative(
        'workshop craft recipe ${recipe.id} arcane dust cost',
        recipe.arcaneDustCost,
      );
      requirePositiveIntMap(
        'workshop craft recipe ${recipe.id} material cost',
        recipe.materialCosts,
      );
      requireKnownKeys(
        'workshop craft recipe ${recipe.id} material cost',
        recipe.materialCosts.keys,
        materialIds,
      );
      requirePositiveDoubleMap(
        'workshop craft recipe ${recipe.id} trait cost',
        recipe.traitCosts,
      );
      requireKnownKeys(
        'workshop craft recipe ${recipe.id} trait cost',
        recipe.traitCosts.keys,
        traitIds,
      );
      requirePositiveIntMap(
        'workshop craft recipe ${recipe.id} result material',
        recipe.resultMaterials,
      );
      requireKnownKeys(
        'workshop craft recipe ${recipe.id} result material',
        recipe.resultMaterials.keys,
        materialIds,
      );
      return recipe.id;
    }),
  );
}

void _validateHatchRecipes(
  List<HomunculusHatchRecipe> recipes,
  Set<String> materialIds,
  Set<String> traitIds,
  BattleCatalogTables battle,
) {
  requireUnique(
    'homunculus hatch recipe id',
    recipes.map((HomunculusHatchRecipe recipe) {
      requireNonEmpty('homunculus hatch recipe id', recipe.id);
      requireNonEmpty(
        'homunculus hatch recipe ${recipe.id} combat job id',
        recipe.combatJobId,
      );
      requireKnown(
        'homunculus hatch recipe ${recipe.id} combat job',
        recipe.combatJobId,
        battle.combatJobDefinitions.keys.toSet(),
      );
      if (battle.combatJobDefinition(recipe.combatJobId).faction !=
          CombatFaction.homunculus) {
        throw StateError(
          'Homunculus hatch recipe ${recipe.id} must use homunculus combat job',
        );
      }
      requirePositiveDuration(
        'homunculus hatch recipe ${recipe.id} duration',
        recipe.duration,
      );
      requirePositiveIntMap(
        'homunculus hatch recipe ${recipe.id} material cost',
        recipe.materialCosts,
      );
      requireKnownKeys(
        'homunculus hatch recipe ${recipe.id} material cost',
        recipe.materialCosts.keys,
        materialIds,
      );
      requirePositiveDoubleMap(
        'homunculus hatch recipe ${recipe.id} trait cost',
        recipe.traitCosts,
      );
      requireKnownKeys(
        'homunculus hatch recipe ${recipe.id} trait cost',
        recipe.traitCosts.keys,
        traitIds,
      );
      return recipe.id;
    }),
  );
  requireUnique(
    'homunculus hatch recipe combat job',
    recipes.map((HomunculusHatchRecipe recipe) => recipe.combatJobId),
  );
}

void _validateWorkshopSkillNodes(
  List<WorkshopSkillNode> nodes,
  Set<String> nodeIds,
  Set<String> traitIds,
) {
  for (final WorkshopSkillNode node in nodes) {
    requireNonEmpty('workshop skill node id', node.id);
    requirePositiveInt(
      'workshop skill node ${node.id} max level',
      node.maxLevel,
    );
    requireLength(
      'workshop skill node ${node.id} costsByLevel',
      node.costsByLevel,
      node.maxLevel,
    );
    requireKnownKeys(
      'workshop skill node ${node.id} prerequisite',
      node.prerequisiteNodeIds,
      nodeIds,
    );
    for (final List<WorkshopSkillCost> levelCosts in node.costsByLevel) {
      requireNonEmpty('workshop skill node ${node.id} level costs', levelCosts);
      for (final WorkshopSkillCost cost in levelCosts) {
        requirePositiveInt('workshop skill node ${node.id} cost', cost.amount);
        if (cost.type == WorkshopSkillCostType.element) {
          final String? elementId = cost.elementId;
          if (elementId == null) {
            throw StateError(
              'Workshop skill node ${node.id} element cost needs elementId',
            );
          }
          requireKnown(
            'workshop skill node ${node.id} element cost',
            elementId,
            traitIds,
          );
        }
      }
    }
    for (final WorkshopSkillRequirement requirement in node.requirements) {
      requireNonNegative(
        'workshop skill node ${node.id} requirement threshold',
        requirement.threshold,
      );
    }
  }
}
