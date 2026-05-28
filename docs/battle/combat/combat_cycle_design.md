# Combat Cycle 상세 설계

## 0. 목적
- 이 문서는 combat 내부 흐름을 `encounter cycle`, `action turn`, `action lifecycle`로 분리한다.
- encounter cycle은 적 조합 하나와 벌이는 전투 전체 단위다.
- action turn은 encounter 행동 큐에서 행동자 1명이 기본 행동 기회를 얻는 단위다.
- action lifecycle은 실제 전투 판정과 로그가 한 번 진행되는 순서 단위다.
- 어떤 기능이 어느 단계에 들어가야 하는지 판단하는 기준 문서다.

## 1. 범위
- 포함:
  - encounter 시작 / 종료
  - 행동 큐 준비와 행동자 선택
  - 기본 공격 / 액티브 스킬 lifecycle
  - 명중 / 치명 / 피해 계산
  - 흡혈 / 재생 / MP 회복
  - passive trigger 발동 지점
  - 추가 공격 / 반격 같은 파생 action lifecycle
- 제외:
  - stage 해금
  - 보상 지급
  - 드롭 계산
  - 적 조합 선택 확률
  - 탐색 / 복구 phase
  - 저장 / 오프라인 진행

## 2. 용어
- `encounter`: 적 조합 하나와 벌이는 전투 단위
- `encounter cycle`: encounter 시작부터 성공 / 전멸 판정까지의 전체 흐름
- `action turn`: encounter 행동 큐에서 선택된 행동자 1명이 기본 행동 기회를 얻는 단위
- `action lifecycle`: 기본 행동, 추가 공격, 반격처럼 실제 판정과 로그가 진행되는 순서 단위
- `base action`: 기본 공격 또는 액티브 스킬 중 하나
- `derived action`: 추가 공격, 반격처럼 base action에서 파생되어 별도 action lifecycle을 수행하는 행동
- `derived action request`: 훅에서 생성하지만 encounter 행동 큐에는 넣지 않는 파생 행동 요청
- `hook`: passive가 끼어드는 고정 지점

### 2.1 카운트 기준
- `turn`은 action turn 번호다.
- `lifecycle`은 action lifecycle 번호다.
- `turnInEncounter`는 encounter 안에서 진행된 action turn 수를 뜻한다.
- 기본 행동에서 추가 공격이나 반격이 여러 번 이어져도 action turn은 1만 증가한다.
- 추가 공격과 반격은 각각 별도 action lifecycle을 소비한다.
- 전투 로그는 같은 행동 기회에서 파생된 행동을 같은 `turn`으로 묶고, `lifecycle`로 실제 처리 순서를 구분한다.

예:
- A 기본 공격 1회, 추가 공격 9회
  - action turn: 1
  - action lifecycle: 1~10
  - 로그 turn: 모두 1
- A 공격, B 반격, A 재반격
  - action turn: 1
  - action lifecycle: 1~3
  - 로그 turn: 모두 1

## 3. Encounter Cycle

### 3.1 Encounter Cycle 단계
1. Encounter 시작
2. 행동 큐 준비
3. 행동자 선택
4. Action Turn 실행
5. Encounter 종료 판정
6. Encounter 결과 반환

### 3.2 Encounter 시작
- 새 적 조합을 런타임 유닛으로 만든다.
- 적 HP, MP, 쿨다운, 임시 상태를 초기화한다.
- 아군은 run에서 유지 중인 HP, MP, 쿨다운을 이어받는다.
- 적용 위치:
  - `battleStart` passive
  - 전투 시작 보호막
  - 전투 시작 modifier 부여
  - 첫 행동 우선권 준비
- 넣으면 안 되는 것:
  - 드롭 계산
  - 보상 계산
  - stage 해금 판정

현재 구현:
- 적 런타임 생성과 아군 상태 유지가 구현되어 있다.
- `battleStart` passive는 모델만 있고 아직 실행되지 않는다.

