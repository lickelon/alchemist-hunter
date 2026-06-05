# 전투 Modifier 설계 기준

## 0. 목적
- 이 문서는 전투 중 적용되는 `버프 / 디버프 / 피해 증감 효과`의 기준을 정리한다.
- `docs/battle/combat/combat_stat_design.md`가 기본 전투 스탯의 source of truth라면, 이 문서는 그 위에 얹히는 `추가 효과 계층`의 source of truth다.
- 여기서의 `BattleModifier`는 전투 피해 계산용 modifier다. 경험치, 골드, 드롭 같은 보상 계열은 별도 `RewardModifier` 계층으로 분리한다.

## 1. 역할 분리

### 1.1 기본 원칙
- `BattleCombatStats`는 캐릭터의 기본 몸값만 담당한다.
- `BattleStatModifier`는 최종 전투 스탯에 흡수되는 추가 수치를 담당한다.
- `BattleModifier`는 최종 스탯으로 환원되지 않는 전투 효과를 담당한다.
- `주는 피해 증가`, `받는 피해 증가` 같은 효과는 기본 스탯으로 넣지 않는다.

### 1.2 책임 구분
- 기본 스탯:
  - `HP`
  - `물공 / 물방`
  - `마공 / 마방`
  - `속도`
  - `치확 / 치피`
  - `명중 / 회피`
  - `상태적중 / 상태저항`
  - `물리관통 / 마법관통`
  - `흡혈 / 회복력 / 재생`
- stat modifier:
  - `치확`
  - `치피`
  - `명중 / 회피`
  - `상태적중 / 상태저항`
  - `물리관통 / 마법관통`
  - `흡혈 / 회복력 / 재생`
- battle modifier:
  - `주는 피해 증가`
  - `받는 피해 증가`
  - `받는 피해 감소`
  - `대 용병 피해 증가`
  - `물리 피해 증가`
  - `중독 대상에게 주는 피해 증가`
  - `치명타 피해 저항`

### 1.3 전투 modifier와 보상 modifier
- `Modifier`는 넓게 보면 수치 보정 효과의 상위 개념으로 둘 수 있다.
- 다만 적용 시점과 소비자가 다르면 같은 리스트로 섞지 않는다.
- `BattleModifier`
  - 전투 중 피해 계산 단계에서 사용한다.
  - 예: `damageDealt`, `damageTaken`
- `RewardModifier`
  - 전투 또는 런 종료 후 보상 계산 단계에서 사용한다.
  - 예: `expGained`, `goldGained`, `dropChance`, `dropQuantity`
- 권장 구조:
```dart
class EffectBundle {
  final List<BattleModifier> battleModifiers;
  final List<RewardModifier> rewardModifiers;
  final List<BattlePassiveEffect> passives;
}
```
- 비추천 구조:
```dart
final List<Modifier> modifiers;
```
- 이유:
  - 전투 계산과 보상 계산의 적용 시점이 다르다.
  - 전투 계산기가 보상 modifier를 필터링하거나, 보상 계산기가 전투 modifier를 필터링하는 구조를 만들지 않는다.
  - 잘못 섞인 데이터를 런타임 타입 체크로 걸러내는 구조는 피한다.

## 2. 모델 방향

### 2.1 핵심 타입
- `BattleStatModifier`
- `BattleStatModifierType`
- `BattleModifier`
- `BattleModifierType`
- `BattleModifierMode`
- `DamageSchool`

### 2.2 권장 구조
```dart
enum BattleStatModifierType {
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
}

enum BattleModifierType {
  damageDealt,
  damageTaken,
}

enum BattleModifierMode { flat, percent }

enum DamageSchool { any, physical, magical }

class BattleStatModifier {
  final BattleStatModifierType type;
  final BattleModifierMode mode;
  final double value;
  final String sourceId;
}

class BattleModifier {
  final BattleModifierType type;
  final BattleModifierMode mode;
  final double value;
  final DamageSchool school;
  final CombatFaction? targetFaction;
  final String sourceId;
}
```

