# 연속 전투 런 설계

## 0. 목적
- 이 문서는 stage별 전투를 `교전 1회 완결형`이 아니라 `연속 런(run)` 구조로 재정의한다.
- stage는 `탐색 -> 교전 -> 탐색`을 반복한다.
- 아군 상태는 교전 사이에 유지되고, 적은 encounter마다 새로 생성된다.

## 1. 핵심 규칙
- 아군은 encounter 종료 후에도 현재 HP와 생존 상태를 유지한다.
- 적은 encounter 종료 시 모두 폐기되고, 다음 encounter 시작 시 새 조합으로 다시 생성된다.
- 성공한 encounter의 골드 / 에센스 / 재료는 `수령 대기`에 누적된다.
- 성공한 encounter의 경험치는 즉시 캐릭터에 반영된다.
- 실패 encounter는 보상이 없고 경험치도 없다.
- full wipe가 발생하면 stage는 `복구` 상태로 전환된다.
- 복구가 끝나면 현재 편성을 유지한 채 `첫 전투 시작 상태`로 되돌아간다.
- full wipe 전까지 누적된 `수령 대기 보상`은 유지된다.

## 2. encounter와 run의 경계
- `run`
  - 한 stage에서 원정을 시작한 뒤, 탐색 / 교전 / 복구를 포함해 이어지는 전체 흐름
- `encounter`
  - 적 조합 하나를 만나 실제 교전이 일어나는 단위

### 유지되는 상태
- run 동안 유지
  - 아군 HP
  - 아군 생존 / 사망 상태
  - run 누적 승리 수
  - run 누적 encounter 수
  - run 누적 전멸 수
  - 수령 대기 보상
- encounter마다 초기화
  - 적 HP
  - 적 생존 상태
  - 적 대상 임시 효과
  - 현재 적 조합 정보

## 3. phase 정의
- `idle`
  - 원정이 멈춘 상태
- `searching`
  - 다음 적 조합을 찾는 상태
- `battling`
  - 현재 encounter가 진행 중인 상태
- `recovering`
  - full wipe 후 복구 대기 상태
- `paused`
  - searching / battling / recovering 중 일시정지한 상태

## 4. 전멸 / 복구 규칙
- full wipe 기준
  - 현재 편성된 아군 전원이 사망하면 full wipe다.
- full wipe 시
  - 현재 encounter는 실패 기록으로 남긴다.
  - 골드 / 에센스 / 재료 / 경험치는 추가하지 않는다.
  - 현재까지 누적된 `수령 대기 보상`은 유지한다.
  - phase를 `recovering`으로 전환한다.
- 복구 종료 시
  - 현재 편성을 유지한다.
  - 모든 편성 캐릭터를 풀 HP로 되돌린다.
  - 교전 중 임시 상태는 모두 제거한다.
  - 현재 encounter는 비운다.
  - run의 `victoryCount`, `encounterCount`는 0부터 다시 시작한다.
  - `wipeCount`는 누적한다.
  - phase는 `searching`으로 전환한다.

## 5. 탐색 중 회복
- 탐색 중 회복은 `혼합형`으로 고정한다.
- encounter 하나가 끝나고 다음 encounter를 시작하기 전, 살아있는 아군에게만 회복을 적용한다.
- 공식
  - `heal = ceil(maxHp * (0.08 + regen))`
- 제약
  - 최대 HP를 넘지 않는다.
  - 죽은 유닛은 revive되지 않는다.
  - `regen`은 캐릭터 최종 전투 스탯 값을 사용한다.

## 6. 보상 / 경험치
- 누적 수령 대상
  - 골드
  - 에센스
  - 재료
- 즉시 반영 대상
  - 경험치

### 성공 encounter
- 골드 / 에센스 / 재료는 `pendingClaim`에 누적한다.
- 편성 참가자 전원에게 stage XP를 즉시 반영한다.

### 실패 encounter
- 골드 / 에센스 / 재료 / 경험치를 모두 획득하지 못한다.

## 7. 액션 진행 단위
- 전투는 `1초당 1회 공격 lifecycle`을 기준으로 진행한다.
- 한 lifecycle 안에는 아래가 포함된다.
  - 공격 또는 빗나감
  - 필요 시 흡혈 로그
  - 필요 시 재생 로그
- 라이브 UI에서는 `총 행동 수`, `총 턴 수 예고`를 보여주지 않는다.

## 8. 1차 범위
- 포함
  - 연속 run 상태
  - full wipe / recovery
  - encounter 간 HP 유지
  - 탐색 중 회복
  - 경험치 즉시 반영
- 제외
  - 보스 전용 패턴
  - 보스 고유 스크립트
  - 소환 / 부활