### 3.3 행동 큐 준비
- 살아있는 유닛만 행동 후보가 된다.
- 기본 행동 큐는 속도 내림차순으로 만든다.
- 속도가 같으면 같은 진영 내부 ID 정렬, 진영이 다르면 아군 우선이다.
- 적용 위치:
  - 첫 턴 선공
  - 행동 지연
  - 행동 게이지형 시스템
- 넣으면 안 되는 것:
  - 피해량 계산
  - 명중 판정

현재 구현:
- 속도 기반 정렬이 구현되어 있다.
- `firstStrike`는 encounter 첫 queue 생성 시에만 우선권으로 반영한다.

### 3.4 행동자 선택
- 행동 큐 맨 앞의 유닛을 꺼낸다.
- 죽은 유닛이면 건너뛴다.
- 적용 위치:
  - 기본 행동 순서
  - 행동 지연
  - 행동 게이지형 시스템
- 넣으면 안 되는 것:
  - 액티브 스킬 효과 계산
  - 명중 / 피해 계산
  - 추가 공격 / 반격 삽입

현재 구현:
- encounter 행동 큐에는 기본 행동자 ID만 남긴다.

### 3.5 Action Turn 실행
- 선택된 행동자가 action turn 1회를 시작한다.
- action turn 안의 기본 행동과 파생 행동은 이 문서 4장의 action lifecycle 규칙을 따른다.
- encounter cycle은 lifecycle 내부의 명중, 피해, 회복 세부 규칙에 개입하지 않는다.
- 추가 공격, 반격, 추격타는 encounter 행동 큐에 넣지 않고 같은 action turn 안에서 파생 action lifecycle로 즉시 처리한다.

### 3.6 Encounter 종료 판정
- 적 전멸이면 encounter 성공이다.
- 아군 전멸이면 full wipe다.
- 전투 종료 조건이 충족되면 파생 action lifecycle을 더 이상 시작하지 않는다.
- 적용 위치:
  - `onDefeat`
  - 사망 시 부활
  - 사망 시 폭발
  - encounter 성공 / 실패 결과 반환
- 넣으면 안 되는 것:
  - pending claim 지급
  - stage progression

현재 구현:
- 성공 / 전멸 판정이 구현되어 있다.
- `onDefeat` trigger는 모델만 있고 아직 실행되지 않는다.

### 3.7 Encounter 결과 반환
- combat은 encounter 성공 여부, 아군 상태, 적 상태, 행동 로그만 반환한다.
- battle은 이 결과를 받아 보상, XP, progression, recovery를 처리한다.
- combat은 보상과 드롭을 직접 계산하지 않는다.

## 4. Action Lifecycle

### 4.1 Action Lifecycle 함수 단계
1. `prepareActionContext`
2. `applyBeforeActionHooks`
3. `selectBaseAction`
4. `selectActionTargets`
5. `applyBeforeHitCheckHooks`
6. `resolveHitCheck`
7. `applyBeforeDamageHooks`
8. `resolveActionEffect`
9. `applyActionEffect`
10. `applyAfterHitHooks`
11. `applyOnDamagedHooks`
12. `applyPostActionRecovery`
13. `applyAfterActionHooks`
14. `resolveDerivedActionLifecycles`
15. `applyTurnEndHooks`
16. `buildActionLifecycleResult`

### 4.2 `prepareActionContext`
- 행동자, 진영, 대상 후보, 현재 HP / MP, 스킬 후보, passive 후보를 묶은 컨텍스트를 만든다.
- 이 단계는 계산 입력을 준비할 뿐 상태를 변경하지 않는다.
- 적용 위치:
  - base action 여부
  - derived action 여부
  - 추가 공격 재귀 방지 플래그
  - 행동 로그 컨텍스트 생성
- 넣으면 안 되는 것:
  - 명중 판정
  - 피해 계산
  - HP / MP 변경

현재 구현:
- 별도 컨텍스트 함수로 분리되어 있지 않다.

