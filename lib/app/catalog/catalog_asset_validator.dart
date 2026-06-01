import 'package:alchemist_hunter/app/catalog/workshop_catalog_data.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_data.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

void validateCatalogAssets({
  required BattleCatalogTables battle,
  required TownCatalogAssets town,
  required WorkshopCatalogAssets workshop,
}) {
  _validateBattleCatalog(battle);
  _validateWorkshopCatalog(workshop);
  _validateTownCatalog(town, workshop);
}

void _validateBattleCatalog(BattleCatalogTables catalog) {
  _requireUnique('battle stage catalog order', catalog.stageCatalog);
  _requireNonEmpty('battle stage catalog order', catalog.stageCatalog);
}

void _validateTownCatalog(
  TownCatalogAssets catalog,
  WorkshopCatalogAssets workshop,
) {
  final Set<String> materialIds = _ids(
    workshop.materials,
    (MaterialEntity material) => material.id,
  );
  _validateShopDefinition(catalog.shopCatalog.general, materialIds);
  _validateShopDefinition(catalog.shopCatalog.catalyst, materialIds);

  _requireUnique(
    'equipment blueprint id',
    catalog.equipmentBlueprints.map((EquipmentBlueprint blueprint) {
      _requireNonEmpty('equipment blueprint id', blueprint.id);
      _requirePositiveDuration(
        'equipment blueprint ${blueprint.id} craft duration',
        blueprint.craftDuration,
      );
      _requirePositiveIntMap(
        'equipment blueprint ${blueprint.id} material cost',
        blueprint.materialCosts,
      );
      _requireKnownKeys(
        'equipment blueprint ${blueprint.id} material cost',
        blueprint.materialCosts.keys,
        materialIds,
      );
      return blueprint.id;
    }),
  );

  _requireUnique(
    'mercenary template id',
    catalog.mercenaryTemplates.map((MercenaryTemplate template) {
      _requireNonEmpty('mercenary template id', template.id);
      _requireNonEmpty(
        'mercenary template ${template.id} combat job id',
        template.combatJobId,
      );
      _requireNonNegative(
        'mercenary template ${template.id} hire cost',
        template.hireCost,
      );
      _requireNonNegative(
        'mercenary template ${template.id} tier index',
        template.tierIndex,
      );
      return template.id;
    }),
  );

  final Set<String> nodeIds = _ids(
    catalog.skillNodes,
    (TownSkillNode node) => node.id,
  );
  _requireNonEmpty('town skill nodes', catalog.skillNodes);
  _validateTownSkillNodes(catalog.skillNodes, nodeIds);
}

void _validateWorkshopCatalog(WorkshopCatalogAssets catalog) {
  final Set<String> traitIds = _ids(catalog.traits, (TraitUnit trait) {
    _requireNonEmpty('trait id', trait.id);
    _requirePositive('trait ${trait.id} potency', trait.potency);
    _requireNonNegativeDoubleMap(
      'trait ${trait.id} components',
      trait.components,
    );
    return trait.id;
  });
  final Set<String> materialIds = _ids(catalog.materials, (
    MaterialEntity material,
  ) {
    _requireNonEmpty('material id', material.id);
    if (material.analyzable) {
      _requireNonEmpty('material ${material.id} traits', material.traits);
    }
    for (final TraitUnit trait in material.traits) {
      _requireKnown('material ${material.id} trait', trait.id, traitIds);
    }
    return material.id;
  });
  _requireUnique(
    'extraction profile id',
    catalog.extractionProfiles.map((ExtractionProfile profile) {
      _requireNonEmpty('extraction profile id', profile.id);
      _requirePositive(
        'extraction profile ${profile.id} yield rate',
        profile.yieldRate,
      );
      _requirePositive(
        'extraction profile ${profile.id} purity rate',
        profile.purityRate,
      );
      _requirePositiveDuration(
        'extraction profile ${profile.id} time cost',
        profile.timeCost,
      );
      return profile.id;
    }),
  );
  final Set<String> potionIds = _ids(catalog.potions, (PotionBlueprint potion) {
    _requireNonEmpty('potion id', potion.id);
    _requirePositiveInt('potion ${potion.id} base value', potion.baseValue);
    _requirePositiveDoubleMap(
      'potion ${potion.id} target traits',
      potion.targetTraits,
    );
    _requireKnownKeys(
      'potion ${potion.id} target traits',
      potion.targetTraits.keys,
      traitIds,
    );
    return potion.id;
  });
  _validatePotionRecipes(catalog.potionRecipeRules, traitIds, potionIds);
  _validatePotionQuality(catalog.potionQualityRule);
  _validateWorkshopCraftRecipes(catalog.craftRecipes, materialIds, traitIds);
  _validateHatchRecipes(catalog.hatchRecipes, materialIds, traitIds);

  final Set<String> nodeIds = _ids(
    catalog.skillNodes,
    (WorkshopSkillNode node) => node.id,
  );
  _requireNonEmpty('workshop skill nodes', catalog.skillNodes);
  _validateWorkshopSkillNodes(catalog.skillNodes, nodeIds, traitIds);
}

