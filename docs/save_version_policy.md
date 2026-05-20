# 저장 경계 / 버전 정책

## 1. 목적
데이터 테이블과 카탈로그가 계속 바뀌는 현재 단계에서 실제 저장 구현은 보류한다.

이 문서는 나중에 저장을 도입할 때 무엇을 저장하고, 무엇을 재계산하거나 폐기할지 정하는 기준이다.

## 2. 버전 정의

### saveVersion
`saveVersion`은 저장 파일의 구조 버전이다.

다음 변경은 `saveVersion`을 올린다.

- 저장 JSON 필드 추가, 삭제, 이름 변경
- 저장 타입 변경
- 상태를 여러 객체로 분리하거나 병합
- 복원 코드가 기존 저장 파일을 그대로 읽을 수 없는 변경

### contentVersion
`contentVersion`은 카탈로그와 밸런스 데이터 호환 버전이다.

다음 변경은 `contentVersion`을 올린다.

- material, potion, equipment, stage, enemy, skill node ID 변경
- stage 보상, 드롭, 제작 시간, 상점 가격 같은 핵심 밸런스 변경
- 카탈로그에서 기존 저장 데이터가 참조하는 ID 제거
- 전투 runtime을 그대로 이어가기 어려운 enemy, encounter, skill 구조 변경

## 3. 저장 메타데이터
저장 파일에는 최소한 아래 메타데이터가 필요하다.

- `saveVersion`
- `contentVersion`
- `savedAt`
- `lastSyncAt`

`savedAt`은 저장 파일 자체가 만들어진 시각이다. `lastSyncAt`은 게임 진행 계산의 기준 시각이다.

## 4. 저장 대상

### 항상 저장
플레이어가 획득하거나 선택한 결과는 저장한다.

- 플레이어 재화: 골드, 정수, 명성, 신비, 다이아
- 플레이어 재료 재고
- 캐릭터 목록과 성장 상태
- 캐릭터 장비 장착 상태
- 보유 장비 인스턴스
- 제작된 포션 스택과 포션 상세 정보
- 추출 원소 재고
- Town / Workshop 스킬트리 진행도
- Battle stage 해금, 클리어, 연승 진행도
- stage 편성
- stage별 포션 loadout
- 작업실 보조 슬롯 배치
- 진행 중인 Town forge queue
- 진행 중인 Workshop queue
- 수령 대기 보상

### 조건부 저장
카탈로그와 강하게 연결된 runtime은 `contentVersion`이 호환될 때만 복원한다.

- 진행 중인 battle expedition
- 현재 encounter runtime
- 적 runtime HP, MP, 상태이상, 보호막, pending actor queue
- 최근 전투 action log
- 상점 현재 진열 목록
- 용병 후보 목록

`contentVersion`이 맞지 않으면 위 항목은 재계산 또는 폐기하고, 플레이어가 이미 획득한 보상과 재고만 유지한다.

### 저장하지 않음
언제든 재계산 가능한 값은 저장하지 않는다.

- UI 선택 상태
- bottom sheet 열림 여부
- toast 메시지
- selector에서 만든 표시용 label
- 전투력 preview
- 장비/캐릭터/포션 derived stat
- 카탈로그 원본 데이터
- 디버그성 로그 전체 이력

Workshop 로그와 Battle recent log는 UX 보조 정보다. 저장하더라도 최근 N개만 저장하고, 복원 실패 시 버려도 된다.

## 5. 복원 정책

### saveVersion이 같을 때
저장 구조를 그대로 읽는다.

읽은 뒤 `lastSyncAt`부터 현재 시각까지 sync를 실행한다. 현재 sync cap은 8시간이다.

### saveVersion이 낮을 때
마이그레이션 코드가 있으면 최신 구조로 변환한다.

마이그레이션 코드가 없으면 저장 파일을 적용하지 않고 초기 세션으로 시작한다. 이 경우 사용자에게 저장 호환 불가 상태를 알릴 수 있어야 한다.

### saveVersion이 높을 때
현재 앱이 알 수 없는 미래 저장 구조이므로 복원하지 않는다.

### contentVersion이 같을 때
카탈로그 의존 runtime까지 복원할 수 있다.

### contentVersion이 다를 때
아래 순서로 처리한다.

1. 재화, 재고, 캐릭터 성장, 장비, 스킬트리처럼 플레이어 소유 결과를 우선 보존한다.
2. 사라진 카탈로그 ID를 참조하는 runtime은 폐기한다.
3. 진행 중인 encounter는 중단하고 해당 stage expedition은 `idle` 또는 안전한 대기 상태로 되돌린다.
4. pending claim은 가능한 한 유지하되, 사라진 material ID가 포함되면 claim 전체를 보류하거나 폐기한다.
5. 상점과 용병 후보는 현재 카탈로그 기준으로 새로 생성한다.

## 6. 카탈로그 ID 원칙
저장 구현 이후에는 카탈로그 ID를 쉽게 바꾸지 않는다.

- 표시 이름 변경은 ID 변경 사유가 아니다.
- 밸런스 수치 변경은 ID 변경 사유가 아니다.
- 의미가 완전히 다른 항목으로 바뀌는 경우에만 새 ID를 쓴다.
- 기존 ID를 삭제할 때는 저장 복원 정책을 먼저 작성한다.

## 7. 오프라인 진행 기준
오프라인 진행은 저장 복원 직후 `lastSyncAt`과 현재 시각 차이로 계산한다.

현재 기준은 다음과 같다.

- 최대 처리 시간은 8시간 cap을 유지한다.
- cap을 초과한 시간은 버린다.
- sync 순서는 상점 갱신, battle, workshop queue, forge queue 순서를 유지한다.
- `contentVersion` 불일치로 runtime을 폐기한 stage는 오프라인 전투 보상을 계산하지 않는다.

## 8. 현재 결론
지금은 저장소를 구현하지 않는다.

먼저 이 문서의 경계를 기준으로 저장 DTO와 마이그레이션 범위를 설계한 뒤, 카탈로그 ID와 밸런스 데이터가 더 안정화되면 실제 로컬 저장소를 도입한다.
