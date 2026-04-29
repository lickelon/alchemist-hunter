# 전투 Passive 설계 기준

## 0. 목적
- 이 문서는 전투 중 `판정 규칙 자체를 바꾸는 효과`의 기준을 정리한다.
- `docs/battle/combat/combat_stat_design.md`는 기본 전투 스탯 기준이다.
- `docs/battle/combat/combat_modifier_design.md`는 수치 보정 효과 기준이다.
- 이 문서는 그 둘로 처리할 수 없는 `전투 규칙 효과`의 source of truth다.

## 1. Passive가 필요한 이유
- `필중`은 명중 수치 증가가 아니라 `명중 판정 생략`이다.
- `2회 공격`은 공격력 증가가 아니라 `행동 횟수 증가`다.
- `선공`, `반격`, `군중제어 면역`도 마찬가지로 단순 수치 보정으로 처리하면 책임이 어색해진다.

즉 아래는 `modifier`가 아니라 `passive`로 다뤄야 한다.
- 필중
- 2회 공격
- 첫 턴 선공
- 피격 시 반격
- 특정 상태이상 면역
- 전투 시작 시 보호막 부여

## 2. 역할 분리

### 2.1 기본 원칙
- `BattleCombatStats`: 캐릭터의 기본 몸값
- `BattleModifier`: 수치 가감
- `BattlePassiveEffect`: 전투 판정 규칙 변경

### 2.2 판단 기준
- 숫자를 더하거나 빼는가
  - `modifier`
- 판정 절차를 건너뛰거나 추가하는가
  - `passive`

### 2.3 예시
- `치확 +20%`
  - modifier
- `이번 공격은 반드시 적중`
  - passive
- `호문에게 주는 피해 +15%`
  - modifier
- `공격 후 1회 추가 타격`
  - passive

## 3. 모델 방향

### 3.1 핵심 타입
- `BattlePassiveEffect`
- `BattlePassiveTrigger`
- `BattlePassiveEffectType`
- `BattlePassiveCondition`

### 3.2 권장 구조
```dart
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
  statusImmune,
  grantModifier,
  grantShield,
  cleanseDebuff,
}

class BattlePassiveEffect {
  final BattlePassiveTrigger trigger;
  final BattlePassiveEffectType type;
  final String sourceId;
  final int? value;
  final int? durationTurns;
  final BattlePassiveCondition? condition;
}
```

### 3.3 필드 의미
- `trigger`: 언제 발동하는가
- `type`: 어떤 규칙 변경을 만드는가
- `sourceId`: 장비, 패시브, 포션, 적 특성 등 출처
- `value`: 타수, 확률, 수량 같은 보조값
- `durationTurns`: 지속 턴
- `condition`: 특정 조건에서만 발동할 때의 필터

## 4. 트리거 훅

### 4.1 초기 필수 훅
1. `battleStart`
2. `beforeAction`
3. `beforeHitCheck`
4. `beforeDamage`
5. `afterHit`
6. `afterAction`
7. `turnEnd`
8. `onDamaged`

### 4.2 훅별 대표 예시
- `battleStart`
  - 전투 시작 시 보호막
  - 첫 턴 한정 공격 버프 부여
- `beforeHitCheck`
  - 필중
  - 회피 불가
- `afterAction`
  - 2회 공격
  - 추가 추격타
- `onDamaged`
  - 피격 시 반격
  - 체력 일정 이하에서 보호막

## 5. 초기 지원 passive

### 5.1 1차 지원 목록
- `alwaysHit`
- `extraAttack`
- `firstStrike`
- `counterAttack`
- `statusImmune`
- `grantModifier`

### 5.2 각 효과의 의미
- `alwaysHit`
  - 명중 판정을 건너뛴다
- `extraAttack`
  - 현재 행동 종료 후 추가 타격 또는 추가 행동을 생성한다
- `firstStrike`
  - 첫 턴 행동 우선권에 보정한다
- `counterAttack`
  - 피격 후 조건 충족 시 즉시 반격 행동을 생성한다
