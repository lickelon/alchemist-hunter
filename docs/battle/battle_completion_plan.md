# 전투 완성도 계획

## 0. 목적
- 이 문서는 `P1 전투 완성도`의 상세 실행 계획만 다룬다.
- `docs/development_plan_v3.md`에는 우선순위만 유지하고, battle 세부 설계는 이 문서를 기준으로 관리한다.
- 전투 스탯, modifier, passive 같은 세부 전투 설계는 `docs/battle/combat/combat_design.md`를 기준으로 참조한다.

## 1. 현재 상태 요약

| 항목 | 현재 상태 | 문제 |
| --- | --- | --- |
| 아군 전투 스탯 | `BattleCombatStats` + `BattleStatModifier` + `BattleModifier` + `BattlePassiveEffect` 구조 반영 | 성장 / 장비 / 인챈트 반영은 됐지만 loadout 보정은 아직 없다 |
| 적 전투 스탯 | `BattleEnemyDefinition`과 stage / enemy set catalog 사용 | Stage 1~5 데이터 밀도와 해금 조건은 더 구체화가 필요하다 |
| 전투 루프 | 속도, 명중, 치명, 물리/마법, 흡혈, 재생, 추가 공격 반영 | 상태이상 / 스킬 / loadout 개입은 아직 없다 |
| 전투 결과 표시 | 최근 결과 시트와 실시간 전투 현황 시트 제공, 포션 fallback 사유 노출 | 해금 근거와 전투 외 성장 요약은 아직 없다 |
| 결과 이력 | stage별 최근 로그 10개 보존, loadout fallback 사유 기록 | 해금 / 드롭 상세 근거는 아직 더 보강할 여지가 있다 |
| 드롭 근거 | stage별 적 구성과 적별 드롭 표시 가능 | Stage 1~5 재료 분배 정책은 더 명확히 정리해야 한다 |
| 스테이지 데이터 | stage / enemy set / enemy catalog 분리 완료, `clearedStageIds` 기반 해금 판정 반영 | clear 기반 unlock 자체는 임시 기준이라 추후 재설계 여지가 있다 |
| 적 정보 | 상세 스탯 / 특수 효과 / 드롭 표시 가능 | 행동 패턴과 후반 적 다양성은 아직 얕다 |
| 적별 드롭 | 적별 표시 가능 | 재료의 stage 중복 제거와 상점 의존 제거가 남아 있다 |
| 포션 loadout | stage별 저장 / 편성 UI / 실제 소비 / fallback 반영 완료 | 부분 적용 규칙과 loadout별 세분 효과는 아직 없다 |
| sync 경계 | battle sync에서 workshop 포션 재고를 같이 반영 | 저장/복원 도입 전까지는 cross-feature 마이그레이션 여지가 남아 있다 |

## 2. 목표
- 아군과 적 모두가 공통 전투 스탯 체계를 사용하게 만든다.
- 전투를 “전투력 숫자 비교”가 아니라 확장 가능한 전투 루프로 바꾼다.
- 전투 결과를 “왜 이렇게 나왔는지” 설명 가능한 수준으로 끌어올린다.
- 스테이지별 난이도/보상/해금 규칙을 데이터화해서 튜닝 가능하게 만든다.
- 스테이지별 적 구성과 적별 드롭 근거를 데이터화해서 설명 가능하게 만든다.
- 포션 loadout을 실제 상태와 연결한다.
- 즉시 전투와 원정 전투가 같은 규칙과 같은 결과 구조를 사용하게 만든다.

## 3. 상세 작업

### 3.1 A단계: 아군 전투 스탯 모델 정규화 [완료]

#### 목표
- 캐릭터를 전투용 단일 수치가 아니라 실제 전투 스탯 묶음으로 해석할 수 있게 한다.

#### 작업
- `BattleCombatStats` 또는 동등한 값 객체 추가
- 권장 필드:
  - `maxHp`
  - `attack`
  - `defense`
  - `speed`
  - `critChance`
  - `critDamage`
  - `accuracy`
  - `evasion`
  - `resistance`
- `HeroProfile`은 단순 `power` 대신 전투 스냅샷 또는 stats를 포함하도록 확장
- `BattlePartyPowerService`는 아래 2역할로 분리
  - UI용 `전투력` 요약 계산
  - 실제 전투용 아군 스냅샷 생성
- 캐릭터 타입, 레벨, 랭크, 티어, 장비, 인챈트, 향후 패시브를 stats 계산에 반영할 수 있게 계층화
- 현재 `powerForCharacter()`의 단순 합산식을 `stats -> combat power summary` 파생 구조로 변경

#### 완료 기준
- 전투 엔진은 아군을 `power` 1개가 아닌 실제 전투 stats로 입력받는다.
- UI의 `전투력`은 남겨도 되지만 실제 전투 입력의 요약치가 된다.

### 3.2 B단계: 적 유닛 / enemy set / 스테이지 데이터 정규화 [진행 중]

