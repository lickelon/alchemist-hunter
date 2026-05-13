# UI/UX 검토 보고서

> 검토 기준일: 2026-05-14

---

## 1. 불필요한 정보 표시

### 1-1. AppBar 다이아몬드 — 수량 미표시

- **파일**: `lib/app/app.dart:87-93`
- **현상**: `Row([Text('Diamonds'), Icon(Icons.diamond)])` 형태로 라벨만 표시. 실제 보유 수량 없음.
- **문제**: 게임 내 프리미엄 재화 UI인데 숫자가 없어 사용자에게 무의미한 정보.
- **방향**: 실제 보유 수량을 표시하거나, 준비 전이라면 AppBar에서 제거.

### 1-2. CharacterCombatEffectSection — 빈 상태 처리 없음

- **파일**: `lib/features/characters/presentation/widgets/character_detail_sheet.dart:61-63`
- **현상**: `effectLines`가 빈 배열일 때도 `CharacterCombatEffectSection`이 항상 렌더링됨.
- **문제**: "전투 효과" 제목만 있고 내용 없는 빈 카드 섹션이 표시될 수 있음.
- **방향**: `effectLines.isEmpty` 시 섹션 자체를 숨김 처리.

### 1-3. WorkshopLogCard — 화면에 미표시

- **파일**: `lib/features/workshop/dashboard/presentation/widgets/workshop_log_card.dart`, `lib/features/workshop/dashboard/presentation/widgets/workshop_sections.dart:23`
- **현상**: `WorkshopLogCard`는 구현·export 되어 있으나 `WorkshopScreen` 자식 목록에 없음.
- **문제**: 데드코드인지 의도적 미노출인지 불명확.
- **방향**: WorkshopScreen에 추가할지, 파일을 제거할지 결정 필요.

---

## 2. 디자인 시스템 위배

### 2-1. Workshop 탭 카드 이름이 영어 (Town 탭은 한국어)

| 위치 | 현재 이름 |
|---|---|
| `workshop_queue_card.dart:15` | `"Craft Queue"` |
| `workshop_craft_card.dart:21` | `"Craft"` |
| `workshop_extraction_card.dart:14` | `"Extraction"` |
| `workshop_enchant_card.dart:14` | `"Enchant"` |
| `workshop_hatch_card.dart:14` | `"Homunculus Hatch"` |
| `workshop_inventory_card.dart:25` | `"Inventory"` |
| `workshop_support_card.dart:21` | `"Workshop Support"` |
| `workshop_skill_tree_card.dart:19` | `"Workshop Skill Tree"` |
| `workshop_screen.dart:57` (리소스 카드) | `"Workshop Resources"` |

- **문제**: Town 탭 카드("일반 상점", "용병 고용", "마을 스킬트리" 등)는 모두 한국어인데 Workshop 탭만 전부 영어. 앱 전체 언어 일관성 없음.
- **방향**: Workshop 카드 이름을 한국어로 통일하거나, 앱 전체를 영어로 통일.

### 2-2. 하드코딩된 BorderRadius

| 파일 | 코드 | 권장 |
|---|---|---|
| `battle_stage_status_sheet.dart:369` | `BorderRadius.circular(12)` | `AppRadius.interactive` |
| `character_detail_sections.dart:102` | `BorderRadius.circular(3)` | 디자인 시스템에 3pt 없음 — 정의 추가 또는 기존 상수로 교체 |

### 2-3. 하드코딩된 패딩

- **파일**: `lib/features/battle/presentation/widgets/battle_assignment_sheet.dart:56`
- **코드**: `EdgeInsets.fromLTRB(16, 8, 16, 4)`
- **권장**: `EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.sm)`

### 2-4. WorkshopEnqueueOptionsSheet — Scaffold 중첩

- **파일**: `lib/features/workshop/crafting/presentation/widgets/workshop_enqueue_options_sheet.dart:32-70`
- **현상**: 다른 모든 시트는 `AppBottomSheet > AppSheetLayout > 내용` 구조. 이 시트만 `AppBottomSheet > Scaffold > Builder > AppSheetLayout > 내용` 구조.
- **문제**: `Navigator.of(sheetContext).pop()` 호출을 위해 Scaffold로 context를 취득하는 비표준 패턴. 디자인 시스템에 정의 없음.
- **방향**: pop context 취득을 다른 방법으로 처리하고 Scaffold 제거.