### 4.3 `applyBeforeActionHooks`
- 행동자가 행동을 시작하기 직전의 훅이다.
- 행동 자체를 막거나, 이번 행동의 액션 선택에 영향을 줄 수 있다.
- 적용 위치:
  - 침묵 / 기절 / 도발
  - 이번 행동 스킬 금지
  - HP 조건부 스킬 우선도 보정
  - 행동 전 버프 갱신
- 넣으면 안 되는 것:
  - 명중 판정 우회
  - 피해량 배율 계산

현재 구현:
- `beforeAction` trigger는 모델만 있고 아직 실행되지 않는다.

### 4.4 `selectBaseAction`
- 기본 공격을 할지 액티브 스킬을 쓸지 결정한다.
- 일반 규칙:
  - 현재 MP가 최대 MP 미만이면 기본 공격
  - 현재 MP가 최대 MP 이상이면 사용 가능한 액티브 스킬을 반드시 사용
  - 액티브 스킬 사용 시 현재 MP를 전부 소비
- 스킬 선택 규칙:
  - 지원 가능한 스킬만 후보로 둔다.
  - 현재는 `damage + randomEnemy`만 실제 발동 대상이다.
  - 후보가 여러 개면 priority가 높은 스킬을 고른다.
- 적용 위치:
  - MP 기반 액티브 스킬
  - 보스 전용 패턴 스킬
  - 쿨다운 기반 스킬
- 넣으면 안 되는 것:
  - passive 추가 공격
  - 반격

현재 구현:
- MP 최대치 도달 시 액티브 스킬을 강제 사용한다.
- 스킬 사용 시 MP를 전부 소비한다.
- `damage + randomEnemy`만 지원한다.

### 4.5 `selectActionTargets`
- 기본 타깃 선택은 랜덤이다.
- 특수 passive나 스킬이 없으면 양쪽 모두 랜덤을 유지한다.
- 스킬의 `targetType`이 기본 랜덤 규칙을 대체할 수 있다.
- 적용 위치:
  - 낮은 HP 우선
  - 높은 공격력 우선
  - 전체 공격
  - 자기 자신 회복
- 넣으면 안 되는 것:
  - stage별 적 조합 확률
  - 드롭 확률

현재 구현:
- 살아있는 상대 중 랜덤 타깃을 선택한다.
- `randomEnemy` 외 target type은 모델만 있다.

### 4.6 `applyBeforeHitCheckHooks`
- 명중 판정 직전 훅이다.
- 명중 판정을 건너뛰거나 명중 / 회피 컨텍스트만 바꾼다.
- 적용 위치:
  - 필중
  - 회피 불가
  - 이번 공격 명중 보정
  - 실명 상태의 명중 저하
- 넣으면 안 되는 것:
  - 피해량 증가
  - 추가 공격 생성

현재 구현:
- `alwaysHit`은 `beforeHitCheck` trigger일 때만 명중 판정을 건너뛴다.

### 4.7 `resolveHitCheck`
- 공격자의 명중과 방어자의 회피로 hit 여부를 결정한다.
- 필중이 적용되면 이 판정을 건너뛴다.
- 빗나가면 피해, 흡혈, afterHit, onDamaged는 발생하지 않는다.
- 그래도 행동 후 재생 / MP 회복 / afterAction은 발생할 수 있다.
- 적용 위치:
  - 명중 / 회피 공식
  - 필중 결과 처리

현재 구현:
- 명중 확률은 `accuracy + potionBonus - evasion` 기반이다.
- 최소 / 최대 clamp가 있다.

### 4.8 `applyBeforeDamageHooks`
- 명중이 확정된 뒤 피해 계산 직전 훅이다.
- 피해량 계산 컨텍스트를 바꿀 수 있다.
- 적용 위치:
  - 치명타 강제
  - 방어 무시
  - 이번 공격 피해 증가
  - 특정 계열 대상 피해 증가
  - 스킬 배율 보정
- 넣으면 안 되는 것:
  - 명중 판정 변경
  - HP 차감

현재 구현:
- `grantModifier` passive는 `beforeDamage`에서 행동자에게 임시 modifier를 부여할 수 있다.
- 피해 배율 자체는 상시 / 임시 `BattleModifier`와 스킬 배율로 계산된다.

