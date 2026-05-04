import 'package:alchemist_hunter/features/battle/domain/models.dart';

const Map<String, BattleEnemyDefinition> battleEnemyDefinitions =
    <String, BattleEnemyDefinition>{
      'enemy_scavenger': BattleEnemyDefinition(
        id: 'enemy_scavenger',
        name: 'Ruin Scavenger',
        faction: CombatFaction.homunculus,
        summary: '잔해를 모으는 전열형',
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
          BattleDropEntry(materialId: 'm_1', min: 1, max: 3, chance: 0.82),
          BattleDropEntry(materialId: 'm_2', min: 1, max: 2, chance: 0.7),
        ],
      ),
      'enemy_wisp': BattleEnemyDefinition(
        id: 'enemy_wisp',
        name: 'Moontear Wisp',
        faction: CombatFaction.homunculus,
        summary: '희귀 재료를 품은 부유체',
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
          BattleDropEntry(materialId: 'm_7', min: 1, max: 1, chance: 0.55),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_27', min: 1, max: 1, chance: 0.22),
          BattleDropEntry(materialId: 'm_30', min: 1, max: 1, chance: 0.14),
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
          accuracy: 0.9,
          evasion: 0.06,
          statusAccuracy: 0.03,
          statusResistance: 0.04,
          physicalPenetration: 0.03,
          magicalPenetration: 0.01,
          lifesteal: 0,
          healingPower: 0,
          regen: 0.01,
        ),
        modifiers: <BattleModifier>[
          BattleModifier(
            type: BattleModifierType.accuracy,
            mode: BattleModifierMode.flat,
            value: 0.04,
            sourceId: 'enemy_scout_focus',
          ),
        ],
        normalDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_2', min: 1, max: 2, chance: 0.72),
          BattleDropEntry(materialId: 'm_7', min: 1, max: 1, chance: 0.45),
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
          BattleDropEntry(materialId: 'm_1', min: 1, max: 2, chance: 0.7),
          BattleDropEntry(materialId: 'm_7', min: 1, max: 1, chance: 0.5),
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
          BattleDropEntry(materialId: 'm_2', min: 1, max: 2, chance: 0.76),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_27', min: 1, max: 1, chance: 0.28),
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
          BattleDropEntry(materialId: 'm_1', min: 2, max: 3, chance: 0.82),
          BattleDropEntry(materialId: 'm_2', min: 1, max: 2, chance: 0.78),
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
          BattleDropEntry(materialId: 'm_7', min: 1, max: 1, chance: 0.7),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_27', min: 1, max: 1, chance: 0.34),
        ],
      ),
      'enemy_chimera': BattleEnemyDefinition(
        id: 'enemy_chimera',
        name: 'Moontear Chimera',
        faction: CombatFaction.homunculus,
        summary: '흡혈과 압박을 겸한 단일 보스',
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
          BattleDropEntry(materialId: 'm_1', min: 2, max: 3, chance: 0.88),
          BattleDropEntry(materialId: 'm_7', min: 1, max: 2, chance: 0.72),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_30', min: 1, max: 2, chance: 0.4),
        ],
      ),
    };

const Map<String, BattleEnemySetDefinition> battleEnemySetDefinitions =
    <String, BattleEnemySetDefinition>{
      'enemy_set_stage_1': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1',
        name: 'Ruins Entrance',
        enemyIds: <String>['enemy_scavenger', 'enemy_wisp'],
        summary: '잡몹 2기 / 기본 재료와 희소 재료 초입',
      ),
      'enemy_set_stage_2': BattleEnemySetDefinition(
        id: 'enemy_set_stage_2',
        name: 'Dust Trail',
        enemyIds: <String>['enemy_scavenger', 'enemy_scout'],
        summary: '방어형 1기 + 원거리 1기',
      ),
      'enemy_set_stage_3': BattleEnemySetDefinition(
        id: 'enemy_set_stage_3',
        name: 'Ash Workshop',
        enemyIds: <String>['enemy_sentinel', 'enemy_apprentice'],
        summary: '탱커 1기 + 마법형 1기',
      ),
      'enemy_set_stage_4': BattleEnemySetDefinition(
        id: 'enemy_set_stage_4',
        name: 'Storm Gallery',
        enemyIds: <String>['enemy_sniper', 'enemy_stalker'],
        summary: '필중 저격 + 연타형 암살자',
      ),
      'enemy_set_stage_5': BattleEnemySetDefinition(
        id: 'enemy_set_stage_5',
        name: 'Moontear Core',
        enemyIds: <String>['enemy_chimera'],
        summary: '단일 보스전',
      ),
    };

const Map<String, BattleStageDefinition> battleStageDefinitions =
    <String, BattleStageDefinition>{
      'stage_1': BattleStageDefinition(
        id: 'stage_1',
        name: 'Stage 1',
        recommendedPower: 220,
        cycleDuration: Duration(seconds: 60),
        enemySetId: 'enemy_set_stage_1',
        goldSuccess: 35,
        goldFailurePenalty: 15,
        essenceSuccess: 6,
        essenceFailure: 2,
        xpSuccessBase: 20,
        xpFailureBase: 8,
      ),
      'stage_2': BattleStageDefinition(
        id: 'stage_2',
        name: 'Stage 2',
        recommendedPower: 260,
        cycleDuration: Duration(seconds: 60),
        enemySetId: 'enemy_set_stage_2',
        goldSuccess: 35,
        goldFailurePenalty: 15,
        essenceSuccess: 6,
        essenceFailure: 2,
        xpSuccessBase: 24,
        xpFailureBase: 10,
      ),
      'stage_3': BattleStageDefinition(
        id: 'stage_3',
        name: 'Stage 3',
        recommendedPower: 320,
        cycleDuration: Duration(seconds: 60),
        enemySetId: 'enemy_set_stage_3',
        goldSuccess: 35,
        goldFailurePenalty: 15,
        essenceSuccess: 6,
        essenceFailure: 2,
        xpSuccessBase: 28,
        xpFailureBase: 12,
      ),
      'stage_4': BattleStageDefinition(
        id: 'stage_4',
        name: 'Stage 4',
        recommendedPower: 380,
        cycleDuration: Duration(seconds: 60),
        enemySetId: 'enemy_set_stage_4',
        goldSuccess: 35,
        goldFailurePenalty: 15,
        essenceSuccess: 6,
        essenceFailure: 2,
        xpSuccessBase: 32,
        xpFailureBase: 14,
      ),
      'stage_5': BattleStageDefinition(
        id: 'stage_5',
        name: 'Stage 5',
        recommendedPower: 460,
        cycleDuration: Duration(seconds: 60),
        enemySetId: 'enemy_set_stage_5',
        goldSuccess: 35,
        goldFailurePenalty: 15,
        essenceSuccess: 6,
        essenceFailure: 2,
        xpSuccessBase: 36,
        xpFailureBase: 16,
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

List<BattleEnemyDefinition> enemyDefinitionsForStage(String stageId) {
  final BattleStageDefinition stage = stageDefinition(stageId);
  final BattleEnemySetDefinition enemySet = enemySetDefinition(
    stage.enemySetId,
  );
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
