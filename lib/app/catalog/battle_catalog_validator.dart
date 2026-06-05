import 'package:alchemist_hunter/app/catalog/catalog_validation_helpers.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';

void validateBattleCatalog(
  BattleCatalogTables catalog, {
  Set<String>? materialIds,
}) {
  requireUnique('battle stage catalog order', catalog.stageCatalog);
  requireNonEmpty('battle stage catalog order', catalog.stageCatalog);
  requireKnownKeys(
    'battle stage catalog order',
    catalog.stageDefinitions.keys,
    catalog.stageCatalog.toSet(),
  );
  for (final BattleStageDefinition stage in catalog.stageDefinitions.values) {
    final double totalChance = stage.encounters.fold<double>(
      0,
      (double total, BattleStageEncounterDefinition encounter) =>
          total + encounter.chance,
    );
    if ((totalChance - 1).abs() > 0.001) {
      throw StateError('Stage ${stage.id} encounter chance total must be 1');
    }
  }
  if (materialIds != null) {
    _validateBattleDrops(catalog, materialIds);
  }
}

void _validateBattleDrops(
  BattleCatalogTables catalog,
  Set<String> materialIds,
) {
  for (final BattleEnemyDefinition enemy in catalog.enemyDefinitions.values) {
    for (final BattleDropEntry drop in <BattleDropEntry>[
      ...enemy.normalDrops,
      ...enemy.specialDrops,
    ]) {
      requireKnown(
        'battle enemy ${enemy.id} drop material',
        drop.materialId,
        materialIds,
      );
      requirePositiveInt('battle enemy ${enemy.id} drop min', drop.min);
      requirePositiveInt('battle enemy ${enemy.id} drop max', drop.max);
      if (drop.max < drop.min) {
        throw StateError('Battle enemy ${enemy.id} drop max must be >= min');
      }
      if (drop.chance <= 0 || drop.chance > 1) {
        throw StateError('Battle enemy ${enemy.id} drop chance must be 0..1');
      }
    }
  }
}