### 4.9 `resolveActionEffect`
- 물리 / 마법 공격 중 사용할 school을 정한다.
- 공격력, 방어력, 관통, 치명타, potionBoost, modifier, 스킬 배율을 반영한다.
- 이 단계는 피해량 / 회복량 / 부여 효과를 계산할 뿐 실제 상태를 변경하지 않는다.
- 적용 위치:
  - 물리 / 마법 피해 공식
  - 치명타
  - 관통
  - 주는 피해 / 받는 피해 modifier
  - 액티브 스킬 피해 배율
- 넣으면 안 되는 것:
  - 실제 HP 차감
  - 흡혈 적용

현재 구현:
- 기본 피해 공식과 스킬 배율이 구현되어 있다.
- 회복형 스킬, 광역 피해 스킬, 아군 대상 스킬, modifier / status / shield 부여 스킬이 실행된다.

### 4.10 `applyActionEffect`
- 계산된 피해, 회복, 보호막 변화, 상태 부여를 대상에게 적용한다.
- HP는 0 아래로 내려가지 않는다.
- 적용 위치:
  - 보호막 차감
  - 회복 적용
  - 상태이상 부여
  - 피해 전환
  - 사망 판정 준비
- 넣으면 안 되는 것:
  - 드롭 계산
  - 경험치 계산

현재 구현:
- 대상 HP 차감이 구현되어 있다.
- 보호막은 아직 없다.

### 4.11 `applyAfterHitHooks`
- 명중했고 피해 또는 효과가 적용된 직후 훅이다.
- 적용 위치:
  - 적중 시 디버프
  - 적중 시 modifier 부여
  - 적중 시 추가 MP 회복
  - 적중 시 상태이상 부여
- 넣으면 안 되는 것:
  - 빗나간 공격의 후속 효과
  - 피격자 반격

현재 구현:
- `grantModifier` passive는 `afterHit`에서 대상에게 임시 modifier를 부여할 수 있다.
- `grantStatus` passive는 `afterHit`에서 대상에게 상태이상을 부여할 수 있다.
- `grantShield` passive는 `afterHit`에서 행동자에게 보호막을 부여할 수 있다.

### 4.12 `applyOnDamagedHooks`
- 대상이 피해를 받은 직후 피격자 기준으로 실행되는 훅이다.
- 이 단계는 반격을 직접 실행하지 않고 `derived action request`만 생성한다.
- 적용 위치:
  - 반격
  - 피격 시 보호막
  - 피격 시 회복
  - HP 임계값 발동
- 넣으면 안 되는 것:
  - 공격자 흡혈
  - 공격자의 추가 공격
  - encounter 행동 큐 변경

현재 구현:
- `onDamaged` trigger는 모델만 있고 아직 실행되지 않는다.

### 4.13 `applyPostActionRecovery`
- base action의 피해 처리 후 공격자에게 발생하는 회복 단계다.
- 순서:
  - 흡혈
  - 재생
  - MP 회복
- 일반 규칙:
  - 흡혈은 가한 피해가 있을 때만 발생한다.
  - 재생은 행동 종료 시 살아있는 행동자에게 적용한다.
  - MP 회복은 기본 공격 후에만 적용한다.
  - 스킬 사용 행동에는 MP 회복을 적용하지 않는다.
- 적용 위치:
  - 흡혈
  - 재생
  - MP재생
  - 행동 후 자가 회복
- 넣으면 안 되는 것:
  - 대상 반격
  - 파생 action lifecycle 생성

현재 구현:
- 흡혈, 재생, MP 회복이 구현되어 있다.

### 4.14 `applyAfterActionHooks`
- 행동 전체가 끝난 뒤 실행되는 훅이다.
- 이 단계는 추가 공격을 직접 실행하지 않고 `derived action request`만 생성한다.
- 적용 위치:
  - 추가 공격
  - 추격타
  - 행동 후 쿨다운 감소
  - 행동 후 modifier 만료
