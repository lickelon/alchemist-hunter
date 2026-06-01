part of 'battle_service.dart';

extension _BattleActionSkillEffects on _BattleActionLifecycleMixin {
  _PrimaryActionEffectResult? _applyNonDamageSkillEffects({
    required _ActionLifecycleContext context,
    required List<_BattleUnit> targets,
    required BattleSkillDefinition? skill,
    required _BattleUnit recoveryTarget,
  }) {
    return switch (skill?.effectType) {
      BattleSkillEffectType.heal => _buildNonDamageSkillResult(
        actions: _applyHealSkill(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: 0,
        ),
        recoveryTarget: recoveryTarget,
      ),
      BattleSkillEffectType.grantModifier => _buildNonDamageSkillResult(
        actions: _applySkillModifier(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: 0,
        ),
        recoveryTarget: recoveryTarget,
      ),
      BattleSkillEffectType.grantStatus => _buildNonDamageSkillResult(
        actions: _applySkillStatus(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: 0,
        ),
        recoveryTarget: recoveryTarget,
      ),
      BattleSkillEffectType.grantShield => _buildNonDamageSkillResult(
        actions: _applySkillShield(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: 0,
        ),
        recoveryTarget: recoveryTarget,
      ),
      BattleSkillEffectType.damage || null => null,
    };
  }

  _PrimaryActionEffectResult _buildNonDamageSkillResult({
    required List<BattleActionLog> actions,
    required _BattleUnit recoveryTarget,
  }) {
    return _PrimaryActionEffectResult(
      actions: actions,
      onDamagedRequests: const <_DerivedActionRequest>[],
      totalDamage: 0,
      recoveryTarget: recoveryTarget,
    );
  }
}
