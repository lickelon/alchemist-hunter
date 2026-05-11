import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemyDefinition> battleEnemyDefinitions =
    <String, BattleEnemyDefinition>{
      'enemy_scavenger': BattleEnemyDefinition(
        id: 'enemy_scavenger',
        name: 'Ruin Scavenger',
        faction: CombatFaction.homunculus,
        summary: '잔해를 주워 버티는 전열형',
        stats: BattleCombatStats(
          maxHp: 46,
          physicalAttack: 10,
          physicalDefense: 9,
          magicalAttack: 4,
          magicalDefense: 7,
          speed: 8,
          critChance: 0.04,
          critDamage: 0.45,
          accuracy: 0.84,
          evasion: 0.03,
          statusAccuracy: 0.03,
          statusResistance: 0.04,
          physicalPenetration: 0.02,
          magicalPenetration: 0.01,
          lifesteal: 0,
          healingPower: 0,
          regen: 0.01,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageTaken,
            mode: BattleModifierMode.percent,
            value: -0.05,
            sourceId: 'enemy_scavenger_hide',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_1', min: 1, max: 3, chance: 0.86),
        ],
      ),
      'enemy_wisp': BattleEnemyDefinition(
        id: 'enemy_wisp',
        name: 'Moontear Wisp',
        faction: CombatFaction.homunculus,
        summary: '희귀 촉매를 품은 부유체',
        stats: BattleCombatStats(
          maxHp: 38,
          physicalAttack: 4,
          physicalDefense: 5,
          magicalAttack: 12,
          magicalDefense: 8,
          speed: 10,
          critChance: 0.05,
          critDamage: 0.45,
          accuracy: 0.88,
          evasion: 0.05,
          statusAccuracy: 0.06,
          statusResistance: 0.05,
          physicalPenetration: 0.01,
          magicalPenetration: 0.03,
          lifesteal: 0,
          healingPower: 0.02,
          regen: 0.01,
        ),
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_2', min: 1, max: 2, chance: 0.74),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_25', min: 1, max: 1, chance: 0.24),
        ],
      ),
      'enemy_mite': BattleEnemyDefinition(
        id: 'enemy_mite',
        name: 'Ash Mite',
        faction: CombatFaction.homunculus,
        summary: '빠르게 파고드는 군체형',
        stats: BattleCombatStats(
          maxHp: 34,
          physicalAttack: 8,
          physicalDefense: 4,
          magicalAttack: 3,
          magicalDefense: 4,
          speed: 12,
          critChance: 0.05,
          critDamage: 0.42,
          accuracy: 0.86,
          evasion: 0.06,
          statusAccuracy: 0.02,
          statusResistance: 0.03,
          physicalPenetration: 0.02,
          magicalPenetration: 0.01,
          lifesteal: 0,
          healingPower: 0,
          regen: 0,
        ),
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_1', min: 1, max: 2, chance: 0.7),
          BattleDropEntry(materialId: 'm_2', min: 1, max: 1, chance: 0.32),
        ],
      ),
      'enemy_scout': BattleEnemyDefinition(
        id: 'enemy_scout',
        name: 'Dust Scout',
        faction: CombatFaction.mercenary,
        summary: '견제 사격 중심의 정찰병',
        stats: BattleCombatStats(
          maxHp: 44,
          physicalAttack: 12,
          physicalDefense: 6,
          magicalAttack: 4,
          magicalDefense: 6,
          speed: 11,
          critChance: 0.06,
          critDamage: 0.48,
          accuracy: 0.94,
          evasion: 0.06,
          statusAccuracy: 0.03,
          statusResistance: 0.04,
          physicalPenetration: 0.03,
          magicalPenetration: 0.01,
          lifesteal: 0,
          healingPower: 0,
          regen: 0.01,
        ),
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_3', min: 1, max: 2, chance: 0.78),
        ],
      ),
      'enemy_stalker': BattleEnemyDefinition(
        id: 'enemy_stalker',
        name: 'Shade Stalker',
        faction: CombatFaction.homunculus,
        summary: '후열을 노리는 연타형',
        stats: BattleCombatStats(
          maxHp: 48,
          physicalAttack: 13,
          physicalDefense: 7,
          magicalAttack: 5,
          magicalDefense: 6,
          speed: 13,
          critChance: 0.08,
          critDamage: 0.5,
          accuracy: 0.9,
          evasion: 0.08,
          statusAccuracy: 0.04,
          statusResistance: 0.05,
          physicalPenetration: 0.04,
          magicalPenetration: 0.01,
          lifesteal: 0.01,
          healingPower: 0,
          regen: 0.01,
        ),
        passives: <BattlePassiveEffect>[
          BattlePassiveEffect(
            trigger: BattlePassiveTrigger.afterAction,
            type: BattlePassiveEffectType.extraAttack,
            sourceId: 'enemy_stalker_flurry',
            value: 1,
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_4', min: 1, max: 2, chance: 0.7),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_26', min: 1, max: 1, chance: 0.22),
        ],
      ),
      'enemy_bruiser': BattleEnemyDefinition(
        id: 'enemy_bruiser',
        name: 'Scrap Bruiser',
        faction: CombatFaction.mercenary,
        summary: '느리지만 묵직하게 압박하는 근접형',
        stats: BattleCombatStats(
          maxHp: 58,
          physicalAttack: 15,
          physicalDefense: 9,
          magicalAttack: 3,
          magicalDefense: 6,
          speed: 8,
          critChance: 0.04,
          critDamage: 0.48,
          accuracy: 0.87,
          evasion: 0.02,
          statusAccuracy: 0.03,
          statusResistance: 0.05,
          physicalPenetration: 0.03,
          magicalPenetration: 0,
          lifesteal: 0,
          healingPower: 0,
          regen: 0.01,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageDealt,
            mode: BattleModifierMode.percent,
            value: 0.08,
            sourceId: 'enemy_bruiser_overhead_swing',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_4', min: 1, max: 3, chance: 0.8),
        ],
      ),
      'enemy_raider': BattleEnemyDefinition(
        id: 'enemy_raider',
        name: 'Dust Raider',
        faction: CombatFaction.mercenary,
        summary: '짧은 교전 뒤 파고드는 돌격형',
        stats: BattleCombatStats(
          maxHp: 50,
          physicalAttack: 14,
          physicalDefense: 7,
          magicalAttack: 4,
          magicalDefense: 6,
          speed: 12,
          critChance: 0.05,
          critDamage: 0.48,
          accuracy: 0.9,
          evasion: 0.05,
          statusAccuracy: 0.03,
          statusResistance: 0.05,
          physicalPenetration: 0.04,
          magicalPenetration: 0.01,
          lifesteal: 0.01,
          healingPower: 0,
          regen: 0.01,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageDealt,
            mode: BattleModifierMode.percent,
            value: 0.06,
            school: DamageSchool.physical,
            sourceId: 'enemy_raider_lunge',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_3', min: 1, max: 2, chance: 0.68),
          BattleDropEntry(materialId: 'm_4', min: 1, max: 1, chance: 0.36),
        ],
      ),
      'enemy_apprentice': BattleEnemyDefinition(
        id: 'enemy_apprentice',
        name: 'Ash Apprentice',
        faction: CombatFaction.mercenary,
        summary: '마력 증폭형 견습 연금술사',
        stats: BattleCombatStats(
          maxHp: 52,
          physicalAttack: 5,
          physicalDefense: 7,
          magicalAttack: 15,
          magicalDefense: 9,
          speed: 11,
          critChance: 0.06,
          critDamage: 0.5,
          accuracy: 0.91,
          evasion: 0.05,
          statusAccuracy: 0.07,
          statusResistance: 0.06,
          physicalPenetration: 0.01,
          magicalPenetration: 0.04,
          lifesteal: 0,
          healingPower: 0.03,
          regen: 0.01,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageDealt,
            mode: BattleModifierMode.percent,
            value: 0.12,
            school: DamageSchool.magical,
            sourceId: 'enemy_apprentice_arcane_surge',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_6', min: 1, max: 2, chance: 0.76),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_27', min: 1, max: 1, chance: 0.28),
        ],
      ),
      'enemy_crucible': BattleEnemyDefinition(
        id: 'enemy_crucible',
        name: 'Crucible Hound',
        faction: CombatFaction.homunculus,
        summary: '달궈진 몸체로 밀어붙이는 돌진형',
        stats: BattleCombatStats(
          maxHp: 66,
          physicalAttack: 16,
          physicalDefense: 11,
          magicalAttack: 8,
          magicalDefense: 9,
          speed: 11,
          critChance: 0.05,
          critDamage: 0.5,
          accuracy: 0.9,
          evasion: 0.04,
          statusAccuracy: 0.04,
          statusResistance: 0.06,
          physicalPenetration: 0.04,
          magicalPenetration: 0.02,
          lifesteal: 0,
          healingPower: 0,
          regen: 0.015,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageTaken,
            mode: BattleModifierMode.percent,
            value: -0.08,
            sourceId: 'enemy_crucible_molten_hide',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_5', min: 1, max: 3, chance: 0.8),
        ],
      ),
      'enemy_sentinel': BattleEnemyDefinition(
        id: 'enemy_sentinel',
        name: 'Clockwork Sentinel',
        faction: CombatFaction.homunculus,
        summary: '장갑형 자동 수호기',
        stats: BattleCombatStats(
          maxHp: 60,
          physicalAttack: 14,
          physicalDefense: 12,
          magicalAttack: 6,
          magicalDefense: 10,
          speed: 10,
          critChance: 0.05,
          critDamage: 0.5,
          accuracy: 0.9,
          evasion: 0.03,
          statusAccuracy: 0.04,
          statusResistance: 0.08,
          physicalPenetration: 0.03,
          magicalPenetration: 0.02,
          lifesteal: 0,
          healingPower: 0,
          regen: 0.015,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageTaken,
            mode: BattleModifierMode.percent,
            value: -0.12,
            sourceId: 'enemy_sentinel_plating',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_5', min: 1, max: 3, chance: 0.82),
        ],
      ),
      'enemy_distiller': BattleEnemyDefinition(
        id: 'enemy_distiller',
        name: 'Soot Distiller',
        faction: CombatFaction.mercenary,
        summary: '잔열을 돌려 화력을 키우는 후열형',
        stats: BattleCombatStats(
          maxHp: 56,
          physicalAttack: 6,
          physicalDefense: 7,
          magicalAttack: 16,
          magicalDefense: 10,
          speed: 10,
          critChance: 0.05,
          critDamage: 0.48,
          accuracy: 0.9,
          evasion: 0.04,
          statusAccuracy: 0.06,
          statusResistance: 0.06,
          physicalPenetration: 0.01,
          magicalPenetration: 0.04,
          lifesteal: 0,
          healingPower: 0.05,
          regen: 0.02,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageDealt,
            mode: BattleModifierMode.percent,
            value: 0.1,
            school: DamageSchool.magical,
            sourceId: 'enemy_distiller_heat_cycle',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_6', min: 1, max: 2, chance: 0.72),
        ],
      ),
      'enemy_sniper': BattleEnemyDefinition(
        id: 'enemy_sniper',
        name: 'Gale Sniper',
        faction: CombatFaction.mercenary,
        summary: '필중 사격 중심의 저격수',
        stats: BattleCombatStats(
          maxHp: 54,
          physicalAttack: 16,
          physicalDefense: 8,
          magicalAttack: 5,
          magicalDefense: 8,
          speed: 13,
          critChance: 0.08,
          critDamage: 0.52,
          accuracy: 0.94,
          evasion: 0.07,
          statusAccuracy: 0.04,
          statusResistance: 0.06,
          physicalPenetration: 0.05,
          magicalPenetration: 0.01,
          lifesteal: 0,
          healingPower: 0,
          regen: 0.01,
        ),
        passives: <BattlePassiveEffect>[
          BattlePassiveEffect(
            trigger: BattlePassiveTrigger.beforeHitCheck,
            type: BattlePassiveEffectType.alwaysHit,
            sourceId: 'enemy_sniper_true_shot',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_7', min: 1, max: 2, chance: 0.74),
        ],
      ),
      'enemy_weaver': BattleEnemyDefinition(
        id: 'enemy_weaver',
        name: 'Bloom Weaver',
        faction: CombatFaction.homunculus,
        summary: '포자를 흩뿌리는 후열형',
        stats: BattleCombatStats(
          maxHp: 58,
          physicalAttack: 7,
          physicalDefense: 8,
          magicalAttack: 17,
          magicalDefense: 11,
          speed: 12,
          critChance: 0.06,
          critDamage: 0.5,
          accuracy: 0.92,
          evasion: 0.06,
          statusAccuracy: 0.08,
          statusResistance: 0.07,
          physicalPenetration: 0.02,
          magicalPenetration: 0.05,
          lifesteal: 0,
          healingPower: 0.04,
          regen: 0.01,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageDealt,
            mode: BattleModifierMode.percent,
            value: 0.1,
            school: DamageSchool.magical,
            sourceId: 'enemy_weaver_spore_burst',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_8', min: 1, max: 2, chance: 0.72),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_28', min: 1, max: 1, chance: 0.32),
        ],
      ),
      'enemy_tempest': BattleEnemyDefinition(
        id: 'enemy_tempest',
        name: 'Tempest Disciple',
        faction: CombatFaction.mercenary,
        summary: '질주 후 연속 주문을 엮는 기동형',
        stats: BattleCombatStats(
          maxHp: 62,
          physicalAttack: 9,
          physicalDefense: 8,
          magicalAttack: 18,
          magicalDefense: 12,
          speed: 14,
          critChance: 0.07,
          critDamage: 0.52,
          accuracy: 0.93,
          evasion: 0.08,
          statusAccuracy: 0.08,
          statusResistance: 0.07,
          physicalPenetration: 0.02,
          magicalPenetration: 0.05,
          lifesteal: 0,
          healingPower: 0.03,
          regen: 0.01,
        ),
        passives: <BattlePassiveEffect>[
          BattlePassiveEffect(
            trigger: BattlePassiveTrigger.afterAction,
            type: BattlePassiveEffectType.extraAttack,
            sourceId: 'enemy_tempest_chain_cast',
            value: 1,
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_8', min: 1, max: 2, chance: 0.78),
        ],
      ),
      'enemy_mirage': BattleEnemyDefinition(
        id: 'enemy_mirage',
        name: 'Mirage Harrier',
        faction: CombatFaction.homunculus,
        summary: '회피와 견제를 반복하는 교란형',
        stats: BattleCombatStats(
          maxHp: 56,
          physicalAttack: 10,
          physicalDefense: 7,
          magicalAttack: 14,
          magicalDefense: 10,
          speed: 15,
          critChance: 0.06,
          critDamage: 0.5,
          accuracy: 0.91,
          evasion: 0.1,
          statusAccuracy: 0.07,
          statusResistance: 0.07,
          physicalPenetration: 0.03,
          magicalPenetration: 0.04,
          lifesteal: 0,
          healingPower: 0.02,
          regen: 0.01,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageTaken,
            mode: BattleModifierMode.percent,
            value: -0.07,
            sourceId: 'enemy_mirage_distortion',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_7', min: 1, max: 1, chance: 0.34),
          BattleDropEntry(materialId: 'm_8', min: 1, max: 2, chance: 0.62),
        ],
      ),
      'enemy_chimera': BattleEnemyDefinition(
        id: 'enemy_chimera',
        name: 'Moontear Chimera',
        faction: CombatFaction.homunculus,
        summary: '흡혈과 압박을 겸한 보스형',
        stats: BattleCombatStats(
          maxHp: 72,
          physicalAttack: 15,
          physicalDefense: 12,
          magicalAttack: 8,
          magicalDefense: 10,
          speed: 10,
          critChance: 0.06,
          critDamage: 0.55,
          accuracy: 0.91,
          evasion: 0.05,
          statusAccuracy: 0.05,
          statusResistance: 0.08,
          physicalPenetration: 0.04,
          magicalPenetration: 0.03,
          lifesteal: 0.01,
          healingPower: 0,
          regen: 0.01,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageDealt,
            mode: BattleModifierMode.percent,
            value: 0.08,
            sourceId: 'enemy_chimera_fury',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_29', min: 1, max: 2, chance: 0.88),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_30', min: 1, max: 2, chance: 0.46),
        ],
      ),
      'enemy_herald': BattleEnemyDefinition(
        id: 'enemy_herald',
        name: 'Core Herald',
        faction: CombatFaction.mercenary,
        summary: '보스의 틈을 벌리는 고속 보조형',
        stats: BattleCombatStats(
          maxHp: 68,
          physicalAttack: 12,
          physicalDefense: 10,
          magicalAttack: 17,
          magicalDefense: 12,
          speed: 14,
          critChance: 0.07,
          critDamage: 0.52,
          accuracy: 0.93,
          evasion: 0.07,
          statusAccuracy: 0.08,
          statusResistance: 0.08,
          physicalPenetration: 0.03,
          magicalPenetration: 0.05,
          lifesteal: 0,
          healingPower: 0.04,
          regen: 0.01,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageDealt,
            mode: BattleModifierMode.percent,
            value: 0.1,
            school: DamageSchool.magical,
            sourceId: 'enemy_herald_core_signal',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_29', min: 1, max: 2, chance: 0.8),
        ],
      ),
      'enemy_warden': BattleEnemyDefinition(
        id: 'enemy_warden',
        name: 'Moonvault Warden',
        faction: CombatFaction.homunculus,
        summary: '핵심을 지키는 중장갑 호위체',
        stats: BattleCombatStats(
          maxHp: 82,
          physicalAttack: 13,
          physicalDefense: 14,
          magicalAttack: 6,
          magicalDefense: 12,
          speed: 9,
          critChance: 0.04,
          critDamage: 0.48,
          accuracy: 0.88,
          evasion: 0.02,
          statusAccuracy: 0.04,
          statusResistance: 0.1,
          physicalPenetration: 0.03,
          magicalPenetration: 0.02,
          lifesteal: 0,
          healingPower: 0,
          regen: 0.02,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.damageTaken,
            mode: BattleModifierMode.percent,
            value: -0.12,
            sourceId: 'enemy_warden_core_shell',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_29', min: 1, max: 2, chance: 0.84),
        ],
      ),
    };

