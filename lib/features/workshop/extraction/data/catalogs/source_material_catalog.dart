import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/material_names.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/trait_catalog.dart';

final List<MaterialEntity> sourceMaterialCatalog =
    List<MaterialEntity>.generate(
      30,
      (int i) => MaterialEntity(
        id: 'm_${i + 1}',
        name: materialNames[i],
        rarity: i < 24 ? MaterialRarity.common : MaterialRarity.rare,
        traits: <TraitUnit>[
          traitCatalog[i % traitCatalog.length],
          traitCatalog[(i + 3) % traitCatalog.length],
        ],
        analyzable: true,
        source: materialSource(i + 1),
      ),
    );

String materialSource(int materialNumber) {
  return switch (materialNumber) {
    1 || 2 || 25 => 'battle_stage_1',
    3 || 4 || 26 => 'battle_stage_2',
    5 || 6 || 27 => 'battle_stage_3',
    7 || 8 || 28 => 'battle_stage_4',
    29 || 30 => 'battle_stage_5',
    _ => 'battle',
  };
}
