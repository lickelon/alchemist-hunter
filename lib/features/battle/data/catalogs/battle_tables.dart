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
          BattleDropEntry(materialId: 'm_1', min: 1, max: 3, chance: 0.86),
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
          BattleDropEntry(materialId: 'm_2', min: 1, max: 2, chance: 0.74),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_25', min: 1, max: 1, chance: 0.24),
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
          BattleDropEntry(materialId: 'm_29', min: 1, max: 2, chance: 0.88),
        ],
        specialDrops: <BattleDropEntry>[
          BattleDropEntry(materialId: 'm_30', min: 1, max: 2, chance: 0.46),
        ],
      ),
    };

const Map<String, BattleEnemySetDefinition> battleEnemySetDefinitions =
    <String, BattleEnemySetDefinition>{
      'enemy_set_stage_1': BattleEnemySetDefinition(
        id: 'enemy_set_stage_1',
        name: 'Ruins Entrance',
        enemyIds: <String>['enemy_scavenger', 'enemy_wisp'],
        summary: '기초 재료와 첫 특수 촉매를 얻는 초입 구간',
      ),
      'enemy_set_stage_2': BattleEnemySetDefinition(
        id: 'enemy_set_stage_2',
        name: 'Dust Trail',
        enemyIds: <String>['enemy_scout', 'enemy_stalker'],
        summary: '정찰 사격과 연타 압박이 섞인 중반 진입 구간',
      ),
      'enemy_set_stage_3': BattleEnemySetDefinition(
        id: 'enemy_set_stage_3',
        name: 'Ash Workshop',
        enemyIds: <String>['enemy_sentinel', 'enemy_apprentice'],
        summary: '장갑형 수호기와 연금 마도 적 조합',
      ),
      'enemy_set_stage_4': BattleEnemySetDefinition(
        id: 'enemy_set_stage_4',
        name: 'Storm Gallery',
        enemyIds: <String>['enemy_sniper', 'enemy_weaver'],
        summary: '필중 사격과 광역 마도 압박 구간',
      ),
      'enemy_set_stage_5': BattleEnemySetDefinition(
        id: 'enemy_set_stage_5',
        name: 'Moontear Core',
        enemyIds: <String>['enemy_chimera'],
        summary: '희귀 촉매를 지키는 단일 보스전',
      ),
    };

const Map<String, BattleStageDefinition> battleStageDefinitions =
    <String, BattleStageDefinition>{
      'stage_1': BattleStageDefinition(
        id: 'stage_1',
        name: '폐허 입구',
        recommendedPower: 220,
        searchDuration: Duration(seconds: 8),
        enemySetId: 'enemy_set_stage_1',
        goldSuccess: 28,
        goldFailurePenalty: 12,
        essenceSuccess: 4,
        essenceFailure: 2,
        xpSuccessBase: 18,
        xpFailureBase: 8,
        clearUnlockFlags: <String>{'stage_2'},
      ),
      'stage_2': BattleStageDefinition(
        id: 'stage_2',
        name: '먼지 회랑',
        recommendedPower: 280,
        searchDuration: Duration(seconds: 9),
        enemySetId: 'enemy_set_stage_2',
        goldSuccess: 40,
        goldFailurePenalty: 14,
        essenceSuccess: 6,
        essenceFailure: 3,
        xpSuccessBase: 24,
        xpFailureBase: 10,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_1',
          label: '잠금 조건: 1단계 클리어 필요',
        ),
        clearUnlockFlags: <String>{'stage_3'},
      ),
      'stage_3': BattleStageDefinition(
        id: 'stage_3',
        name: '재의 공방',
        recommendedPower: 350,
        searchDuration: Duration(seconds: 11),
        enemySetId: 'enemy_set_stage_3',
        goldSuccess: 56,
        goldFailurePenalty: 18,
        essenceSuccess: 9,
        essenceFailure: 4,
        xpSuccessBase: 32,
        xpFailureBase: 12,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_2',
          label: '잠금 조건: 2단계 클리어 필요',
        ),
        clearUnlockFlags: <String>{'stage_4', 'potion_special_1'},
      ),
      'stage_4': BattleStageDefinition(
        id: 'stage_4',
        name: '폭풍 전시실',
        recommendedPower: 430,
        searchDuration: Duration(seconds: 13),
        enemySetId: 'enemy_set_stage_4',
        goldSuccess: 78,
        goldFailurePenalty: 22,
        essenceSuccess: 13,
        essenceFailure: 5,
        xpSuccessBase: 44,
        xpFailureBase: 14,
        unlockCondition: BattleStageUnlockCondition(
          requiredStageId: 'stage_3',
          label: '잠금 조건: 3단계 클리어 필요',
        ),
        clearUnlockFlags: <String>{'stage_5'},
      ),
      'stage_5': BattleStageDefinition(
        id: 'stage_5',
        name: '문물의 핵',
        recommendedPower: 520,
        searchDuration: Duration(seconds: 16),
        enemySetId: 'enemy_set_stage_5',
        goldSuccess: 108,
        goldFailurePenalty: 28,
        essenceSuccess: 18,
        essenceFailure: 6,
        xpSuccessBase: 58,
        xpFailureBase: 18,
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
