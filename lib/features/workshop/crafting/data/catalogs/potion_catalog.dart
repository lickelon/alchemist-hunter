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
  (int i) => PotionBlueprint(
    id: 'p_${i + 1}',
    name: _potionNames[i],
    targetTraits: <String, double>{
      traitCatalog[i % 12].id: 0.6,
      traitCatalog[(i + 1) % 12].id: 0.4,
    },
    baseValue: 100 + (i * 25),
    useType: i < 10 ? PotionUseType.both : PotionUseType.combat,
  ),
);

const List<PotionRecipeRule> potionRecipeCatalog = <PotionRecipeRule>[
  PotionRecipeRule(
    id: 'r_hp_atk',
    requiredTraits: <String>{'t_hp', 't_atk'},
    resultPotionId: 'p_3',
  ),
  PotionRecipeRule(
    id: 'r_def_spd',
    requiredTraits: <String>{'t_def', 't_spd'},
    resultPotionId: 'p_4',
  ),
];

const List<PotionRecipeBranchRule> potionRecipeBranchCatalog =
    <PotionRecipeBranchRule>[
      PotionRecipeBranchRule(
        recipeId: 'r_hp_atk',
        dominantTrait: 't_hp',
        ratioGapMin: 0.05,
        branchedPotionId: 'p_1',
      ),
      PotionRecipeBranchRule(
        recipeId: 'r_hp_atk',
        dominantTrait: 't_atk',
        ratioGapMin: 0.05,
        branchedPotionId: 'p_2',
      ),
    ];

const PotionQualityRule potionQualityCatalog = PotionQualityRule(
  gradeThresholds: <PotionQualityGrade, double>{
    PotionQualityGrade.s: 0.92,
    PotionQualityGrade.a: 0.78,
    PotionQualityGrade.b: 0.58,
    PotionQualityGrade.c: 0,
  },
);
