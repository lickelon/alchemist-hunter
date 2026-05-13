# UI/UX 검토 보고서

> 최초 검토: 2026-05-14 / 2차 검토: 2026-05-14

범례: ✅ 수정 완료 / ⚠️ 수정 필요 / 🔍 확인 필요

---

## 1. 불필요한 정보 표시

### ✅ 1-1. AppBar 다이아몬드 — 수량 미표시
- `lib/app/app.dart` — `state.player.diamonds` 바인딩으로 수정 완료

### ✅ 1-2. CharacterCombatEffectSection — 빈 상태 처리 없음
- `lib/features/characters/presentation/widgets/character_detail_sheet.dart` — `effectLines.isNotEmpty` 조건 추가 완료

### 🔍 1-3. WorkshopLogCard — 화면에 미표시
- `lib/features/workshop/dashboard/presentation/widgets/workshop_log_card.dart`
- 구현·export 되어 있으나 `WorkshopScreen` 자식 목록에 없음. 데드코드인지 의도적 미노출인지 불명확.
- **방향**: WorkshopScreen에 추가할지 파일을 제거할지 결정 필요.

---

## 2. 디자인 시스템 위배

### ✅ 2-1. Workshop 탭 카드 이름 영한 혼용
- "Craft Queue" → "제작 대기열", "Craft" → "포션 제작" 등 한국어 통일 완료

### ⚠️ 2-2. Scaffold 중첩 패턴 — 2곳 미수정
`WorkshopEnqueueOptionsSheet`에서는 제거됐으나 두 곳이 남아 있음.

| 파일 | `sheetContext` 용도 |
|---|---|
| `workshop_enchant_sheet.dart:94` | `Navigator.of(sheetContext).pop()` + `AppToast.show` |
| `workshop_hatch_sheet.dart:24` | `AppToast.show(sheetContext, …)` |

두 파일 모두 `context`를 직접 사용하는 것으로 대체 가능. (`WorkshopEnchantSheet`는 `ConsumerStatefulWidget`, `WorkshopHatchSheet`는 `ConsumerWidget`)

### ⚠️ 2-3. 작업실 자원 카드 — ListCard로 전환이 오히려 역효과
- `lib/features/workshop/dashboard/presentation/screens/workshop_screen.dart:62`
- 이전 수정에서 `Card + ListTile` → `ListCard(onTap: null)`로 전환했으나, chevron은 없어도 외형이 클릭 가능한 다른 카드들과 구분이 안 됨.
- **방향**: 마을 경제 카드(`town_screen.dart:32-38`)와 동일하게 `Card + ListTile` 직접 구현으로 되돌리기.

### ⚠️ 2-4. info-only 카드 패턴 미정의
- `town_screen.dart:32-38` (마을 경제), `workshop_screen.dart:62` (작업실 자원)
- 클릭 불가 정보 표시 전용 카드를 `Card(child: ListTile(…))` 직접 구현. 두 곳에서 동일하게 사용하지만 공용 컴포넌트가 없음.
- **방향**: `InfoCard` 컴포넌트 정의 또는 현재 패턴을 관례로 문서화.

### ✅ 2-5. ListCard trailing chevron 항상 표시
- `list_card.dart` — `onTap == null ? null : const Icon(Icons.chevron_right)` 처리 완료

### ⚠️ 2-6. CharacterCard — InkWell vs Card borderRadius 불일치
- `character_card.dart:31`
- `InkWell(borderRadius: AppRadius.interactive)` = 12pt, CardTheme의 card radius = `AppRadius.card` = 8pt
- 리플 효과가 카드 테두리를 벗어날 수 있음.
- **방향**: `InkWell`의 `borderRadius`를 `AppRadius.card`로 맞추기.

### ⚠️ 2-7. BattleResultSheet — 색상 하드코딩
- `battle_result_sheet.dart:52-55`
- `Colors.green.shade700` / `Colors.red.shade700` 직접 사용.
- **방향**: 성공/실패 의미의 색은 `colorScheme.primary` / `colorScheme.error` 계열로 교체.

### ⚠️ 2-8. 하드코딩된 수치
| 파일 | 코드 | 권장 |
|---|---|---|
| `battle_assignment_sheet.dart:56` | `EdgeInsets.fromLTRB(16, 8, 16, 4)` | `AppSpacing` 상수 사용 |