- 넣으면 안 되는 것:
  - 명중 판정 우회
  - 피해량 계산
  - encounter 행동 큐 변경

현재 구현:
- `extraAttack`은 `derived action request`를 생성하고 `resolveDerivedActionLifecycles`에서 즉시 실행한다.

### 4.15 `resolveDerivedActionLifecycles`
- `applyAfterActionHooks`나 `applyOnDamagedHooks`에서 생성된 `derived action request`를 같은 action turn 안의 별도 action lifecycle로 즉시 실행한다.
- encounter 행동 큐에는 어떤 항목도 추가하지 않는다.
- 파생 action lifecycle도 동일한 함수 단계를 따른다.
- 실행 순서:
  - 반격처럼 피격자 기준으로 발생한 파생 행동
  - 추가 공격 / 추격타처럼 공격자 기준으로 발생한 파생 행동
  - 동일 우선순위면 발생 로그 순서
- 일반 규칙:
  - encounter 종료 조건이 이미 충족되면 실행하지 않는다.
  - 죽은 유닛은 파생 행동을 수행하지 않는다.
  - 추가 공격은 다시 추가 공격을 생성하지 않는다.
  - 반격은 반격을 다시 유발할 수 있다.
  - 반격 연쇄는 action turn 안의 lifecycle 제한으로 막는다.
- 적용 위치:
  - 추가 공격
  - 반격
  - 추격타
  - 조건부 즉시 재행동
- 넣으면 안 되는 것:
  - 기본 행동 큐 재정렬
  - 다음 행동자 선택
  - 드롭 / 보상 계산

현재 구현:
- `extraAttack` 파생 lifecycle 실행이 구현되어 있다.
- `counterAttack` 파생 lifecycle 실행이 구현되어 있다.

### 4.16 `applyTurnEndHooks`
- lifecycle의 마지막 정리 단계다.
- 적용 위치:
  - 지속 턴 감소
  - 상태이상 피해
  - 버프 / 디버프 만료
  - 행동 단위 쿨다운 감소
- 넣으면 안 되는 것:
  - 새 타깃 선택
  - 드롭 / 보상 계산

현재 구현:
- `grantModifier` passive는 `turnEnd`에서 행동자에게 임시 modifier를 부여할 수 있다.
- 행동자에게 걸린 임시 modifier의 남은 lifecycle을 감소시킨다.
- 독 상태이상은 `turnEnd`에서 피해를 주고, 상태이상의 남은 lifecycle을 감소시킨다.

### 4.17 `buildActionLifecycleResult`
- 행동 로그, 변경된 유닛 상태, 파생 action lifecycle 로그, 종료 후보 상태를 묶어 반환한다.
- encounter cycle은 이 결과를 받아 다음 기본 행동자 선택 또는 encounter 종료 판정을 진행한다.
- 적용 위치:
  - UI 전투 로그
  - 현재 HP / MP 스냅샷
  - 파생 행동 로그 병합
  - encounter 종료 판정 입력
- 넣으면 안 되는 것:
  - 다음 행동자 선택
  - 보상 계산
  - 드롭 계산

현재 구현:
- 결과 객체가 action lifecycle 단위로 충분히 분리되어 있지 않다.

## 5. Encounter Cycle과 Action Turn / Lifecycle의 경계
- encounter cycle은 행동 순서, 행동 큐, 전투 종료를 관리한다.
- action turn은 encounter 행동 큐에서 선택된 행동자 1명의 기본 행동 기회를 관리한다.
- action lifecycle은 기본 행동과 파생 행동 각각의 판정과 결과를 관리한다.
- 추가 공격과 반격은 encounter 행동 큐를 변경하지 않고 같은 action turn 안의 별도 action lifecycle로 즉시 실행한다.
- encounter 행동 큐는 기본 행동 순서만 관리한다.
- 보상, 드롭, XP, progression은 encounter cycle 밖의 battle 책임이다.

## 6. 기능별 배치 기준

