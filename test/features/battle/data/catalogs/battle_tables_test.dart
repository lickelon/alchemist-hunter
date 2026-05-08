import 'package:alchemist_hunter/features/battle/data/catalogs/battle_tables.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/shop_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shop materials are obtainable from exactly one stage', () {
    final Set<String> shopMaterialIds = <String>{
      ...buildGeneralShopSeedItems().map((item) => item.materialId),
      ...buildCatalystShopSeedItems().map((item) => item.materialId),
    };

    for (final String materialId in shopMaterialIds) {
      final List<String> stages = stageCatalog.where((String stageId) {
        final Set<String> materialIds = <String>{
          ...stageDropTable(stageId).normalDrops.map((drop) => drop.materialId),
          ...stageDropTable(stageId).specialDrops.map(
            (drop) => drop.materialId,
          ),
        };
        return materialIds.contains(materialId);
      }).toList(growable: false);

      expect(
        stages,
        hasLength(1),
        reason: '$materialId should belong to exactly one stage',
      );
    }
  });

  test('stage reward and difficulty curves increase toward stage 5', () {
    for (int index = 0; index < stageCatalog.length - 1; index++) {
      final current = stageDefinition(stageCatalog[index]);
      final next = stageDefinition(stageCatalog[index + 1]);

      expect(next.recommendedPower, greaterThan(current.recommendedPower));
      expect(next.searchDuration, greaterThanOrEqualTo(current.searchDuration));
      expect(next.goldSuccess, greaterThan(current.goldSuccess));
      expect(next.essenceSuccess, greaterThan(current.essenceSuccess));
      expect(next.xpSuccessBase, greaterThan(current.xpSuccessBase));
    }
  });

  test('mid stages use expanded enemy sets while final stage stays boss-focused', () {
    expect(enemyDefinitionsForStage('stage_1'), hasLength(2));
    expect(enemyDefinitionsForStage('stage_2'), hasLength(3));
    expect(enemyDefinitionsForStage('stage_3'), hasLength(3));
    expect(enemyDefinitionsForStage('stage_4'), hasLength(3));
    expect(enemyDefinitionsForStage('stage_5'), hasLength(1));
  });
}
