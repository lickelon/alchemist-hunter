# 전투 Combat 설계 개요

## 0. 목적
- 이 문서는 전투 시스템 중 `combat` 하위 설계 문서의 진입점이다.
- 전투 전체 실행 계획은 `docs/battle/battle_completion_plan.md`를 따른다.
- 실제 전투 규칙 설계는 아래 세 문서를 함께 참고한다.

## 1. battle과 combat의 경계
- `battle`은 스테이지, 원정, 드롭, 보상, 해금, 로그, UI, sync를 포함한 전투 상위 영역이다.
- `combat`은 `battle` 내부에서 실제 전투 계산만 담당하는 하위 영역이다.
- 즉 `combat`은 스탯, 턴 루프, 피해 계산, modifier, passive를 다룬다.

## 2. 참고 문서
- `docs/battle/combat/combat_stat_design.md`
  - 기본 전투 스탯, 계열, 직업, 티어/랭크/레벨 성장 규칙
- `docs/battle/combat/combat_modifier_design.md`
  - 수치 보정 효과, 피해 증감, 버프/디버프, modifier 계산 순서
- `docs/battle/combat/combat_passive_design.md`
  - 필중, 2회 공격, 선공, 반격 같은 판정 규칙 변경 효과

## 3. 문서 사용 기준
- 기본 몸값과 성장 규칙을 정할 때는 `combat_stat_design.md`를 본다.
- 수치를 더하거나 빼는 효과를 설계할 때는 `combat_modifier_design.md`를 본다.
- 판정 절차를 건너뛰거나 행동 규칙을 추가하는 효과를 설계할 때는 `combat_passive_design.md`를 본다.

## 4. 책임 분리
- `BattleCombatStats`
  - 기본 전투 수치
- `BattleModifier`
  - 수치 보정
- `BattlePassiveEffect`
  - 전투 판정 규칙 변경

이 3층 분리를 combat 설계의 기본 원칙으로 유지한다.
