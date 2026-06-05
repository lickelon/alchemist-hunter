import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_enemy_effect_labels.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleDropChanceView {
  const BattleDropChanceView({
    required this.materialId,
    required this.materialName,
    required this.quantityLabel,
    required this.chanceLabel,
  });

  final String materialId;
  final String materialName;
  final String quantityLabel;
  final String chanceLabel;
}

class BattleEnemyDropView {
  const BattleEnemyDropView({
    required this.enemyName,
    required this.identityLabel,
    required this.statLines,
    required this.effectLines,
    required this.normalDrops,
    required this.specialDrops,
  });

  final String enemyName;
  final String identityLabel;
  final List<String> statLines;
  final List<String> effectLines;
  final List<BattleDropChanceView> normalDrops;
  final List<BattleDropChanceView> specialDrops;
}

class BattleStageDropOverviewView {
  const BattleStageDropOverviewView({
    required this.stageName,
    required this.recommendedPower,
    required this.enemyCount,
    required this.enemies,
  });

  final String stageName;
  final int recommendedPower;
  final int enemyCount;
  final List<BattleEnemyDropView> enemies;
}

final battleStageDropOverviewProvider =
    Provider.family<BattleStageDropOverviewView, String>((
      Ref ref,
      String stageId,
    ) {
      final BattleCatalogRepository battleCatalog = ref.watch(
        battleCatalogRepositoryProvider,
      );
      final MaterialCatalogRepository materialCatalog = ref.watch(
        materialCatalogRepositoryProvider,
      );
      final BattleStageDefinition stage = battleCatalog.stageDefinition(
        stageId,
      );
      final List<BattleEnemyDefinition> uniqueEnemies = battleCatalog
          .enemyDefinitionsForStage(stageId);

      return BattleStageDropOverviewView(
        stageName: battleStageDisplayName(stage.id, fallback: stage.name),
        recommendedPower: stage.recommendedPower,
        enemyCount: uniqueEnemies.length,
        enemies: uniqueEnemies
            .map((BattleEnemyDefinition enemy) {
              return BattleEnemyDropView(
                enemyName: enemy.name,
                identityLabel:
                    '${battleFactionLabel(enemy.faction)} ${enemy.summary}',
                statLines: battleEnemyStatLines(enemy.stats),
                effectLines: battleEnemyEffectLines(enemy),
                normalDrops: enemy.normalDrops
                    .map(
                      (BattleDropEntry drop) => BattleDropChanceView(
                        materialId: drop.materialId,
                        materialName:
                            materialCatalog.materialName(drop.materialId) ??
                            drop.materialId,
                        quantityLabel: battleDropQuantityLabel(drop),
                        chanceLabel: battleChanceLabel(drop.chance),
                      ),
                    )
                    .toList(growable: false),
                specialDrops: enemy.specialDrops
                    .map(
                      (BattleDropEntry drop) => BattleDropChanceView(
                        materialId: drop.materialId,
                        materialName:
                            materialCatalog.materialName(drop.materialId) ??
                            drop.materialId,
                        quantityLabel: battleDropQuantityLabel(drop),
                        chanceLabel: battleChanceLabel(drop.chance),
                      ),
                    )
                    .toList(growable: false),
              );
            })
            .toList(growable: false),
      );
    });
