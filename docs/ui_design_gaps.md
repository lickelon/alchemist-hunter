# UI 디자인 갭 정리

> 기준 커밋: `20d770f` / 작성일: 2026-05-27  
> 범위: presentation 레이어 전반 (common widgets, 4개 피처 시트/스크린)  
> 범례: ⚠️ 수정 필요 / 🔲 시스템 정의 필요

---

## 1. 정보 밀도 — subtitle에 `\n`으로 줄을 구겨 넣는 패턴

`DetailLines`가 이미 존재함에도 town 시트들은 적용되지 않은 상태다.

### ~~⚠️ 1-1. TownEquipmentSheet — blueprint subtitle 3줄~~ ✅ 수정 완료
`lib/features/town/presentation/widgets/sheets/town_equipment_sheet.dart:38`
```dart
'${entry.slotLabel} / ${entry.statLabel}\n${entry.materialCostLabel}\n제작 시간 ${entry.durationLabel}'
```
슬롯/스탯, 재료 비용, 제작 시간이 하나의 subtitle 문자열에 `\n`으로 연결된다.  
→ `DetailLines`로 분리 완료.

### ~~⚠️ 1-2. TownPotionSaleSheet — subtitle 2줄~~ ✅ 수정 완료
`lib/features/town/presentation/widgets/sheets/town_potion_sale_sheet.dart:32`
```dart
'품질 ${entry.qualityLabel} / 점수 ${entry.scoreLabel}\n판매가 ${entry.saleValue}'
```
판매가가 다음 줄로 내려가 핵심 정보(가격)의 위치가 불명확하다.  
→ `DetailLines` 적용 완료.

### ~~⚠️ 1-3. TownMercenaryHireSheet — subtitle 2줄~~ ✅ 수정 완료
`lib/features/town/presentation/widgets/sheets/town_mercenary_hire_sheet.dart:42`
```dart
'${entry.tierLabel} / ${entry.roleLabel}\n고용 비용 ${entry.hireCost}${entry.hireHint}'
```
→ `DetailLines` 적용 완료.

### ~~⚠️ 1-4. BattleResultSheet — subtitle에 6개 항목이 `/`로 연결~~ ✅ 수정 완료
`lib/features/battle/presentation/widgets/battle_result_sheet.dart:114`
```dart
'${log.success ? '성공' : '실패'} / 골드 ... / 정수 ... / 재료 ...종 / 행동 ...회${log.usedLoadoutFallback ? ' / 포션 부족' : ''}'
```
6개 항목이 한 줄에 `/`로 연결된다. 접힌 상태에서는 overflow되거나 잘린다.  
→ title은 성공/실패와 핵심 보상, subtitle은 재료/행동/포션 부족 상태만 표시하도록 축소 완료.

---

## 2. 컴포넌트 중복 / 패턴 불일치

### ⚠️ 2-1. `_SheetSectionTitle` — private 위젯이 `SectionCard`와 역할 중복
`lib/features/town/presentation/widgets/sheets/town_equipment_sheet.dart:105-113`
```dart
class _SheetSectionTitle extends StatelessWidget {
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.w700));
  }
}
```
`SectionCard`(공통 위젯)가 이미 섹션 구분 역할을 하는데, 이 파일만 별도 private 위젯을 정의했다.  
`SectionCard`를 쓰면 카드 배경과 패딩까지 일관되게 적용된다.  
→ `_SheetSectionTitle` 제거 후 `SectionCard`로 교체.

### ~~⚠️ 2-2. `BattleResultSheet` — ExpansionTile title/subtitle 역할 역전~~ ✅ 수정 완료
`lib/features/battle/presentation/widgets/battle_result_sheet.dart:93-115`

현재:
- `title` → 고정 문자열 "전투 결과" (접힌 상태에서 각 기록을 구분할 수 없음)
- `subtitle` → 성공/실패, 골드, 정수, 재료, 행동 수 등 핵심 요약

타일이 접히면 "전투 결과"만 보인다. 기록이 여러 건일 때 구분이 불가능하다.  
→ `title`에 성공/실패 + 핵심 수치, `subtitle`에 부가 정보를 표시하도록 정리 완료.