void _validateShopDefinition(ShopDefinitionData shop, Set<String> materialIds) {
  _requireNonEmpty('${shop.shopType.name} shop seed items', shop.seedItems);
  _requirePositiveDuration(
    '${shop.shopType.name} shop refresh interval',
    shop.refreshInterval,
  );
  _requirePositiveInt(
    '${shop.shopType.name} shop purchase limit',
    shop.purchaseLimitPerItem,
  );
  _requireNonNegative(
    '${shop.shopType.name} shop base refresh cost',
    shop.baseRefreshCost,
  );
  _requireNonNegative(
    '${shop.shopType.name} shop refresh cost step',
    shop.refreshCostStep,
  );
  _requireUnique(
    '${shop.shopType.name} shop material id',
    shop.seedItems.map((ShopItem item) {
      _requireKnown(
        '${shop.shopType.name} shop material',
        item.materialId,
        materialIds,
      );
      _requirePositiveInt(
        '${shop.shopType.name} shop ${item.materialId} price',
        item.price,
      );
      _requireNonNegative(
        '${shop.shopType.name} shop ${item.materialId} quantity',
        item.quantity,
      );
      return item.materialId;
    }),
  );
}

void _validateTownSkillNodes(List<TownSkillNode> nodes, Set<String> nodeIds) {
  for (final TownSkillNode node in nodes) {
    _requireNonEmpty('town skill node id', node.id);
    _requirePositiveInt('town skill node ${node.id} max level', node.maxLevel);
    _requireLength(
      'town skill node ${node.id} costsByLevel',
      node.costsByLevel,
      node.maxLevel,
    );
    _requireKnownKeys(
      'town skill node ${node.id} prerequisite',
      node.prerequisiteNodeIds,
      nodeIds,
    );
    for (final List<TownSkillCost> levelCosts in node.costsByLevel) {
      _requireNonEmpty('town skill node ${node.id} level costs', levelCosts);
      for (final TownSkillCost cost in levelCosts) {
        _requirePositiveInt('town skill node ${node.id} cost', cost.amount);
      }
    }
    for (final TownSkillRequirement requirement in node.requirements) {
      _requireNonNegative(
        'town skill node ${node.id} requirement threshold',
        requirement.threshold,
      );
    }
  }
}