const Map<String, BattleEnemySetDefinition>
battleEnemySetDefinitions = <String, BattleEnemySetDefinition>{
  'enemy_set_stage_1_patrol': BattleEnemySetDefinition(
    id: 'enemy_set_stage_1_patrol',
    name: 'Ruins Patrol',
    enemyIds: <String>['enemy_scavenger', 'enemy_mite'],
    summary: '기본 약재를 긁어모으는 순찰조',
  ),
  'enemy_set_stage_1_haunt': BattleEnemySetDefinition(
    id: 'enemy_set_stage_1_haunt',
    name: 'Crystal Haunt',
    enemyIds: <String>['enemy_scavenger', 'enemy_wisp'],
    summary: '희귀 촉매를 품은 부유체가 섞인 초입 조합',
  ),
  'enemy_set_stage_1_swarm': BattleEnemySetDefinition(
    id: 'enemy_set_stage_1_swarm',
    name: 'Mite Swarm',
    enemyIds: <String>['enemy_mite', 'enemy_wisp'],
    summary: '빠른 군체와 부유체가 엮이는 초반 혼성 조합',
  ),
  'enemy_set_stage_2_crossfire': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_crossfire',
    name: 'Crossfire Line',
    enemyIds: <String>['enemy_scout', 'enemy_stalker', 'enemy_bruiser'],
    summary: '정찰, 연타, 압박이 모두 들어오는 기본 전개',
  ),
  'enemy_set_stage_2_ambush': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_ambush',
    name: 'Ambush Knot',
    enemyIds: <String>['enemy_scout', 'enemy_stalker', 'enemy_raider'],
    summary: '고속 접근과 기습이 겹치는 교란 조합',
  ),
  'enemy_set_stage_2_assault': BattleEnemySetDefinition(
    id: 'enemy_set_stage_2_assault',
    name: 'Assault Wedge',
    enemyIds: <String>['enemy_scout', 'enemy_bruiser', 'enemy_raider'],
    summary: '전열 압박 비중이 높은 돌격 조합',
  ),
  'enemy_set_stage_3_furnace': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_furnace',
    name: 'Furnace Front',
    enemyIds: <String>['enemy_sentinel', 'enemy_crucible', 'enemy_apprentice'],
    summary: '장갑 수호기와 돌진형이 전열을 잡는 표준 조합',
  ),
  'enemy_set_stage_3_relay': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_relay',
    name: 'Arcane Relay',
    enemyIds: <String>['enemy_sentinel', 'enemy_apprentice', 'enemy_distiller'],
    summary: '후열 화력이 강하게 몰리는 연성 조합',
  ),
  'enemy_set_stage_3_overheat': BattleEnemySetDefinition(
    id: 'enemy_set_stage_3_overheat',
    name: 'Overheat Wing',
    enemyIds: <String>['enemy_crucible', 'enemy_apprentice', 'enemy_distiller'],
    summary: '방어보다 화력 압박이 앞서는 고열 조합',
  ),
  'enemy_set_stage_4_lattice': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_lattice',
    name: 'Storm Lattice',
    enemyIds: <String>['enemy_sniper', 'enemy_weaver', 'enemy_tempest'],
    summary: '필중 견제와 연속 주문이 겹치는 기본 고압 조합',
  ),
  'enemy_set_stage_4_volley': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_volley',
    name: 'Phantom Volley',
    enemyIds: <String>['enemy_sniper', 'enemy_weaver', 'enemy_mirage'],
    summary: '회피 교란 비중이 높은 원거리 압박 조합',
  ),
  'enemy_set_stage_4_hunt': BattleEnemySetDefinition(
    id: 'enemy_set_stage_4_hunt',
    name: 'Chain Hunt',
    enemyIds: <String>['enemy_sniper', 'enemy_tempest', 'enemy_mirage'],
    summary: '기동 교전과 후속 타격이 강한 추격 조합',
  ),
  'enemy_set_stage_5_guarded': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_guarded',
    name: 'Core Keeper',
    enemyIds: <String>['enemy_chimera', 'enemy_warden'],
    summary: '보스와 중장갑 호위체가 함께 버티는 기본 조합',
  ),
  'enemy_set_stage_5_signal': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_signal',
    name: 'Signal Choir',
    enemyIds: <String>['enemy_chimera', 'enemy_herald'],
    summary: '보스와 후열 화력이 동시에 압박하는 조합',
  ),
  'enemy_set_stage_5_awakened': BattleEnemySetDefinition(
    id: 'enemy_set_stage_5_awakened',
    name: 'Full Awakening',
    enemyIds: <String>['enemy_chimera', 'enemy_herald', 'enemy_warden'],
    summary: '최종 구간의 완전체 조합',
  ),
};