### 2.3 필드 의미
- `BattleStatModifier.type`: 어떤 최종 스탯에 흡수되는지
- `BattleModifier.type`: 어떤 전투 효과를 조정하는지
- `mode`: `flat` 또는 `percent`
- `value`: 효과 수치
- `school`: `전체 / 물리 / 마법` 적용 범위
- `targetFaction`: `용병 / 호문` 조건부 대상
- `sourceId`: 장비, 포션, 스킬, 상태이상 등 출처 추적용 식별자

## 3. Modifier 분류

### 3.1 상시 modifier
- 전투 시작 전에 이미 확정된 효과
- 예:
  - 장비 특수 옵션
  - 인챈트 고정 옵션
  - 패시브
  - 편성 보너스

### 3.2 전투 중 임시 modifier
- 전투 중 부여되고 해제되는 효과
- 예:
  - 포션 버프
  - 스킬 버프
  - 취약
  - 방어 감소
  - 중독 대상 추가 피해

### 3.3 상태이상과의 관계
- 상태이상은 독립된 `StatusEffect` 모델을 둘 수 있다.
- 실제 계산 시점에는 `StatusEffect -> BattleModifier`로 변환해서 적용한다.
- 즉 상태이상은 생명주기 관리 책임, modifier는 수치 계산 책임을 가진다.

## 4. 초기 지원 범위

### 4.1 1차 지원 modifier
- `critRate`
- `critDamage`
- `accuracy`
- `evasion`
- `lifesteal`
- `healingPower`
- `regen`
- `damageDealt`
- `damageTaken`

### 4.2 적용 범위
- `damageDealt`
  - 전체
  - 물리
  - 마법
- `damageTaken`
  - 전체
  - 물리
  - 마법

### 4.3 후속 확장 후보
- `critResist`
- `statusDamageTaken`
- `shieldPower`

### 4.4 현재 보류하는 후보
- 아래 효과는 당장 `BattleModifierType`으로 추가하지 않는다.
- `healingDone`
  - 현재는 `BattleStatModifierType.healingPower`와 역할이 겹친다.
- `resourceCost`
  - MP는 현재 스킬 사용 빈도를 제한하는 별도 축이다.
  - `maxMp / mpRegen`과 역할이 가까우므로 필요가 명확해질 때 별도 설계한다.
- `cooldownRecovery`
  - 쿨다운 모델은 존재하지만 현재는 MP가 더 실질적인 재사용 제한 역할을 한다.
- `statusDurationDealt`, `statusDurationTaken`
  - 상태이상 세부 공식이 확정된 뒤 검토한다.

### 4.5 보상 modifier 후보
- 보상 계열은 `BattleModifier`가 아니라 `RewardModifier` 후보로 둔다.
- 후보:
  - `expGained`
  - `goldGained`
  - `dropChance`
  - `dropQuantity`
- 적용 위치:
  - 전투 승패 또는 런 결과 확정 이후
  - 보상 집계 단계
  - 장비, 패시브, 마을/작업실 효과가 보상 modifier를 제공할 수 있다.

## 5. 계산 순서

### 5.1 기본 공격 계산
1. 공격 타입 결정
   - 물리 공격
   - 마법 공격
2. 기본 피해 계산
   - 물리면 `물공 vs 물방`
   - 마법이면 `마공 vs 마방`
3. 관통 반영
   - `물리관통` 또는 `마법관통`
4. 치명타 판정 및 치피 반영
5. 공격자 `damageDealt` modifier 반영
6. 방어자 `damageTaken` modifier 반영
7. 흡혈, 재생, 부가 회복 처리
8. 최종 clamp

### 5.2 기본 공식 방향
```text
finalDamage =
  baseDamage
  * (1 + attacker.damageDealtGeneral + attacker.damageDealtBySchool)
  * (1 + defender.damageTakenGeneral + defender.damageTakenBySchool)
```

### 5.3 방어 계열 처리 원칙
- `받는 피해 감소`는 별도 modifier type으로 둘 수도 있다.
- 다만 초기에는 `damageTaken`에 음수값을 허용하는 방식이 단순하다.
- 예:
  - `damageTaken +0.20` = 받는 피해 20% 증가
  - `damageTaken -0.15` = 받는 피해 15% 감소

## 6. 누적 규칙