### ⚠️ 2-3. `BattleAssignmentSheet` — 삼항 안에 삼항으로 오류 메시지 처리
`lib/features/battle/presentation/widgets/battle_assignment_sheet.dart:46-50`
```dart
'${character.typeLabel} / 전투력 ${character.power}${character.assignmentHint.isNotEmpty
    ? " / ${character.assignmentHint}"
    : character.assignable ? "" : " / 파티가 가득 참"}'
```
"파티가 가득 참"이라는 오류 상태가 정상 정보와 같은 weight의 텍스트로 섞인다.  
→ 오류 상태는 시각적으로 분리(색상 또는 별도 행).

### ⚠️ 2-4. `TownSkillTreeSheet` — 불릿 기호가 데이터 문자열에 포함됨
`lib/features/town/presentation/widgets/sheets/town_skill_tree_sheet.dart:36`
```dart
'${node.depth == 0 ? "●" : "↳"} ${node.name} (${node.levelLabel})'
```
들여쓰기는 `Padding`으로 처리하면서 불릿 표시는 문자열에 직접 구워져 있다. 둘 중 하나로 통일해야 한다.  
→ 불릿도 `Padding` + `Row`로 위젯 수준에서 처리하거나, 들여쓰기를 문자열로 처리.

### ⚠️ 2-5. `TownMercenaryHireSheet` — header에 상태 정보와 액션 버튼 혼재
`lib/features/town/presentation/widgets/sheets/town_mercenary_hire_sheet.dart:19-33`

`header`에 "보유 골드 N"(상태)과 "후보 갱신" 버튼(액션)이 같은 영역에 있다.  
`AppSheetLayout.header`는 현재 상태 표시 용도로 쓰이는 자리다. 액션 버튼은 `footer`나 별도 영역에 있어야 한다.

---

## 3. 패딩 이슈

### ⚠️ 3-1. `WorkshopCraftSheet` — ListTile contentPadding 무력화
`lib/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart:70`
```dart
contentPadding: EdgeInsets.zero,
```
전역 `ListTileThemeData.contentPadding = horizontal: 12, vertical: 2`를 덮어써서, 이 리스트의 아이콘이 `AppBottomSheet`의 12pt outer padding 경계에 바로 붙는다. 같은 시트 내 `AppSheetLayout` 타이틀과 수직 정렬이 어긋난다.

### ⚠️ 3-2. `SectionCard` 내부 padding이 outer padding과 이중 합산됨
`lib/common/widgets/section_card.dart:27`

`AppBottomSheet` outer padding(12pt) + `SectionCard` 내부 padding(12pt) = 24pt.  
반면 `AppSheetLayout` 타이틀과 `SectionCard` 타이틀은 모두 12pt 지점에 있어, 콘텐츠(24pt)와 제목(12pt) 간 들여쓰기 차이가 생긴다.

### ⚠️ 3-3. `AppDialogLayout` actionsPadding top이 0
`lib/common/widgets/app_dialog_layout.dart:49-54`
```dart
actionsPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
```
콘텐츠와 액션 버튼 사이 간격이 0이다. 콘텐츠 위젯이 스스로 하단 여백을 두지 않으면 버튼과 내용이 붙는다.

### ⚠️ 3-4. 아이콘 배지 vertical padding에 raw 픽셀 값
`lib/features/workshop/presentation/widgets/workshop_resource_icon_grid.dart:158`
```dart
padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 1),
```
`AppSpacing.xs = 2pt`인데 vertical만 `1`로 하드코딩됐다. `AppSpacing`에 없는 값이다.

### ⚠️ 3-5. `BorderRadius` 두 곳이 AppRadius 상수를 사용하지 않음
`lib/features/workshop/presentation/widgets/workshop_resource_icon_grid.dart:122, 154`
```dart
borderRadius: BorderRadius.circular(8),  // AppRadius.sm과 동일값이지만 상수 미참조
borderRadius: BorderRadius.circular(6),  // AppRadius에 없는 값
```