const Map<String, BattleStageDefinition> battleStageDefinitions =
    <String, BattleStageDefinition>{
      'stage_1': BattleStageDefinition(
        id: 'stage_1',
        name: '폐허 입구',
        recommendedPower: 210,
        searchDuration: Duration(seconds: 7),
        encounters: <BattleStageEncounterDefinition>[
          BattleStageEncounterDefinition(
            id: 'stage_1_patrol',
            name: '순찰 조합',
            enemySetId: 'enemy_set_stage_1_patrol',
            summary: '기본 약재 중심의 순찰조',
            chance: 0.42,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_haunt',
            name: '부유체 조합',
            enemySetId: 'enemy_set_stage_1_haunt',
            summary: '희귀 촉매가 섞인 초입 조합',
            chance: 0.33,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_1_swarm',
            name: '군체 조합',
            enemySetId: 'enemy_set_stage_1_swarm',
            summary: '빠른 교전 위주의 군체 조합',
            chance: 0.25,
          ),
        ],
        goldSuccess: 24,
        goldFailurePenalty: 0,
        essenceSuccess: 4,
        essenceFailure: 0,
        xpSuccessBase: 16,
        xpFailureBase: 0,
        clearUnlockFlags: <String>{'stage_2'},
      ),
      'stage_2': BattleStageDefinition(
        id: 'stage_2',
        name: '먼지 회랑',
        recommendedPower: 300,
        searchDuration: Duration(seconds: 9),
        encounters: <BattleStageEncounterDefinition>[
          BattleStageEncounterDefinition(
            id: 'stage_2_crossfire',
            name: '교차 화력 조합',
            enemySetId: 'enemy_set_stage_2_crossfire',
            summary: '정찰과 연타, 압박이 고르게 섞인 전개',
            chance: 0.4,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_2_ambush',
            name: '기습 조합',
            enemySetId: 'enemy_set_stage_2_ambush',
            summary: '고속 접근과 후열 압박 비중이 높은 전개',
            chance: 0.34,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_2_assault',
            name: '돌격 조합',
            enemySetId: 'enemy_set_stage_2_assault',
            summary: '전열 압박이 강한 정면 돌파 전개',
            chance: 0.26,
          ),
        ],
        goldSuccess: 42,
        goldFailurePenalty: 0,
        essenceSuccess: 6,
        essenceFailure: 0,
        xpSuccessBase: 24,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_1',
          label: '잠금 조건: 1단계 클리어 필요',
        ),
        clearUnlockFlags: <String>{'stage_3'},
      ),
      'stage_3': BattleStageDefinition(
        id: 'stage_3',
        name: '재의 공방',
        recommendedPower: 390,
        searchDuration: Duration(seconds: 11),
        encounters: <BattleStageEncounterDefinition>[
          BattleStageEncounterDefinition(
            id: 'stage_3_furnace',
            name: '용광 전선 조합',
            enemySetId: 'enemy_set_stage_3_furnace',
            summary: '전열 버티기와 후열 화력이 균형 잡힌 전개',
            chance: 0.38,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_3_relay',
            name: '연성 릴레이 조합',
            enemySetId: 'enemy_set_stage_3_relay',
            summary: '후열 연성 화력이 몰리는 전개',
            chance: 0.34,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_3_overheat',
            name: '과열 조합',
            enemySetId: 'enemy_set_stage_3_overheat',
            summary: '방어보다 화력 압박이 앞서는 전개',
            chance: 0.28,
          ),
        ],
        goldSuccess: 60,
        goldFailurePenalty: 0,
        essenceSuccess: 9,
        essenceFailure: 0,
        xpSuccessBase: 34,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_2',
          label: '잠금 조건: 2단계 클리어 필요',
        ),
        clearUnlockFlags: <String>{'stage_4', 'potion_special_1'},
      ),
      'stage_4': BattleStageDefinition(
        id: 'stage_4',
        name: '폭풍 전시실',
        recommendedPower: 490,
        searchDuration: Duration(seconds: 14),
        encounters: <BattleStageEncounterDefinition>[
          BattleStageEncounterDefinition(
            id: 'stage_4_lattice',
            name: '폭풍 조합',
            enemySetId: 'enemy_set_stage_4_lattice',
            summary: '필중 견제와 연속 주문이 겹치는 기본 전개',
            chance: 0.4,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_4_volley',
            name: '교란 조합',
            enemySetId: 'enemy_set_stage_4_volley',
            summary: '회피 교란 비중이 높은 원거리 전개',
            chance: 0.33,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_4_hunt',
            name: '추격 조합',
            enemySetId: 'enemy_set_stage_4_hunt',
            summary: '기동 교전과 후속 타격이 강한 전개',
            chance: 0.27,
          ),
        ],
        goldSuccess: 86,
        goldFailurePenalty: 0,
        essenceSuccess: 13,
        essenceFailure: 0,
        xpSuccessBase: 46,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_3',
          label: '잠금 조건: 3단계 클리어 필요',
        ),
        clearUnlockFlags: <String>{'stage_5'},
      ),
      'stage_5': BattleStageDefinition(
        id: 'stage_5',
        name: '문물의 핵',
        recommendedPower: 580,
        searchDuration: Duration(seconds: 15),
        encounters: <BattleStageEncounterDefinition>[
          BattleStageEncounterDefinition(
            id: 'stage_5_guarded',
            name: '호위 조합',
            enemySetId: 'enemy_set_stage_5_guarded',
            summary: '보스와 중장갑 호위체가 버티는 전개',
            chance: 0.48,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_signal',
            name: '신호 조합',
            enemySetId: 'enemy_set_stage_5_signal',
            summary: '보스와 후열 화력이 동시에 몰아치는 전개',
            chance: 0.34,
          ),
          BattleStageEncounterDefinition(
            id: 'stage_5_awakened',
            name: '각성 조합',
            enemySetId: 'enemy_set_stage_5_awakened',
            summary: '최종 구간 완전체 전개',
            chance: 0.18,
          ),
        ],
        goldSuccess: 112,
        goldFailurePenalty: 0,
        essenceSuccess: 18,
        essenceFailure: 0,
        xpSuccessBase: 58,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_4',
          label: '잠금 조건: 4단계 클리어 필요',
        ),
        clearUnlockFlags: <String>{'potion_special_2'},
      ),
    };

