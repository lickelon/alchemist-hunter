import 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

const List<String> _potionNames = <String>[
  '활력 포션',
  '돌격 포션',
  '투지 포션',
  '수호 기동 포션',
  '정밀 포션',
  '흡수 포션',
  '집중 포션',
  '행운 포션',
  '황혼 포션',
  '정화 포션',
  '마력 포션',
  '재생 포션',
  '강인 혼합 포션',
  '사냥꾼 혼합 포션',
  '연금 혼합 포션',
];

final List<PotionBlueprint> potionCatalog = List<PotionBlueprint>.generate(
  15,
  _buildPotionBlueprint,
);

final List<PotionRecipeRule> potionRecipeCatalog = <PotionRecipeRule>[
  PotionRecipeRule(
    id: 'r_hp_atk',
    mainTraitId: 't_hp',
    subTraitId: 't_atk',
    mainPercent: 60,
    subPercent: 40,
    resultPotionId: 'p_1',
  ),
  PotionRecipeRule(
    id: 'r_atk_hp',
    mainTraitId: 't_atk',
    subTraitId: 't_hp',
    mainPercent: 60,
    subPercent: 40,
    resultPotionId: 'p_2',
  ),
  PotionRecipeRule(
    id: 'r_crit_focus',
    mainTraitId: 't_crit',
    subTraitId: 't_focus',
    mainPercent: 55,
    subPercent: 45,
    resultPotionId: 'p_3',
  ),
  PotionRecipeRule(
    id: 'r_def_spd',
    mainTraitId: 't_def',
    subTraitId: 't_spd',
    mainPercent: 65,
    subPercent: 35,
    resultPotionId: 'p_4',
  ),
];

const PotionQualityRule potionQualityCatalog = PotionQualityRule(
  gradeThresholds: <PotionQualityGrade, double>{
    PotionQualityGrade.s: 0.999,
    PotionQualityGrade.a: 0.9,
    PotionQualityGrade.b: 0.7,
    PotionQualityGrade.c: 0.4,
    PotionQualityGrade.f: 0,
  },
);

PotionBlueprint _buildPotionBlueprint(int i) {
  final String id = 'p_${i + 1}';
  final Map<String, double> targetTraits = switch (id) {
    'p_1' => const <String, double>{'t_hp': 0.6, 't_atk': 0.4},
    'p_2' => const <String, double>{'t_atk': 0.6, 't_hp': 0.4},
    'p_3' => const <String, double>{'t_crit': 0.55, 't_focus': 0.45},
    'p_4' => const <String, double>{'t_def': 0.65, 't_spd': 0.35},
    _ => <String, double>{
      traitCatalog[i % 12].id: 0.6,
      traitCatalog[(i + 1) % 12].id: 0.4,
    },
  };
  return PotionBlueprint(
    id: id,
    name: _potionNames[i],
    targetTraits: targetTraits,
    baseValue: 100 + (i * 25),
    useType: i < 10 ? PotionUseType.both : PotionUseType.combat,
  );
}
