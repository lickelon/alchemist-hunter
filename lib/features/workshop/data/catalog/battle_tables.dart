import 'package:alchemist_hunter/features/workshop/domain/models.dart';

final List<String> stageCatalog = List<String>.generate(
  5,
  (int i) => 'stage_${i + 1}',
);

final List<String> enemySetCatalog = List<String>.generate(
  20,
  (int i) => 'enemy_set_${i + 1}',
);

BattleDropTable stageDropTable(String stageId) {
  return BattleDropTable(
    stageId: stageId,
    normalDrops: const <BattleDropEntry>[
      BattleDropEntry(materialId: 'm_1', min: 1, max: 3, chance: 0.8),
      BattleDropEntry(materialId: 'm_2', min: 1, max: 2, chance: 0.7),
      BattleDropEntry(materialId: 'm_7', min: 1, max: 1, chance: 0.4),
    ],
    specialDrops: const <BattleDropEntry>[
      BattleDropEntry(materialId: 'm_27', min: 1, max: 1, chance: 0.35),
      BattleDropEntry(materialId: 'm_30', min: 1, max: 2, chance: 0.2),
    ],
  );
}