#### 목표
- 적과 스테이지를 데이터로 정의해서 전투 난이도와 드롭의 근거를 만든다.

#### 작업
- `BattleEnemyDefinition` 모델 추가
- 권장 필드:
  - `id`
  - `name`
  - `role`
  - `stats`
  - `traits`
  - `dropTable`
  - `actionProfile`
- `BattleEnemySetDefinition` 모델 추가
- 권장 필드:
  - `id`
  - `name`
  - `enemyIds`
  - `summary`
- `BattleStageDefinition` 모델 추가
- 권장 필드:
  - `id`
  - `name`
  - `recommendedPower`
  - `cycleDuration`
  - `enemySetId`
  - `goldSuccess`
  - `goldFailurePenalty`
  - `essenceSuccess`
  - `essenceFailure`
  - `xpSuccessBase`
  - `xpFailureBase`
  - `unlockCondition`
- `BattleDropDefinition` 또는 동등한 적별 드롭 구조 추가
- 권장 필드:
  - `materialId`
  - `min`
  - `max`
  - `chance`
  - `condition`
- `lib/features/battle/data/catalogs/battle_tables.dart`
  - stage 정의, enemy set 정의, enemy 정의를 분리
  - 적별 드롭 테이블 정의
  - stage별 보상 스케일 정의

#### 완료 기준
- Stage 1~5가 서로 다른 적 구성, 드롭, 보상, 권장 전투력 데이터를 가진다.
- 각 stage는 enemy set을 통해 어떤 적을 만나는지 설명할 수 있다.
- 각 재료 드롭은 stage 단위가 아니라 enemy 단위 근거를 가진다.
- stage 튜닝이 battle catalog 수정만으로 가능하다.

### 3.3 C단계: 전투 루프 고도화 [완료]

#### 목표
- 전투를 단순 점수 비교가 아니라 행동 로그가 남는 시뮬레이션 루프로 바꾼다.

#### 작업
- `BattleService.runAutoBattle()`의 현재 구조를 교체
  - 현재: `score >= stagePower` + 확률 보정
  - 목표: unit 기반 cycle simulation
- `BattleUnitSnapshot`, `BattleActionLog`, `BattleTurnResult`, `BattleSimulationResult` 계열 모델 추가
- 최소 전투 루프 규칙
  - 속도 기반 행동 순서
  - 단일 기본 공격
  - 공격력/방어력 기반 피해 계산
  - 치명타 / 명중 / 회피
  - 생존 여부에 따른 종료 판정
- 확장 여지
  - role 기반 타겟 선택
  - 적 action profile
  - 상태 효과 / 버프 / 디버프
  - 포션 / 패시브 개입 지점
- `BattleResult`를 simulation summary 기반 구조로 확장

#### 완료 기준
- 전투 결과가 어떤 행동 순서와 계산으로 나왔는지 추적 가능하다.
- 적 stats와 아군 stats가 실제로 승패와 턴 수에 영향을 준다.

### 3.4 D단계: 결과 이력 모델과 상세 UI [완료]

#### 목표
- 최근 전투 결과 10건을 stage별로 확인할 수 있게 한다.

#### 작업
- `lib/features/battle/domain/models/battle_models.dart`
  - `BattleLogEntry` 추가
  - 권장 필드:
    - `resolvedAt`
    - `success`
    - `gold`
    - `essence`
    - `materials`
    - `turns`
    - `summary`
    - `actionLogs` 또는 축약 전투 근거
  - `BattleExpeditionState.recentLogs` 추가
- `lib/features/battle/domain/services/battle_expedition_resolver.dart`
  - `BattleCycleResolution`에 `logEntry` 추가
  - `lastSummary`는 `logEntry`에서 파생되는 최소 요약으로 축소
- `lib/features/battle/domain/services/battle_expedition_progress_service.dart`
  - 사이클마다 `recentLogs` 앞삽입
  - 최근 10개 cap 적용
- `lib/features/battle/presentation/viewmodels/battle_selectors.dart`
  - `battleStageRecentLogsProvider`
  - `battleStageLastResultLabelProvider`
- `lib/features/battle/presentation/widgets/battle_result_sheet.dart`
  - 최근 전투 기록 바텀시트 추가
- `lib/features/battle/presentation/screens/dungeon_screen.dart`
  - 최근 결과 영역에서 `BattleResultSheet` 진입

#### 완료 기준
- 각 stage에서 최근 10회 전투 이력을 볼 수 있다.
- 성공/실패, Gold, Essence, 재료, 턴 수와 최소 전투 근거를 확인할 수 있다.

### 3.5 E단계: 해금 조건 체계화 [완료]

#### 목표
- 해금 문자열 하드코딩을 제거하고, Stage 3~5 확장이 가능한 구조를 만든다.

#### 현재 메모
- 현재 구현은 `이전 stage 클리어` 기반 unlock catalog까지 반영된 상태다.
- 이 규칙은 재료 의존 하드코딩을 제거하기 위한 임시 기준이다.
- 추후에는 `clearedStageIds` 전용 상태, 세션 진행도, stage별 별도 해금 조건을 다시 설계할 여지가 있다.
- 즉 지금 기준은 "하드코딩 제거와 stage progression 정리"를 우선 달성한 상태로 본다.