### 2-5. 섹션 카드 패턴 중복 구현

| 위젯 | 위치 | 특징 |
|---|---|---|
| `CharacterDetailSection` | `character_detail_sections.dart:7-51` | primary 색상 제목, trailing 지원 |
| `_StatusCard` | `battle_stage_status_sheet.dart:420-442` | 단순 제목, trailing 없음 |

- **문제**: 둘 다 "제목 있는 카드 섹션" 컨셉이지만 별도 구현.
- **방향**: 하나로 통합하거나, 어느 쪽을 공용 컴포넌트로 승격할지 결정. `_StatusCard`를 `CharacterDetailSection`으로 교체 검토.

---

## 3. 디자인 시스템에 없는 UI 패턴

### 3-1. 뱃지 컴포넌트 (`_GrowthBadge`)

- **파일**: `lib/features/characters/presentation/widgets/character_detail_sections.dart:125-150`
- **현상**: `secondaryContainer` 색상 + `labelSmall` 텍스트 조합의 인라인 배지. private 위젯으로만 정의.
- **문제**: 재사용 불가. 유사한 배지가 다른 화면에 필요할 때 별도 구현하게 됨.
- **방향**: `AppBadge` 등의 이름으로 `common/widgets`에 공용 컴포넌트로 추출하거나, 디자인 시스템 문서에 패턴 정의.

### 3-2. 탭 불가 요약 카드 (`Card + ListTile` 직접 사용)

- **파일**: `lib/features/town/presentation/screens/town_screen.dart:33-38`, `lib/features/workshop/dashboard/presentation/screens/workshop_screen.dart:54-61`
- **현상**: 클릭 안 되는 정보 표시 전용 카드를 `Card(child: ListTile(...))` 패턴으로 직접 구현.
- **문제**: `ListCard`는 항상 `chevron_right`를 표시하므로 탭 없는 카드에 사용 불가. "info-only 카드" 패턴이 디자인 시스템에 정의되어 있지 않음.
- **방향**: `ListCard`에 `onTap: null`일 때 chevron을 숨기는 처리 추가, 또는 별도 `InfoCard` 컴포넌트 정의.

### 3-3. ListCard — trailing chevron 항상 표시

- **파일**: `lib/common/widgets/list_card.dart:26`
- **코드**: `trailing: const Icon(Icons.chevron_right)` — `onTap` 유무와 무관하게 항상 표시.
- **문제**: 비활성 상태를 지원하지 않는 컴포넌트 설계. `onTap: null` 전달 시 시각적으로 클릭 가능처럼 보임.
- **방향**: `onTap == null ? null : const Icon(Icons.chevron_right)` 처리 추가.

---

## 우선순위 요약

| 우선순위 | 이슈 | 이유 |
|---|---|---|
| 높음 | 2-1. Workshop 카드 이름 영한 혼용 | 사용자에게 직접 보이는 일관성 문제 |
| 높음 | 1-2. 빈 전투 효과 섹션 | 실제로 빈 카드가 렌더링될 수 있음 |
| 높음 | 2-4. Scaffold 중첩 | 비표준 패턴, 예상치 못한 동작 가능성 |
| 중간 | 1-1. 다이아몬드 수량 미표시 | 기능 미완성 또는 불필요한 UI |
| 중간 | 2-5. 섹션 카드 패턴 중복 | 유지보수 비용 증가 |
| 중간 | 3-2. info-only 카드 패턴 미정의 | 동일 패턴 재사용 시 일관성 깨짐 |
| 낮음 | 2-2, 2-3. 하드코딩된 수치 | 기능 영향은 없지만 시스템 일관성 |
| 낮음 | 3-1. 뱃지 컴포넌트 미정의 | 현재는 한 곳에서만 사용 |
| 낮음 | 3-3. ListCard chevron 항상 표시 | 현재 사용처에서는 실문제 없음 |
| 확인 필요 | 1-3. WorkshopLogCard 미표시 | 의도적인지 여부 불명확 |
