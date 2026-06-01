part of 'battle_combat_stat_service.dart';

const Map<String, List<BattleSkillDefinition>> _skillsByJob =
    <String, List<BattleSkillDefinition>>{
      CombatJobIds.mercenaryWarrior: <BattleSkillDefinition>[
        BattleSkillDefinition(
          id: 'mercenary_warrior_shield_break',
          name: '방패 강타',
          summary: '강한 일격으로 무작위 적에게 물리 피해를 준다.',
          targetType: BattleSkillTargetType.randomEnemy,
          effectType: BattleSkillEffectType.damage,
          school: DamageSchool.physical,
          powerMultiplier: 1.45,
          flatPower: 4,
        ),
      ],
      CombatJobIds.mercenaryMage: <BattleSkillDefinition>[
        BattleSkillDefinition(
          id: 'mercenary_mage_fireball',
          name: '화염구',
          summary: '압축한 화염으로 모든 적에게 마법 피해를 준다.',
          targetType: BattleSkillTargetType.allEnemies,
          effectType: BattleSkillEffectType.damage,
          school: DamageSchool.magical,
          powerMultiplier: 0.95,
          flatPower: 4,
        ),
      ],
      CombatJobIds.mercenaryRogue: <BattleSkillDefinition>[
        BattleSkillDefinition(
          id: 'mercenary_rogue_expose',
          name: '약점 노출',
          summary: '무작위 적이 받는 피해를 잠시 증가시킨다.',
          targetType: BattleSkillTargetType.randomEnemy,
          effectType: BattleSkillEffectType.grantModifier,
          durationLifecycles: 2,
          modifier: BattleModifier(
            type: BattleModifierType.damageTaken,
            mode: BattleModifierMode.percent,
            value: 0.16,
            sourceId: 'mercenary_rogue_expose',
          ),
        ),
      ],
      CombatJobIds.mercenaryArcher: <BattleSkillDefinition>[
        BattleSkillDefinition(
          id: 'mercenary_archer_piercing_shot',
          name: '관통 사격',
          summary: '방어선을 꿰뚫는 화살로 무작위 적에게 물리 피해를 준다.',
          targetType: BattleSkillTargetType.randomEnemy,
          effectType: BattleSkillEffectType.damage,
          school: DamageSchool.physical,
          powerMultiplier: 1.55,
          flatPower: 3,
        ),
      ],
      CombatJobIds.homunculusWarrior: <BattleSkillDefinition>[
        BattleSkillDefinition(
          id: 'homunculus_warrior_bio_guard',
          name: '생체 장갑',
          summary: '자신에게 보호막을 부여한다.',
          targetType: BattleSkillTargetType.self,
          effectType: BattleSkillEffectType.grantShield,
          shieldValue: 18,
        ),
      ],
      CombatJobIds.homunculusMage: <BattleSkillDefinition>[
        BattleSkillDefinition(
          id: 'homunculus_mage_reconstruct',
          name: '재구성',
          summary: '모든 아군의 체력을 회복한다.',
          targetType: BattleSkillTargetType.allAllies,
          effectType: BattleSkillEffectType.heal,
          flatPower: 12,
        ),
      ],
      CombatJobIds.homunculusRogue: <BattleSkillDefinition>[
        BattleSkillDefinition(
          id: 'homunculus_rogue_acid_infusion',
          name: '산성 주입',
          summary: '무작위 적에게 독을 부여한다.',
          targetType: BattleSkillTargetType.randomEnemy,
          effectType: BattleSkillEffectType.grantStatus,
          statusType: BattleStatusType.poison,
          durationLifecycles: 3,
          flatPower: 5,
        ),
      ],
      CombatJobIds.homunculusArcher: <BattleSkillDefinition>[
        BattleSkillDefinition(
          id: 'homunculus_archer_resonance_shot',
          name: '공명 사격',
          summary: '모든 적에게 마법 피해를 준다.',
          targetType: BattleSkillTargetType.allEnemies,
          effectType: BattleSkillEffectType.damage,
          school: DamageSchool.magical,
          powerMultiplier: 0.9,
          flatPower: 4,
        ),
      ],
    };