const List<String> stageCatalog = <String>[
  'stage_1',
  'stage_2',
  'stage_3',
  'stage_4',
  'stage_5',
];

BattleStageDefinition stageDefinition(String stageId) {
  final BattleStageDefinition? definition = battleStageDefinitions[stageId];
  if (definition == null) {
    throw StateError('Unknown stage: $stageId');
  }
  return definition;
}

BattleEnemySetDefinition enemySetDefinition(String enemySetId) {
  final BattleEnemySetDefinition? definition =
      battleEnemySetDefinitions[enemySetId];
  if (definition == null) {
    throw StateError('Unknown enemy set: $enemySetId');
  }
  return definition;
}

List<BattleStageEncounterDefinition> encounterDefinitionsForStage(
  String stageId,
) {
  return stageDefinition(stageId).encounters;
}

List<BattleEnemyDefinition> enemyDefinitionsForSet(String enemySetId) {
  final BattleEnemySetDefinition enemySet = enemySetDefinition(enemySetId);
  return enemySet.enemyIds
      .map((String enemyId) {
        final BattleEnemyDefinition? definition =
            battleEnemyDefinitions[enemyId];
        if (definition == null) {
          throw StateError('Unknown enemy: $enemyId');
        }
        return definition;
      })
      .toList(growable: false);
}