- `statusImmune`
  - 특정 상태이상 적용을 무효화한다
- `grantModifier`
  - passive가 특정 시점에 modifier를 부여한다

## 6. Modifier와의 연결

### 6.1 관계
- passive는 직접 수치를 바꾸지 않아도 된다.
- 대신 발동 시 `BattleModifier`를 생성해서 붙일 수 있다.

### 6.2 예시
- `전투 시작 시 2턴 동안 물공 +20%`
  - passive: `battleStart`
  - effect type: `grantModifier`
  - 결과: 물공 증가 modifier 생성
- `적중 시 1턴 동안 받는 피해 +10% 부여`
  - passive: `afterHit`
  - effect type: `grantModifier`
  - 결과: 대상에게 `damageTaken +10%` modifier 부여

즉:
- `modifier`는 수치 계산 책임
- `passive`는 발동 조건과 규칙 변경 책임

## 7. 구현 원칙

### 7.1 필중
- `accuracy`를 무한대로 올리는 방식으로 처리하지 않는다.
- `beforeHitCheck`에서 `cannotMiss` 같은 전투 컨텍스트 플래그를 세운다.

### 7.2 2회 공격
- 피해를 단순 2배로 만들지 않는다.
- `afterAction`에서 추가 공격 action을 큐에 넣는다.
- 추가 공격은 별도 명중/치명/흡혈 판정을 가진다.

### 7.3 선공
- 속도 스탯 자체를 영구 수정하지 않는다.
- 첫 턴 행동 순서 계산 시 우선권 보정으로 처리한다.

### 7.4 반격
- 상시 자동 피해 반사와 동일시하지 않는다.
- `onDamaged`에서 조건 충족 시 반격 action을 생성한다.

## 8. 권장 실행 구조

### 8.1 전투 시작 전
- 캐릭터별 기본 스탯 계산
- 상시 modifier 적용
- passive 목록 로드

### 8.2 전투 루프 중
1. 행동자 선택
2. `beforeAction` passive 처리
3. 명중 판정 전 passive 처리
4. 피해 계산 전 passive 처리
5. 실제 타격
6. `afterHit` passive 처리
7. `afterAction` passive 처리
8. 턴 종료 처리

### 8.3 상태 변화
- passive는 직접 액션을 생성할 수 있어야 한다.
- passive는 modifier를 생성하거나 해제할 수 있어야 한다.
- passive는 특정 판정을 무효화할 수 있어야 한다.

## 9. 조건 시스템

### 9.1 필요 이유
- 모든 passive가 항상 발동하면 안 된다.
- 계열, 체력 구간, 첫 턴, 치명타 성공 여부 같은 조건이 필요하다.

### 9.2 대표 조건
- `targetFaction == mercenary`
- `targetFaction == homunculus`
- `currentHpRatio <= 0.5`
- `turnNumber == 1`
- `attackWasCritical == true`
- `targetHasStatus == poisoned`

## 10. 이번 단계에 포함하지 않는 것
- 복잡한 스킬 스크립트 시스템
- 상태이상 전체 설계
- 보호막 상세 공식
- 소환물
- 사망 시 부활
- 광역 타깃 우선순위 규칙

## 11. 구현 시 주의점
- `필중`, `2회 공격`을 억지로 스탯이나 modifier로 표현하지 않는다.
- `extraAttack`은 수치 배율이 아니라 `행동 추가`로 처리한다.
- passive 발동 로그는 전투 리포트에 남길 수 있어야 한다.
- 출처 추적이 가능해야 한다.
  - 예: 장비, 인챈트, 포션, 적 고유능력, 패시브
- 초기 구현에서는 범위를 좁게 잡는다.
  - `alwaysHit`
  - `extraAttack`
  - `grantModifier`
  - `counterAttack`

## 12. 결론
- 전투 수치 체계는 `BattleCombatStats`
- 수치 보정 체계는 `BattleModifier`
- 판정 규칙 변경 체계는 `BattlePassiveEffect`

이 3층으로 분리해야 전투 시스템이 커져도 책임이 무너지지 않는다.