### 6.1 같은 타입 누적
- 동일 타입 modifier는 먼저 합산한 뒤 최종 계산에 반영한다.
- 초기 규칙은 `가산 합산`을 기본으로 한다.

### 6.2 mode 처리
- `BattleStatModifier.flat`: 최종 스탯에 직접 더한다
- `BattleModifier.percent`: 최종 전투 계산에서 배율로 반영한다

### 6.3 권장 정책
- `damageDealt`, `damageTaken`은 `BattleModifier.percent`만 허용한다.
- `critRate`, `accuracy`, `evasion`은 `BattleStatModifier.flat`로 다룬다.
- `lifesteal`, `healingPower`, `regen`도 `BattleStatModifier.flat`로 다룬다.
- `mpRegen`은 modifier로 빼지 않는다. MP는 현재 스킬 사용 빈도 제어축이므로 `maxMp / mpRegen`을 전투 스탯에 유지한다.

## 7. 소유권과 적용 시점

### 7.1 전투 시작 전 스냅샷
- 전투 시작 시점에 아래를 합산한 `BattleCombatSnapshot`을 만든다.
  - 기본 전투 스탯
  - 장비 기본 보너스
  - 인챈트 기본 보너스
  - 상시 stat modifier
  - 상시 battle modifier

### 7.2 전투 중 상태
- 전투 중에는 `ActiveBattleState` 또는 동등한 모델이 임시 modifier를 관리한다.
- 턴 종료 시점마다 지속 턴을 감소시킨다.
- `remainingTurns == 0`이면 제거한다.

### 7.3 출처별 연결
- 장비 기본 옵션: `BattleCombatStats`
- 장비 특수 수치: `BattleStatModifier`
- 장비 전투 효과: `BattleModifier`
- 장비 규칙 변경 효과: `BattlePassiveEffect`
- 포션 효과: `BattleStatModifier` 또는 `BattleModifier`
- 스킬 효과: `BattleModifier`
- 상태이상 효과: `StatusEffect -> BattleModifier`
- 적 고유 피해 보정: `BattleModifier`

## 8. 계열 태그와의 연결
- `용병 / 호문`은 여전히 전투 피해 타입이 아니다.
- 다만 modifier의 조건부 대상에는 연결할 수 있다.
- 예:
  - `대 용병 피해 +15%`
  - `대 호문 받는 피해 -10%`

즉 계열 태그는 `modifier 조건`에는 쓰되, 전역 고정 상성 배율로는 쓰지 않는다.

## 9. 이번 단계에 포함하지 않는 것
- 스킬 개별 설계
- 마나
- 보호막 전용 수식
- 반사 피해
- 도트 세부 공식
- 면역, 해제, 저지 규칙
- 상태이상 저항 계산 상세식
- 보상 modifier 구현

## 10. 구현 시 주의점
- `BattleCombatStats`, `BattleStatModifier`, `BattleModifier`를 한 모델에 우겨넣지 않는다.
- 기본 스탯 테이블에는 `주는 피해 증가`, `받는 피해 증가`를 넣지 않는다.
- 경험치, 골드, 드롭 보정은 `BattleModifier`에 넣지 않는다.
- 수치 계산은 반드시 `전투 스냅샷 -> stat modifier 흡수 -> battle modifier 누적 -> 최종 계산` 순서를 유지한다.
- UI 표시용 문자열과 내부 modifier key를 같은 값으로 재사용하지 않는다.
- 로그/리포트에는 modifier 출처가 추적 가능해야 한다.

## 11. Enemy modifier 해석
- `enemies.json`의 `modifiers`는 패시브가 아니다.
- 적에게 전투 시작 전부터 붙어 있는 상시 `BattleModifier`로 해석한다.
- `passives` 또는 `passiveIds`는 전투 규칙 변경, 트리거형 효과, 특정 시점의 modifier/status/shield 부여를 담당한다.
- 따라서:
  - `피해 +10%`는 `BattleModifier`
  - `공격 후 추가 공격`은 `BattlePassiveEffect`
  - `전투 시작 시 보호막 부여`는 `BattlePassiveEffect`
  - `보상 경험치 +10%`는 `RewardModifier`