List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) {
  final Map<String, BattleEnemyDefinition> uniqueEnemies =
      <String, BattleEnemyDefinition>{};
  for (final BattleStageEncounterDefinition encounter
      in encounterDefinitionsForStage(stageId)) {
    for (final BattleEnemyDefinition enemy in enemyDefinitionsForSet(
      encounter.enemySetId,
    )) {
      uniqueEnemies[enemy.id] = enemy;
    }
  }
  return uniqueEnemies.values.toList(growable: false);
}

BattleDropTable dropTableForEnemySet({
  required String stageId,
  required String enemySetId,
}) {
  final List<BattleEnemyDefinition> enemies = enemyDefinitionsForSet(
    enemySetId,
  );
  return BattleDropTable(
    stageId: stageId,
    normalDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.normalDrops)
        .toList(growable: false),
    specialDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.specialDrops)
        .toList(growable: false),
  );
}

BattleDropTable stageDropTable(String stageId) {
  final List<BattleEnemyDefinition> enemies = enemyDefinitionsForStage(stageId);
  return BattleDropTable(
    stageId: stageId,
    normalDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.normalDrops)
        .toList(growable: false),
    specialDrops: enemies
        .expand((BattleEnemyDefinition enemy) => enemy.specialDrops)
        .toList(growable: false),
  );
}