### ⚠️ 3-6. 스크롤 감지 임계값에 raw 픽셀 magic number
`lib/features/battle/presentation/widgets/battle_stage_status_sheet.dart:165`
```dart
_timelineScrollController.position.maxScrollExtent - 12
```
"바닥 근처" 판별 임계값이 `12`로 하드코딩됐다.

---

## 4. 디자인 시스템 미정의 항목

### ~~🔲 4-1. 섹션 소제목 텍스트 스타일 토큰 없음~~ ✅ 수정 완료
`TextStyle(fontWeight: FontWeight.w700)`이 섹션 소제목 용도로 최소 7곳에 인라인으로 박혀 있다.

| 파일 | 줄 | 용도 |
|---|---|---|
| `workshop_material_extraction_detail.dart` | 77, 90, 120 | "추출 수량", "분석 결과", "추출 프로필" |
| `workshop_enchant_sections.dart` | 29, 78 | "포션 선택", "장비 선택" |
| `workshop_extraction_sheet.dart` | 22 | "재료 선택" (header) |
| `town_equipment_sheet.dart` | 112 | `_SheetSectionTitle` |
| `workshop_support_sheet.dart` | 36 | SectionCard titleStyle |

반면 `CharacterDetailSection`(`character_detail_section.dart:24`)은 `textTheme.labelLarge?.copyWith(fontWeight: w700, color: primary)`를 사용한다. 같은 역할인데 구현이 다르다.

→ `AppTextStyles.subsectionTitle` ThemeExtension을 추가하고 관련 소제목이 이를 참조하도록 통일 완료.

### 🔲 4-2. `FontWeight.w600` vs `w700` 사용 기준 미정의
- `AppBadge` 라벨: `w600`
- `_StatCell` 수치 (전투 스탯): `w600`
- 전투력 라벨 (`powerLabel`): `w600`
- 모든 섹션 소제목: `w700`
- `titleMedium` 테마: `w700`

"강조 데이터 값 = w600, 제목 = w700" 처럼 쓰이는 것 같지만 어디에도 명시되어 있지 않다.  
→ AppTheme 또는 별도 문서에 weight 사용 기준을 정의.

### 🔲 4-3. 바텀 시트에 드래그 핸들 없음
`lib/common/widgets/app_bottom_sheet.dart`

`enableDrag: true`이지만 상단 pill(drag handle)이 없다.  
`showModalBottomSheet`에 `showDragHandle: true`를 전달하지 않으면 Flutter가 자동 추가하지 않는다.  
→ `showAppBottomSheet`에 `showDragHandle: true` 추가, 또는 시스템 차원에서 정책 결정.

### 🔲 4-4. 빈 상태(empty state) 위젯 패턴 미정의
두 가지 형태가 혼재한다.

```dart
// 형태 A — Center (중앙 정렬)
const Center(child: Text('큐가 비어있습니다'))

// 형태 B — Padding (좌측 정렬, 센터링 없음)
const Padding(
  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
  child: Text('등록된 대장간 작업이 없습니다'),
)
```

공통 `AppEmptyState` 위젯이 없어 각 시트마다 다르게 처리된다.

### 🔲 4-5. 탭 바 텍스트가 영어
`lib/app/app.dart:133-137`
```dart
Tab(text: 'Town')
Tab(text: 'Workshop')
Tab(text: 'Characters')
Tab(text: 'Battle')
```
앱 전체가 한국어인데 하단 탭만 영어다. 의도적 선택인지 미처리인지 불명확하고 어디에도 문서화되지 않았다.

### 🔲 4-6. 다이얼로그 높이 시스템 미정의
`AppBottomSheet`는 `maxHeight = 0.9 * screenHeight`로 캡을 정의했지만, 다이얼로그는 각자 다른 비율을 직접 쓴다.

| 파일 | 줄 | 값 |
|---|---|---|
| `battle_result_sheet.dart` | 62 | `* 0.52` |
| `workshop_material_extraction_detail.dart` | 159 | `* 0.58` |

→ `AppDialogHeight` 상수 또는 `AppBottomSheet`와 동일한 방식의 토큰 정의 필요.