#### 작업
- `StageUnlockCondition` 모델 추가
- 권장 필드:
  - `stageId`
  - `requiredMaterialId`
  - `requiredMaterialCount`
  - `requiredStageId`
  - `label`
- stage unlock catalog 정의
- `ProgressState`에 `clearedStageIds` 또는 동등한 진행 추적 상태 추가
- `BattleExpeditionUseCase.claimStageRewards()`의 직접 하드코딩 해금 처리 제거
- battle 전용 unlock service 또는 use case로 이동
- `DungeonScreen._lockedReason()` 제거 또는 selector 기반으로 대체
- stage 정의와 unlock 조건이 같은 catalog 축을 사용하도록 정리

#### 완료 기준
- Stage 2~5 잠금 조건이 데이터로 표현된다.
- UI 문구와 실제 해금 판정이 같은 규칙을 사용한다.
- `ProgressState.clearedStageIds`가 stage progression의 기준이 된다.

### 3.6 F단계: 포션 loadout 상태와 UI [완료]

#### 목표
- stage별 포션 loadout을 편성처럼 저장하고 수정할 수 있게 한다.

#### 작업
- `BattleState` 또는 stage config에 `stagePotionLoadouts` 추가
- 구조 예시:
  - `Map<String, Map<String, int>>`
- `BattleAssignmentSheet`에 포션 선택 섹션 추가
- 표시 내용:
  - 포션 이름
  - 보유 수량
  - 감소/증가 버튼
- resolver의 하드코딩 loadout 제거

#### 완료 기준
- 각 stage별 포션 로드아웃을 저장할 수 있다.
- 편성 시트에서 수정한 값이 실제 상태에 반영된다.

### 3.7 G단계: 포션 소비 규칙과 sync 경계 정리 [완료]

#### 목표
- loadout이 실제 전투 결과에 영향을 주고, 원정 sync에서도 일관되게 소비되게 한다.

#### 핵심 제약
- 현재 `SessionProgressSyncUseCase`는 battle 쪽에서 `BattleState`만 갱신한다.
- 따라서 포션 소비처럼 player/workshop 재고를 건드리는 규칙은 현재 경계로는 부족하다.

#### 작업
- battle cycle 해석 결과를 `BattleState` 전용 delta가 아니라 `SessionState`에 적용 가능한 구조로 확장
- `resolveCycle()` 반환값에 추가 정보 포함
  - 실제 사용한 potion loadout
  - 부족해서 적용하지 못한 potion
  - 부족 사유
- 소비 규칙
  - 충분하면 사이클마다 포션 소비
  - 부족하면 무보정 전투로 fallback
  - fallback 여부는 전투 결과 이력에 기록
- 즉시 전투와 원정 전투가 같은 결과 적용 경로를 쓰도록 정리

#### 완료 기준
- loadout이 실제 전투 결과와 재고에 영향을 준다.
- 포션 부족 시 전투는 계속 돌되, 로그와 현황 UI에서 이유를 볼 수 있다.

### 3.8 H단계: 테스트 확장 [진행 중]

#### 도메인 테스트
- 아군 stats 계산과 전투력 요약치 일관성
- 적 stats / enemy set / stage 매핑
- 전투 루프 피해 계산 / 행동 순서 / 치명 / 회피
- recent logs 누적 / 10개 cap
- 적별 드롭 / stage별 보상 스케일
- unlock condition 판정
- potion loadout 소비 / 부족 fallback
- 다중 cycle sync 누적 처리

#### 프레젠테이션 테스트
- 전투 결과 시트 렌더
- 최근 결과 요약 라벨
- stage별 적 구성 / 예상 드롭 표시
- loadout 편집 UI
- stage별 잠금 문구 표시

## 4. 권장 다음 순서
1. B단계 잔여 작업
   - Stage 1~5 적 세트 / 드롭 / 보상 / 재료 분배 구체화
   - 상점 전용 재료 제거
   - 재료의 stage 중복 제거
2. H단계 테스트 확장
   - 해금 / loadout / fallback / 소비 회귀 보강
3. clear 기반 unlock 이후의 차기 해금 규칙 재설계 메모 정리

## 5. 남은 PR 분리 기준
- 1차 PR
  - Stage 1~5 적 세트 / 드롭 / 보상 / 재료 분배 구체화
  - 목적: stage progression과 재료 수급 경로 확정
- 2차 PR
  - 회귀 / 보강 테스트
- 3차 PR
  - clear 기반 unlock 이후의 차기 해금 규칙 재설계
  - 목적: 임시 progression 규칙 탈피

## 6. 보류 판단
- 저장/복원은 이 문서 범위에 넣지 않는다.
- 전투 밸런스 수치 자체의 세부 튜닝은 구조 정리 후 별도 밸런스 작업으로 본다.
