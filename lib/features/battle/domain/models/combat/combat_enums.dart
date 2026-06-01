enum CombatFaction { mercenary, homunculus }

enum CombatDiscipline { warrior, mage, rogue, archer }

enum BattleModifierType { damageDealt, damageTaken }

enum BattleModifierMode { flat, percent }

enum DamageSchool { any, physical, magical }

enum BattleStatusType { poison, stun }

enum BattlePassiveConditionType {
  always,
  actorHpBelow,
  actorHpAbove,
  targetFaction,
  targetHasStatus,
  criticalHit,
}

enum BattleStatModifierType {
  maxHp,
  maxMp,
  physicalAttack,
  physicalDefense,
  magicalAttack,
  magicalDefense,
  speed,
  critRate,
  critDamage,
  accuracy,
  evasion,
  statusAccuracy,
  statusResistance,
  physicalPenetration,
  magicalPenetration,
  lifesteal,
  healingPower,
  regen,
  mpRegen,
}

enum BattlePassiveTrigger {
  battleStart,
  beforeAction,
  beforeHitCheck,
  beforeDamage,
  afterHit,
  afterAction,
  turnEnd,
  onDamaged,
  onDefeat,
}

enum BattlePassiveEffectType {
  alwaysHit,
  extraAttack,
  firstStrike,
  counterAttack,
  grantModifier,
  grantStatus,
  grantShield,
}

enum BattleSkillTargetType {
  randomEnemy,
  self,
  randomAlly,
  allEnemies,
  allAllies,
}

enum BattleSkillEffectType {
  damage,
  heal,
  grantModifier,
  grantStatus,
  grantShield,
}