void _validatePotionRecipes(
  List<PotionRecipeRule> recipes,
  Set<String> traitIds,
  Set<String> potionIds,
) {
  final Set<String> recipePairs = <String>{};
  _requireUnique(
    'potion recipe id',
    recipes.map((PotionRecipeRule recipe) {
      _requireKnown(
        'potion recipe ${recipe.id} main trait',
        recipe.mainTraitId,
        traitIds,
      );
      _requireKnown(
        'potion recipe ${recipe.id} sub trait',
        recipe.subTraitId,
        traitIds,
      );
      _requireKnown(
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
  _requireUnique(
    'workshop craft recipe id',
    recipes.map((WorkshopCraftRecipe recipe) {
      _requireNonEmpty('workshop craft recipe id', recipe.id);
      _requirePositiveDuration(
        'workshop craft recipe ${recipe.id} duration',
        recipe.duration,
      );
      _requireNonNegative(
        'workshop craft recipe ${recipe.id} essence cost',
        recipe.essenceCost,
      );
      _requireNonNegative(
        'workshop craft recipe ${recipe.id} arcane dust cost',
        recipe.arcaneDustCost,
      );
      _requirePositiveIntMap(
        'workshop craft recipe ${recipe.id} material cost',
        recipe.materialCosts,
      );
      _requireKnownKeys(
        'workshop craft recipe ${recipe.id} material cost',
        recipe.materialCosts.keys,
        materialIds,
      );
      _requirePositiveDoubleMap(
        'workshop craft recipe ${recipe.id} trait cost',
        recipe.traitCosts,
      );
      _requireKnownKeys(
        'workshop craft recipe ${recipe.id} trait cost',
        recipe.traitCosts.keys,
        traitIds,
      );
      _requirePositiveIntMap(
        'workshop craft recipe ${recipe.id} result material',
        recipe.resultMaterials,
      );
      _requireKnownKeys(
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
) {
  _requireUnique(
    'homunculus hatch recipe id',
    recipes.map((HomunculusHatchRecipe recipe) {
      _requireNonEmpty('homunculus hatch recipe id', recipe.id);
      _requireNonEmpty(
        'homunculus hatch recipe ${recipe.id} combat job id',
        recipe.combatJobId,
      );
      _requirePositiveDuration(
        'homunculus hatch recipe ${recipe.id} duration',
        recipe.duration,
      );
      _requirePositiveIntMap(
        'homunculus hatch recipe ${recipe.id} material cost',
        recipe.materialCosts,
      );
      _requireKnownKeys(
        'homunculus hatch recipe ${recipe.id} material cost',
        recipe.materialCosts.keys,
        materialIds,
      );
      _requirePositiveDoubleMap(
        'homunculus hatch recipe ${recipe.id} trait cost',
        recipe.traitCosts,
      );
      _requireKnownKeys(
        'homunculus hatch recipe ${recipe.id} trait cost',
        recipe.traitCosts.keys,
        traitIds,
      );
      return recipe.id;
    }),
  );
}

void _validateWorkshopSkillNodes(
  List<WorkshopSkillNode> nodes,
  Set<String> nodeIds,
  Set<String> traitIds,
) {
  for (final WorkshopSkillNode node in nodes) {
    _requireNonEmpty('workshop skill node id', node.id);
    _requirePositiveInt(
      'workshop skill node ${node.id} max level',
      node.maxLevel,
    );
    _requireLength(
      'workshop skill node ${node.id} costsByLevel',
      node.costsByLevel,
      node.maxLevel,
    );
    _requireKnownKeys(
      'workshop skill node ${node.id} prerequisite',
      node.prerequisiteNodeIds,
      nodeIds,
    );
    for (final List<WorkshopSkillCost> levelCosts in node.costsByLevel) {
      _requireNonEmpty(
        'workshop skill node ${node.id} level costs',
        levelCosts,
      );
      for (final WorkshopSkillCost cost in levelCosts) {
        _requirePositiveInt('workshop skill node ${node.id} cost', cost.amount);
        if (cost.type == WorkshopSkillCostType.element) {
          final String? elementId = cost.elementId;
          if (elementId == null) {
            throw StateError(
              'Workshop skill node ${node.id} element cost needs elementId',
            );
          }
          _requireKnown(
            'workshop skill node ${node.id} element cost',
            elementId,
            traitIds,
          );
        }
      }
    }
    for (final WorkshopSkillRequirement requirement in node.requirements) {
      _requireNonNegative(
        'workshop skill node ${node.id} requirement threshold',
        requirement.threshold,
      );
    }
  }
}

Set<String> _ids<T>(Iterable<T> values, String Function(T value) idOf) {
  final List<String> ids = values.map(idOf).toList(growable: false);
  _requireUnique('catalog id', ids);
  return ids.toSet();
}

void _requireUnique(String label, Iterable<String> values) {
  final Set<String> seen = <String>{};
  for (final String value in values) {
    _requireNonEmpty(label, value);
    if (!seen.add(value)) {
      throw StateError('Duplicate $label: $value');
    }
  }
}

void _requireKnown(String label, String value, Set<String> knownValues) {
  if (!knownValues.contains(value)) {
    throw StateError('Unknown $label: $value');
  }
}

void _requireKnownKeys(
  String label,
  Iterable<String> values,
  Set<String> knownValues,
) {
  for (final String value in values) {
    _requireKnown(label, value, knownValues);
  }
}

void _requireNonEmpty(String label, Object value) {
  if (value is String && value.isEmpty) {
    throw StateError('$label must not be empty');
  }
  if (value is Iterable<Object?> && value.isEmpty) {
    throw StateError('$label must not be empty');
  }
}

void _requireLength(String label, List<Object?> values, int length) {
  if (values.length != length) {
    throw StateError('$label must have $length entries');
  }
}

void _requirePositiveInt(String label, int value) {
  if (value <= 0) {
    throw StateError('$label must be positive: $value');
  }
}

void _requireNonNegative(String label, int value) {
  if (value < 0) {
    throw StateError('$label must be non-negative: $value');
  }
}

void _requirePositive(String label, double value) {
  if (value <= 0) {
    throw StateError('$label must be positive: $value');
  }
}

void _requirePositiveDuration(String label, Duration value) {
  if (value <= Duration.zero) {
    throw StateError('$label must be positive: $value');
  }
}

void _requirePositiveIntMap(String label, Map<String, int> values) {
  for (final MapEntry<String, int> entry in values.entries) {
    _requirePositiveInt('$label ${entry.key}', entry.value);
  }
}

void _requirePositiveDoubleMap(String label, Map<String, double> values) {
  for (final MapEntry<String, double> entry in values.entries) {
    _requirePositive('$label ${entry.key}', entry.value);
  }
}

void _requireNonNegativeDoubleMap(String label, Map<String, double> values) {
  for (final MapEntry<String, double> entry in values.entries) {
    if (entry.value < 0) {
      throw StateError('$label ${entry.key} must be non-negative');
    }
  }
}
