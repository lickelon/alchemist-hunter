# Workshop 디자인 현황 / 이슈

## 1. 목적
현재 Workshop 피처의 시트, 모달, 자원 표시 UI를 기준으로 남은 디자인 이슈를 정리한다.

이 문서는 구현 계획서가 아니라 현황 판단 문서다. 실제 수정은 아래 우선순위에 따라 별도 커밋으로 진행한다.

## 2. 현재 화면 구조

`WorkshopScreen`은 정보 카드 1개와 기능 카드 7개로 구성된다.

- `InfoCard`: 작업실 자원
- `WorkshopQueueCard`: 작업 큐
- `WorkshopExtractionCard`: 재료 추출
- `WorkshopCraftCard`: 포션 제작
- `WorkshopEnchantCard`: 장비 인챈트
- `WorkshopHatchCard`: 호문쿨루스 부화
- `WorkshopInventoryCard`: 작업실 인벤토리
- `WorkshopSkillTreeCard`: 작업실 스킬트리

이전 미사용 자원 카드였던 `WorkshopMaterialCard`와 `WorkshopCraftedPotionCard`는 제거했다. 재료 / 원소 / 포션 조회 진입점은 `WorkshopInventoryCard`로 본다.

`WorkshopSupportCard`는 제품 기능 제외 결정에 따라 대시보드 진입점에서 제거했다. support feature 로직과 상태는 아직 남아 있으며, 추후 별도 제거 대상으로 둔다.

## 3. 공통 UI 사용 현황

| 컴포넌트 | 현재 사용 |
| --- | --- |
| `AppSheetLayout` | Workshop 주요 바텀시트에서 사용 |
| `AppDialogLayout` | 상세 / 확인 / 보조 입력 다이얼로그에서 사용 |
| `showAppBottomSheet` | 대시보드 카드에서 시트 진입 시 사용 |
| `ListCard` | Workshop 기능 카드에서 사용 |
| `ResourceIconGrid` | Workshop 재료 / 원소 / 포션 그리드 표시에서 사용 |

`ResourceIconGrid`는 `common/widgets`의 공통 위젯이다. Workshop뿐 아니라 Town 포션 판매, Town 대장간 보유 장비, Characters 장비 선택, Battle 보상 수령에서도 같은 패턴을 쓴다.

## 4. 이슈별 분석

### ~~4.1 Dialog / Sheet 이중 프레젠테이션 래퍼~~ ✅ 정리 완료

현황:

- `WorkshopEnqueueOptionsSheet`를 제거하고 `WorkshopEnqueueOptionsDialog`만 남겼다.
- `WorkshopMaterialExtractionDetail` sheet 래퍼를 제거하고 `WorkshopMaterialExtractionDetailDialog`만 남겼다.
- sheet/dialog enum 분기 구조를 제거했다.

영향:

- 새 호출 지점은 다이얼로그 래퍼만 사용하면 된다.
- 바텀시트 안에서 추가 상세 / 보조 입력은 다이얼로그로 여는 디자인 기준과 맞는다.

권장 조치:

- 완료 상태를 유지한다.

우선순위: 완료

### ~~4.2 미사용 자원 카드~~ ✅ 정리 완료

대상:

- `WorkshopMaterialCard`
- `WorkshopCraftedPotionCard`

현황:

- `WorkshopMaterialCard`와 `WorkshopCraftedPotionCard`를 제거했다.
- 재료 / 원소 / 포션 조회는 `WorkshopInventoryCard`가 담당한다.

영향:

- 자원 조회 진입점이 `WorkshopInventoryCard`로 단순화됐다.

권장 조치:

- 별도 빠른 접근 카드가 필요해지기 전까지 재료 / 포션 전용 카드를 다시 만들지 않는다.

우선순위: 완료

### 4.3 자원 선택 UI와 작업 선택 UI의 표현 기준

그리드 적용:

- 추출 재료 선택
- 작업실 인벤토리 재료 / 원소 / 포션 탭
- 인챈트 포션 / 장비 선택

리스트 유지:

- 포션 제조 선택
- 호문쿨루스 부화 레시피
- 작업실 스킬트리

현황 판단:

- 자원 조회는 아이콘 그리드와 상세 모달로 정리되고 있다.
- 자원 선택도 아이콘 그리드 기반으로 정리되고 있다.
- 작업 선택, 레시피 선택, 스킬트리처럼 설명과 액션이 중심인 화면은 리스트가 자연스럽다.

영향:

- 포션 제조, 부화, 스킬트리는 작업 선택 / 설정 화면이므로 리스트 유지가 자연스럽다.
- 작업실 보조 슬롯은 제품 기능에서 제외되어 신규 UI 기준에 포함하지 않는다.

권장 조치:

- 제조, 부화, 스킬트리는 현재 리스트를 유지한다.
- 이후 다른 자원 선택 화면이 추가되면 `ResourceIconGrid`를 우선 검토한다.

우선순위: 낮음

### 4.4 상세 모달 내부 표현 차이

대상:

- 자원 상세 모달
- 추출 상세 모달
- 제조 수량 선택 모달
- 인챈트 확인 모달

현황:

- 외부 표면은 `AppDialogLayout`으로 통일되어 있다.
- 내부 콘텐츠는 기능별로 다르다.
- 자원 상세 모달은 단순 텍스트 행, 추출 상세 모달은 수량 선택 / 원소 선택 / 등록 액션을 포함한다.

영향:

- 기능 차이에 따른 표현 차이라 직접적인 문제는 아니다.
- 다만 단순 상세 행은 `DetailLines`와 역할이 일부 겹친다.

권장 조치:

- 지금은 유지한다.
- 자원 상세 모달이 더 늘어나면 `DetailLines` 또는 자원 상세 전용 위젯으로 정리한다.

우선순위: 낮음

### ~~4.5 `WorkshopResourceIconGrid` 위치~~ ✅ 정리 완료

현황:

- `ResourceIconGrid`로 이름을 바꾸고 `lib/common/widgets`로 이동했다.
- Workshop / Town / Characters / Battle에서 같은 아이콘 그리드 패턴을 공유한다.

영향:

- feature 전용 위젯을 다른 feature에서 참조하지 않아도 된다.
- 배지, radius, tile 크기 기준이 한 곳으로 모인다.

권장 조치:

- 완료 상태를 유지한다.

우선순위: 완료

### ~~4.6 `WorkshopMaterialCard`와 `WorkshopInventoryCard` 역할 중복~~ ✅ 정리 완료

현황:

- `WorkshopInventoryCard`는 재료 / 원소 / 포션 전체 조회 진입점이다.
- `WorkshopMaterialCard`와 `WorkshopCraftedPotionCard`는 제거했다.

영향:

- 자원 조회 카드의 역할 중복은 현재 없다.

권장 조치:

- `WorkshopInventoryCard`를 단일 조회 진입점으로 유지한다.

우선순위: 완료

## 5. 권장 작업 순서

1. 자원 상세 모달이 더 늘어날 때 상세 행 표현 정리
2. 새 자원 선택 화면이 추가되면 `ResourceIconGrid` 우선 검토
