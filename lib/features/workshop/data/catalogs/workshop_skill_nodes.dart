import 'package:alchemist_hunter/features/workshop/domain/models.dart';

const List<WorkshopSkillNode> workshopSkillNodes = <WorkshopSkillNode>[
  WorkshopSkillNode(
    id: 'workshop_alembic',
    name: 'Alembic Array',
    description: '추출 설비를 정돈해 수율을 안정적으로 끌어올린다.',
    maxLevel: 2,
    costsByLevel: <List<WorkshopSkillCost>>[
      <WorkshopSkillCost>[
        WorkshopSkillCost(type: WorkshopSkillCostType.arcaneDust, amount: 1),
      ],
      <WorkshopSkillCost>[
        WorkshopSkillCost(type: WorkshopSkillCostType.arcaneDust, amount: 2),
        WorkshopSkillCost(
          type: WorkshopSkillCostType.element,
          amount: 1,
          elementId: 't_hp',
        ),
      ],
    ],
    prerequisiteNodeIds: <String>[],
    requirements: <WorkshopSkillRequirement>[],
    effects: <WorkshopSkillEffect>[
      WorkshopSkillEffect(
        type: WorkshopSkillEffectType.extractionYield,
        modifierType: WorkshopSkillModifierType.percent,
        value: 0.08,
        label: '추출 수율 +8%',
      ),
    ],
  ),
  WorkshopSkillNode(
    id: 'workshop_queue_matrix',
    name: 'Queue Matrix',
    description: '제작 흐름을 정리해 연속 작업을 더 부드럽게 만든다.',
    maxLevel: 2,
    costsByLevel: <List<WorkshopSkillCost>>[
      <WorkshopSkillCost>[
        WorkshopSkillCost(type: WorkshopSkillCostType.arcaneDust, amount: 2),
      ],
      <WorkshopSkillCost>[
        WorkshopSkillCost(type: WorkshopSkillCostType.arcaneDust, amount: 3),
        WorkshopSkillCost(
          type: WorkshopSkillCostType.element,
          amount: 1,
          elementId: 't_atk',
        ),
      ],
    ],
    prerequisiteNodeIds: <String>['workshop_alembic'],
    requirements: <WorkshopSkillRequirement>[
      WorkshopSkillRequirement(
        type: WorkshopSkillRequirementType.potionCraftCount,
        threshold: 5,
        label: '포션 제작 5회',
      ),
    ],
    effects: <WorkshopSkillEffect>[
      WorkshopSkillEffect(
        type: WorkshopSkillEffectType.craftQueueCapacity,
        modifierType: WorkshopSkillModifierType.flat,
        value: 1,
        label: '제작 큐 용량 +1',
      ),
    ],
  ),
  WorkshopSkillNode(
    id: 'workshop_sigil_press',
    name: 'Sigil Press',
    description: '인챈트 각인을 정밀하게 눌러 강화량을 높인다.',
    maxLevel: 2,
    costsByLevel: <List<WorkshopSkillCost>>[
      <WorkshopSkillCost>[
        WorkshopSkillCost(type: WorkshopSkillCostType.arcaneDust, amount: 2),
      ],
      <WorkshopSkillCost>[
        WorkshopSkillCost(type: WorkshopSkillCostType.arcaneDust, amount: 4),
        WorkshopSkillCost(
          type: WorkshopSkillCostType.element,
          amount: 1,
          elementId: 't_def',
        ),
      ],
    ],
    prerequisiteNodeIds: <String>['workshop_alembic'],
    requirements: <WorkshopSkillRequirement>[
      WorkshopSkillRequirement(
        type: WorkshopSkillRequirementType.enchantCount,
        threshold: 3,
        label: '인챈트 3회',
      ),
    ],
    effects: <WorkshopSkillEffect>[
      WorkshopSkillEffect(
        type: WorkshopSkillEffectType.enchantPotency,
        modifierType: WorkshopSkillModifierType.percent,
        value: 0.12,
        label: '인챈트 강화량 +12%',
      ),
    ],
  ),
];
