import 'package:alchemist_hunter/features/town/domain/models.dart';

const List<TownSkillNode> townSkillNodes = <TownSkillNode>[
  TownSkillNode(
    id: 'town_trade_ledger',
    name: 'Trade Ledger',
    description: '판매 수익 관리와 상점 운영 효율을 높인다.',
    maxLevel: 2,
    costsByLevel: <List<TownSkillCost>>[
      <TownSkillCost>[
        TownSkillCost(type: TownSkillCostType.townInsight, amount: 1),
      ],
      <TownSkillCost>[
        TownSkillCost(type: TownSkillCostType.townInsight, amount: 2),
        TownSkillCost(type: TownSkillCostType.gold, amount: 150),
      ],
    ],
    prerequisiteNodeIds: <String>[],
    requirements: <TownSkillRequirement>[],
    effects: <TownSkillEffect>[
      TownSkillEffect(
        type: TownSkillEffectType.potionSaleBonus,
        modifierType: TownSkillModifierType.percent,
        value: 0.05,
        label: '포션 판매가 +5%',
      ),
      TownSkillEffect(
        type: TownSkillEffectType.shopRefreshDiscount,
        modifierType: TownSkillModifierType.percent,
        value: 0.1,
        label: '강제 갱신 비용 -10%',
      ),
    ],
  ),
  TownSkillNode(
    id: 'town_hiring_board',
    name: 'Hiring Board',
    description: '더 나은 고용 공고를 붙여 용병 모집 효율을 높인다.',
    maxLevel: 2,
    costsByLevel: <List<TownSkillCost>>[
      <TownSkillCost>[
        TownSkillCost(type: TownSkillCostType.townInsight, amount: 2),
      ],
      <TownSkillCost>[
        TownSkillCost(type: TownSkillCostType.townInsight, amount: 3),
        TownSkillCost(type: TownSkillCostType.gold, amount: 220),
      ],
    ],
    prerequisiteNodeIds: <String>['town_trade_ledger'],
    requirements: <TownSkillRequirement>[
      TownSkillRequirement(
        type: TownSkillRequirementType.mercenaryCount,
        threshold: 2,
        label: '용병 2명 보유',
      ),
    ],
    effects: <TownSkillEffect>[
      TownSkillEffect(
        type: TownSkillEffectType.mercenaryHireDiscount,
        modifierType: TownSkillModifierType.percent,
        value: 0.08,
        label: '용병 고용 비용 -8%',
      ),
    ],
  ),
  TownSkillNode(
    id: 'town_forge_rack',
    name: 'Forge Rack',
    description: '장비 작업대를 확장해 제작 효율을 높인다.',
    maxLevel: 2,
    costsByLevel: <List<TownSkillCost>>[
      <TownSkillCost>[
        TownSkillCost(type: TownSkillCostType.townInsight, amount: 2),
      ],
      <TownSkillCost>[
        TownSkillCost(type: TownSkillCostType.townInsight, amount: 4),
        TownSkillCost(type: TownSkillCostType.gold, amount: 280),
      ],
    ],
    prerequisiteNodeIds: <String>['town_trade_ledger'],
    requirements: <TownSkillRequirement>[
      TownSkillRequirement(
        type: TownSkillRequirementType.equipmentCraftCount,
        threshold: 3,
        label: '장비 제작 3회',
      ),
    ],
    effects: <TownSkillEffect>[
      TownSkillEffect(
        type: TownSkillEffectType.equipmentCraftEfficiency,
        modifierType: TownSkillModifierType.percent,
        value: 0.1,
        label: '장비 제작 효율 +10%',
      ),
    ],
  ),
];