### 🔲 4-7. `AppRadius`에 작은 pill 반지름 없음
현재 AppRadius:
- `sm = 8pt` — 카드/컨테이너
- `md = 12pt` — 인터랙티브 요소
- `lg = 16pt` — 대형 컨테이너
- `progress = 3.0` — 프로그레스 바 (시맨틱 이름이지만 범용성 없음)

아이콘 배지(`BorderRadius.circular(6)`), `AppBadge`(`BorderRadius.circular(AppSpacing.sm)` = 4pt) 같이 작은 pill 형태가 필요한 곳에서 각자 임의 값을 쓴다.  
→ `AppRadius.chip` 또는 `AppRadius.badge`(4~6pt) 추가.

### 🔲 4-8. `AppBadge`의 borderRadius가 spacing 값을 반지름으로 오용
`lib/common/widgets/app_badge.dart:17`
```dart
borderRadius: BorderRadius.circular(AppSpacing.sm), // 4pt — spacing 상수를 radius로 사용
```
`AppSpacing.sm = 4`는 간격 값인데 모서리 반지름에 사용됐다.  
4-7에서 `AppRadius.badge`가 정의되면 이를 참조하도록 교체.

### 🔲 4-9. `_kSelectorMaxHeight = 120.0` — 레이아웃 제약이 magic number
`lib/features/workshop/enchanting/presentation/widgets/workshop_enchant_sections.dart:10`
```dart
const double _kSelectorMaxHeight = 120.0;
```
아이콘 그리드 2행 분량(`tileSize 52 + spacing 4 + tileSize 52 + runSpacing 4 = 112`에 여유)이지만, 타일 크기(`tileSize = 52`)와의 관계가 코드에 표현되어 있지 않다. 타일 크기 변경 시 이 값도 수동으로 맞춰야 한다.

### 🔲 4-10. `_kDepthIndent = 20.0` — AppSpacing에 없는 레이아웃 상수
`lib/features/town/presentation/widgets/sheets/town_skill_tree_sheet.dart:9`
```dart
const double _kDepthIndent = 20.0;
```
`AppSpacing`에 없는 값이 파일 로컬 상수로만 존재한다.

### 🔲 4-11. `BattleStageStatusSheet` 레이아웃 상수 5개가 파일 상단에 하드코딩
`lib/features/battle/presentation/widgets/battle_stage_status_sheet.dart:16-20`
```dart
const double _unitBoardCardHeight = 360;
const double _unitBoardMinHeight = 220;
const double _compactLayoutReserveHeight = 250;
const double _progressCardHeight = 44;
const double _timelineLineHeight = 24;
```
AppSpacing에 없는 레이아웃 제약들이 파일 내에 흩어져 있다. 이 값들이 서로 어떤 관계인지 코드만으로 파악하기 어렵다.

---

## 우선순위 요약

| 우선순위 | 항목 | 파급 범위 |
|---|---|---|
| 완료 | 1-1~1-4. subtitle `\n` 정보 밀도 | town 시트 전반, battle result |
| 완료 | 2-2. BattleResultSheet title/subtitle 역전 | battle |
| 완료 | 4-1. 섹션 소제목 스타일 토큰 없음 | 앱 전반 |
| 중간 | 2-1. `_SheetSectionTitle` 중복 | town equipment |
| 중간 | 2-3. BattleAssignment 삼항 중첩 오류 처리 | battle |
| 중간 | 3-1. WorkshopCraftSheet contentPadding 무력화 | workshop craft |
| 중간 | 3-2. SectionCard 이중 padding | 공통 |
| 중간 | 4-3. 드래그 핸들 없음 | 모든 bottom sheet |
| 중간 | 4-4. empty state 위젯 미정의 | 앱 전반 |
| 낮음 | 2-4. 스킬트리 불릿 기호 문자열 내 포함 | town skill tree |
| 낮음 | 2-5. 용병 고용 header 역할 혼재 | town mercenary |
| 낮음 | 3-3~3-6. 개별 padding raw 값 | 산발적 |
| 낮음 | 4-2. w600/w700 기준 미정의 | 앱 전반 |
| 낮음 | 4-5. 탭 바 영어 | app.dart |
| 낮음 | 4-6~4-11. AppRadius/AppSpacing 시스템 갭 | 공통 |