| 기능 | 들어갈 흐름 | 단계 | 이유 |
| --- | --- | --- | --- |
| 필중 | Action Lifecycle | `applyBeforeHitCheckHooks` | 명중 판정을 건너뛰는 규칙 변경 |
| 명중 증가 | Action Lifecycle 또는 스탯 계산 | `applyBeforeHitCheckHooks` | 판정 수치 보정 |
| 치명타 확률 증가 | Action Lifecycle 또는 스탯 계산 | `applyBeforeDamageHooks` | 기본 수치면 스탯, 조건부면 훅 |
| 치명타 강제 | Action Lifecycle | `applyBeforeDamageHooks` | 명중 후 피해 계산 전 확정 |
| 주는 피해 증가 | Action Lifecycle | `resolveActionEffect` | 최종 피해 배율 |
| 받는 피해 증가 | Action Lifecycle | `resolveActionEffect` | 방어자 기준 최종 피해 배율 |
| 방어 무시 | Action Lifecycle | `applyBeforeDamageHooks` 또는 `resolveActionEffect` | 피해 공식 입력 변경 |
| 액티브 스킬 | Action Lifecycle | `selectBaseAction` | 기본 공격을 대체하는 base action |
| 스킬 쿨다운 | Action Lifecycle | `selectBaseAction` / `applyTurnEndHooks` | 사용 가능 여부와 만료 처리 |
| 흡혈 | Action Lifecycle | `applyPostActionRecovery` | 가한 피해 확정 후 회복 |
| 재생 | Action Lifecycle | `applyPostActionRecovery` 또는 `applyTurnEndHooks` | 행동 단위 회복이면 행동 후, 턴 단위면 Turn End |
| MP 회복 | Action Lifecycle | `applyPostActionRecovery` | 기본 공격 후 자원 회복 |
| 상태이상 부여 | Action Lifecycle | `applyAfterHitHooks` 또는 `applyActionEffect` | 적중한 공격의 후속 효과 |
| 상태이상 피해 | Action Lifecycle | `applyTurnEndHooks` | 지속 피해 정리 |
| 추가 공격 | Action Lifecycle | `applyAfterActionHooks` / `resolveDerivedActionLifecycles` | 큐 삽입 없이 별도 lifecycle 실행 |
| 반격 | Action Lifecycle | `applyOnDamagedHooks` / `resolveDerivedActionLifecycles` | 큐 삽입 없이 피격자 기준 lifecycle 실행 |
| 보호막 | Encounter Cycle 또는 Action Lifecycle | Encounter 시작 / `applyOnDamagedHooks` | 시작 보호막 또는 피격 반응 |
| 사망 시 폭발 | Encounter Cycle | On Defeat / 종료 판정 | 사망 이벤트 |
| 부활 | Encounter Cycle | On Defeat / 종료 판정 | 사망 결과 변경 |

## 7. 구현 우선순위
1. 보스 전용 스킬 / 패턴 구현

## 8. 무한 루프 방지 기준
- 전체 encounter guard는 action turn 기준으로 둔다.
- 권장 기본값은 `maxActionTurns = 256`이다.
- action turn guard에 도달하면 encounter는 실패로 종료한다.
- 같은 action turn 안의 반격 연쇄는 lifecycle 기준으로 별도 제한을 둔다.
- 권장 기본값은 `maxLifecyclesPerActionTurn = 64`이다.
- lifecycle 제한에 도달하면 해당 action turn의 파생 행동 연쇄만 중단하고, encounter 자체는 다음 action turn으로 진행한다.

## 9. 주의점
- 모든 행동은 하나의 action lifecycle 안에서 완료되어야 한다.
- 추가 공격과 반격은 encounter 행동 큐를 변경하지 않는다.
- 추가 공격과 반격은 별도 action lifecycle을 즉시 실행한다.
- 흡혈, 재생, MP 회복은 별도 로그로 남긴다.
- 총 턴 수를 미리 계산해서 UI에 보여주지 않는다.
- 타깃은 특수 규칙이 없으면 랜덤이다.
- combat은 보상과 드롭을 계산하지 않는다.
