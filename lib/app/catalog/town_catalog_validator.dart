import 'package:alchemist_hunter/app/catalog/catalog_validation_helpers.dart';
import 'package:alchemist_hunter/app/catalog/workshop_catalog_data.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_data.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

void validateTownCatalog(
  TownCatalogAssets catalog,
  WorkshopCatalogAssets workshop,
  BattleCatalogTables battle,
) {
  final Set<String> materialIds = catalogIds(
    workshop.materials,
    (MaterialEntity material) => material.id,
  );
  _validateShopDefinition(catalog.shopCatalog.general, materialIds);
  _validateShopDefinition(catalog.shopCatalog.catalyst, materialIds);

  requireUnique(
    'equipment blueprint id',
    catalog.equipmentBlueprints.map((EquipmentBlueprint blueprint) {
      requireNonEmpty('equipment blueprint id', blueprint.id);
      requirePositiveDuration(
        'equipment blueprint ${blueprint.id} craft duration',
        blueprint.craftDuration,
      );
      requirePositiveIntMap(
        'equipment blueprint ${blueprint.id} material cost',
        blueprint.materialCosts,
      );
      requireKnownKeys(
        'equipment blueprint ${blueprint.id} material cost',
        blueprint.materialCosts.keys,
        materialIds,
      );
      return blueprint.id;
    }),
  );

  final Set<String> mercenaryTierJobPairs = <String>{};
  requireUnique(
    'mercenary template id',
    catalog.mercenaryTemplates.map((MercenaryTemplate template) {
      requireNonEmpty('mercenary template id', template.id);
      requireNonEmpty(
        'mercenary template ${template.id} combat job id',
        template.combatJobId,
      );
      requireKnown(
        'mercenary template ${template.id} combat job',
        template.combatJobId,
        battle.combatJobDefinitions.keys.toSet(),
      );
      if (battle.combatJobDefinition(template.combatJobId).faction !=
          CombatFaction.mercenary) {
        throw StateError(
          'Mercenary template ${template.id} must use mercenary combat job',
        );
      }
      requireNonNegative(
        'mercenary template ${template.id} hire cost',
        template.hireCost,
      );
      requireNonNegative(
        'mercenary template ${template.id} tier index',
        template.tierIndex,
      );
      final String tierJobPair =
          '${template.tierIndex}:${template.combatJobId}';
      if (!mercenaryTierJobPairs.add(tierJobPair)) {
        throw StateError(
          'Duplicate mercenary template tier/job pair: $tierJobPair',
        );
      }
      return template.id;
    }),
  );

  final Set<String> nodeIds = catalogIds(
    catalog.skillNodes,
    (TownSkillNode node) => node.id,
  );
  requireNonEmpty('town skill nodes', catalog.skillNodes);
  _validateTownSkillNodes(catalog.skillNodes, nodeIds);
}

void _validateShopDefinition(ShopDefinitionData shop, Set<String> materialIds) {
  requireNonEmpty('${shop.shopType.name} shop seed items', shop.seedItems);
  requirePositiveDuration(
    '${shop.shopType.name} shop refresh interval',
    shop.refreshInterval,
  );
  requirePositiveInt(
    '${shop.shopType.name} shop purchase limit',
    shop.purchaseLimitPerItem,
  );
  requireNonNegative(
    '${shop.shopType.name} shop base refresh cost',
    shop.baseRefreshCost,
  );
  requireNonNegative(
    '${shop.shopType.name} shop refresh cost step',
    shop.refreshCostStep,
  );
  requireUnique(
    '${shop.shopType.name} shop material id',
    shop.seedItems.map((ShopItem item) {
      requireKnown(
        '${shop.shopType.name} shop material',
        item.materialId,
        materialIds,
      );
      requirePositiveInt(
        '${shop.shopType.name} shop ${item.materialId} price',
        item.price,
      );
      requireNonNegative(
        '${shop.shopType.name} shop ${item.materialId} quantity',
        item.quantity,
      );
      return item.materialId;
    }),
  );
}

void _validateTownSkillNodes(List<TownSkillNode> nodes, Set<String> nodeIds) {
  for (final TownSkillNode node in nodes) {
    requireNonEmpty('town skill node id', node.id);
    requirePositiveInt('town skill node ${node.id} max level', node.maxLevel);
    requireLength(
      'town skill node ${node.id} costsByLevel',
      node.costsByLevel,
      node.maxLevel,
    );
    requireKnownKeys(
      'town skill node ${node.id} prerequisite',
      node.prerequisiteNodeIds,
      nodeIds,
    );
    for (final List<TownSkillCost> levelCosts in node.costsByLevel) {
      requireNonEmpty('town skill node ${node.id} level costs', levelCosts);
      for (final TownSkillCost cost in levelCosts) {
        requirePositiveInt('town skill node ${node.id} cost', cost.amount);
      }
    }
    for (final TownSkillRequirement requirement in node.requirements) {
      requireNonNegative(
        'town skill node ${node.id} requirement threshold',
        requirement.threshold,
      );
    }
  }
}