---

## 3. 디자인 시스템에 없는 UI 패턴

### ⚠️ 3-1. 섹션 카드 패턴 3중 중복 구현
"제목 있는 카드 섹션" 컨셉이 세 곳에 각각 별도 구현되어 있음.

| 위젯 | 위치 | 특징 |
|---|---|---|
| `CharacterDetailSection` | `character_detail_section.dart` | primary 색상 제목, trailing 지원 |
| `BattleStatusCard` | `battle_status_card.dart` | 단순 제목, trailing 없음 |
| 슬롯 카드 (inline) | `workshop_support_sheet.dart:34` | Card + Padding + Column 직접 구현 |

- **방향**: 공통 컴포넌트 하나로 통합하거나 `CharacterDetailSection`을 표준으로 지정하고 나머지 교체.

### ⚠️ 3-2. 뱃지 컴포넌트 (`_GrowthBadge`) — private 위젯으로만 존재
- `character_growth_section.dart:79-104`
- `secondaryContainer` 색상 + `labelSmall` 텍스트의 배지. 재사용 불가.
- **방향**: `common/widgets`에 공용 컴포넌트로 추출 검토.

---

## 4. 과도한 정보 밀도

### ⚠️ 4-1. 스킬트리 시트 — ListTile subtitle에 6줄 텍스트
동일한 패턴이 두 파일에 존재.

- `town_skill_tree_sheet.dart:40-45`
- `workshop_skill_tree_sheet.dart:43`

```
description\n현재 효과\n다음 효과\n선행조건\n비용\n상태
```

ListTile subtitle은 단문 보조 텍스트 용도. 6개 항목을 `\n`으로 연결하면 시각 계층이 없어 읽기 어려움.

### ⚠️ 4-2. 호문쿨루스 부화 시트 — ListTile subtitle에 6줄 텍스트
- `workshop_hatch_sheet.dart:43`

```
description\n결과\n역할\n보조효과\n비용\n가용성
```

스킬트리와 동일한 문제.

---

## 5. 기타 UX

### ⚠️ 5-1. TownEquipmentSheet — expandBody 암묵적 의존
- `town_equipment_sheet.dart:28-105`
- `AppSheetLayout`에 `expandBody` 미지정(기본값 `true`)인데, body로 `Column + Expanded 3개` 구조를 전달.
- 세 섹션("장비 등록", "대장간 진행", "보유 장비")이 남은 공간을 항상 3등분. 각 섹션 아이템 수가 차이 날 경우 공간 낭비가 생길 수 있음.
- **방향**: 의도적이라면 주석으로 명시. 비의도적이라면 각 섹션 높이를 콘텐츠에 맞게 조정.

### ⚠️ 5-2. WorkshopSupportSheet — 후보 선택 UI 연결이 불명확
- `workshop_support_sheet.dart:49-89`
- ChoiceChip 목록(선택용)과 그 아래 텍스트 리스트(설명용)가 동일 candidates를 두 번 순회.
- 선택한 칩과 해당 설명 텍스트의 시각적 연결이 없음.
- **방향**: 칩과 설명을 같은 항목 내에 배치하거나, 선택된 항목의 설명만 표시하는 방식 검토.

---

## 우선순위 요약

| 우선순위 | 이슈 |
|---|---|
| 높음 | 2-2. Scaffold 중첩 2곳 미수정 |
| 높음 | 2-3. 작업실 자원 카드 ListCard 전환 되돌리기 |
| 높음 | 4-1/4-2. 스킬트리·부화 시트 6줄 subtitle |
| 중간 | 2-6. CharacterCard InkWell borderRadius 불일치 |
| 중간 | 2-7. BattleResultSheet 색상 하드코딩 |
| 중간 | 3-1. 섹션 카드 패턴 3중 중복 |
| 중간 | 5-1. TownEquipmentSheet expandBody 암묵적 의존 |
| 낮음 | 2-4. info-only 카드 패턴 미정의 |
| 낮음 | 2-8. 하드코딩된 패딩 |
| 낮음 | 3-2. 뱃지 컴포넌트 미정의 |
| 낮음 | 5-2. SupportSheet 선택 UX 불명확 |
| 확인 필요 | 1-3. WorkshopLogCard 미표시 |
