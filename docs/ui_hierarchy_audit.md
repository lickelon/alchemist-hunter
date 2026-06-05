# UI 정보 위계 감사 (2026-06-05)

## 1. 개요

현재 코드베이스에서 발견된 정보 위계 및 시각 위계 이슈를 분류하고 파일·라인 기준으로 정리한다.
이슈는 근본 원인 패턴 기준으로 분류한다.

---

## 2. 패턴 A — 레이블 함수가 `\n`/` / ` 연결 문자열을 반환

UI 레이어에서 `_splitEquipmentLabel`, `_splitEffectLabel` 같은 파싱 함수가 여러 곳에 반복 등장한다.
이는 레이블 함수가 레이아웃 결정을 문자열 포맷으로 끌고 들어갔기 때문이다.

단, 이 패턴은 모두 같은 원인으로 묶으면 안 된다.
장비 라벨 파싱(A1~A4, A6)은 `equipment_*_labels.dart`의 반환 형태가 직접 원인이지만,
전투 효과 라벨(A5), 드롭 라벨(A7), 스킬트리 라벨(A8)은 별도 표시 모델을 구조화해야 하는 독립 이슈다.

적용 상태:
- A1~A4, A6: 완료. 장비 스탯/효과/detail label list API를 추가하고 장비 UI의 `_splitEquipmentLabel` 파싱을 제거했다.
- A5: 완료. 캐릭터 전투 효과 label을 atomic list로 내려 UI split을 제거했다.
- A7: 완료. 전투 드롭 스탯/효과 label을 atomic list로 내려 UI split을 제거했다.
- A8: 완료. 스킬트리 detail label을 list 모델로 바꾸고 `_badgeLabels` split을 제거했다.
- A9: 완료. 배치 상태 prefix를 view model에서 제거하고 UI가 필요한 문맥을 직접 붙이도록 정리했다.

### 2.1 근본 원인 파일

**`lib/features/town/equipment/equipment_stat_labels.dart:39`**
```dart
return '${segments.take(3).join(' / ')}\n${segments.skip(3).join(' / ')}';
```
6개 스탯을 `'체력 N / 물공 N / 물방 N\n마공 N / 마방 N / 속도 N'` 형식으로 반환.
UI가 이 구조를 알고 있어야 렌더링 가능.

**`lib/features/town/equipment/equipment_detail_labels.dart:12, 26`**
```dart
return '$statLabel\n${equipmentBlueprintEffectLabel(blueprint)}';  // :12
return lines.join('\n');  // :26
```
`equipmentBlueprintDetailLabel`, `equipmentInstanceDetailLabel` 모두 `\n`으로 섹션을 연결해 반환.

### 2.2 증상 — UI에서 파싱하는 우회 함수

| 파일 | 라인 | 함수명 | 역할 |
|------|------|--------|------|
| `town/widgets/sheets/town_equipment_sheet.dart` | 195-200 | `_splitEquipmentLabel` | `\n`, ` / ` 기준 분리 후 badge 생성 |
| `characters/widgets/character_equipment_section.dart` | 76-82 | `_splitEquipmentLabel` | 동일 (복사된 패턴) |
| `characters/widgets/character_combat_sections.dart` | 54-59 | `_splitEffectLabel` | 동일 |
| `characters/widgets/character_equipment_header.dart` | 75-81 | `_splitEquipmentLabel` | 동일 (4번째 복사) |
| `battle/widgets/battle_stage_drop_list.dart` | 105-110 | `_splitDropLabel` | 동일 (5번째 복사) |
| `common/widgets/skill_tree_node_detail_dialog.dart` | 84-89 | `_badgeLabels` | ` / ` 분리 후 prefix 붙여 badge 생성 |

`_splitEquipmentLabel`은 장비 라벨 포맷 문제의 직접 증상이다.
`_splitEffectLabel`, `_splitDropLabel`, `_badgeLabels`는 유사한 문자열 파싱 증상이지만,
장비 라벨 수정으로 해결되지 않으므로 별도 작업으로 분리한다.

### 2.3 증상 — UI에서 뷰모델 문자열 조작

**`lib/features/characters/presentation/widgets/character_assignment_section.dart:18`**
```dart
final String statusLabel = assignmentLabel.replaceFirst('배치 상태: ', '');
```
뷰모델이 `'배치 상태: 대기'` 형태로 반환하고, UI가 prefix를 직접 제거.

### 2.4 수정 방향
- 장비 스탯/효과 라벨은 가능하면 `List<String>` 또는 `List<StatLine>` 같은 구조화 데이터로 전달한다.
- `formatEquipmentStatLabel`을 단일 문자열로만 바꾸는 것은 임시 완화일 뿐 최종 방향이 아니다.
- 호출부(CharacterEquipmentSection 등)가 줄바꿈과 badge 배치를 직접 결정한다.
- UI의 `_splitEquipmentLabel` 파싱 함수를 제거한다.
- 전투 효과, 드롭 라벨, 스킬트리 효과/비용 라벨은 장비 라벨 작업과 분리해 별도 구조화 여부를 판단한다.
- `assignmentLabel`에서 `'배치 상태: '` prefix를 뷰모델에서 제거한다.

---

## 3. 패턴 B — 경고·상태 정보와 네비게이션·액션이 같은 레이아웃 영역에 혼재

적용 상태:
- B1: 완료. 연금술 시트의 큐 경고를 TabBar header에서 body 상단 상태 표시로 분리했다.
- B2: 완료. 상점 갱신 버튼을 header에서 footer 액션 영역으로 이동하고, header에는 갱신 비용만 남겼다.

### 3.1 연금술 시트 header

**`lib/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart:61-79`**
```dart
header: Column(
  children: [
    if (queueFull) ...[AppBadge(label: '큐 가득 참 N/N'), SizedBox(...)],
    const TabBar(tabs: [...]),
  ],
),
```
큐 경고(상태 정보)와 TabBar(네비게이션)가 같은 `Column` 안에 나열됨.
큐가 가득 찼을 때 탭 위에 배지가 붙는 구조라 경고가 네비게이션과 같은 시각 무게로 표시됨.

**수정 방향**: 큐 경고는 body 상단 배너 또는 `AppSheetLayout` 별도 영역으로 분리.

### 3.2 상점 header

**`lib/features/town/presentation/widgets/sheets/town_shop_sheet.dart:37-54`**
```dart
header: Column(
  children: [
    Row(children: [
      AppBadge(label: '골드 $refreshCost'),
      FilledButton.tonalIcon(onPressed: ..., label: Text('갱신')),
    ]),
  ],
),
```
갱신 비용 배지(정보)와 갱신 버튼(액션)이 header에 함께 있음.
`AppSheetLayout.footer`에 갱신 버튼을 배치하고, header는 상태 정보만 남겨야 한다.

---

## 4. 패턴 C — Action 영역(버튼)에 상태 텍스트가 노출

적용 상태:
- C1: 완료. 상점 구매 버튼 라벨을 항상 `구매`로 고정했다.
- C2: 완료. 캐릭터 성장의 최대 티어 상태를 disabled button에서 badge로 바꿨다.

### 4.1 상점 구매 버튼

**`lib/features/town/presentation/widgets/sheets/town_shop_sheet.dart:215`**
```dart
child: Text(widget.soldOut ? '품절' : '구매'),
```
`onPressed: null`인 버튼 라벨이 '품절'로 표시됨.
그리드 아이콘에 이미 '품절' 배지가 있어 중복이고, 버튼 영역이 상태 표시에 사용됨.

**수정 방향**: 버튼 라벨은 항상 '구매'로 고정하고, 품절 상태는 기존 그리드 배지로만 전달.

### 4.2 캐릭터 성장 '최대' 버튼

**`lib/features/characters/presentation/widgets/character_growth_section.dart:95-96`**
```dart
if (character.tierIndex >= character.maxTier) {
  return FilledButton.tonal(onPressed: null, child: const Text('최대'));
}
```
'최대'는 액션이 아닌 종료 상태인데, `disabled FilledButton`으로 렌더링됨.
'티어업', '랭크업' 버튼과 같은 컴포넌트를 쓰므로 상태가 읽히지 않음.

**수정 방향**: '최대' 상태는 `AppBadge` 또는 비활성 chip으로 표시.

---

## 5. 패턴 D — 섹션 제목 스타일 불일치

적용 상태:
- D1: 완료. 제작 상세 모달의 `수량`, `재료` 섹션 제목에 `subsectionTitle`을 적용했다.
- D2: 완료. 양조 등록 다이얼로그의 `수량` 섹션 제목에 `subsectionTitle`을 적용했다.

### 5.1 제작 상세 vs 추출 상세

**제작 상세** `lib/features/workshop/crafting/presentation/widgets/workshop_material_craft_detail_dialog.dart:98, 111`
```dart
Text('수량'),          // 기본 bodyMedium 추정
Text('재료'),
```

**추출 상세** `lib/features/workshop/extraction/presentation/widgets/workshop_material_extraction_detail.dart:66`
```dart
final TextStyle subsectionTitleStyle = AppTextStyles.of(context).subsectionTitle;
Text('수량', style: subsectionTitleStyle),
Text('원소', style: subsectionTitleStyle),
Text('프로필', style: subsectionTitleStyle),
```

같은 역할의 섹션 제목이 화면마다 다른 텍스트 무게로 표시됨.

**수정 방향**: 제작 상세 모달의 `Text('수량')`, `Text('재료')`에 `AppTextStyles.of(context).subsectionTitle` 적용.

---

## 6. 패턴 E — 두 정보를 구분자(쉼표·중간점)로 연결

적용 상태:
- E1: 완료. 전투 보상 런 요약의 성공/실패 횟수를 별도 줄로 분리했다.
- E2: 완료. 양조 실험 결과의 등급과 점수를 별도 텍스트로 분리했다.
- E3: 완료. 마을 경제 카드의 골드/명성을 2줄 subtitle로 분리했다.
- E4: 완료. 작업실 자원 카드의 정수/신비를 2줄 subtitle로 분리했다.

### 6.1 전투 보상 런 요약

**`lib/features/battle/presentation/widgets/battle_claim_dialog.dart:57`**
```dart
'성공 ${claim.victoryCount}회, 실패 ${claim.wipeCount}회',
```
두 개의 독립 정보를 쉼표로 이어 한 `DetailLines` 항목으로 표시.
`DetailLines`를 이미 사용하므로 두 줄로 분리하면 위계가 명확해진다.

**수정 방향**: `'성공 N회'`, `'실패 N회'`를 별도 줄로 분리.

### 6.2 양조 실험 품질 라벨

**`lib/features/workshop/crafting/presentation/widgets/workshop_brew_experiment_result_body.dart:37`**
```dart
final String? qualityLabel = result.qualityScore == null
    ? null
    : '$gradeLabel · ${(result.qualityScore! * 100).round()}점';
```
등급(`gradeLabel`)과 점수(`N점`)를 중간점으로 연결.
등급은 시각적으로 강조될 정보이고, 점수는 보조 정보이므로 위계가 다르다.
현재 포션명 아래 별도 줄로는 분리되어 있으므로, 구조 문제보다는 한 줄 안에서 등급과 점수가 같은 무게로 묶인 소이슈다.

**수정 방향**: 등급을 `titleMedium` 또는 배지로 표시하고, 점수는 `bodySmall`의 보조 텍스트로 분리.

---

## 7. 패턴 F — 타이틀에 성격이 다른 두 정보 혼합

### 7.1 캐릭터 상세 시트 제목

**`lib/features/characters/presentation/widgets/character_detail_sheet.dart:52`**
```dart
title: '${character.name} ${item.typeLabel}',
```
이름(고유 식별자)과 타입 라벨(분류 정보)이 공백으로 이어짐.
타입은 제목보다 낮은 위계의 정보이므로 배지 또는 subtitle로 분리가 적합하다.

### 7.2 장비 선택 다이얼로그 제목

**`lib/features/characters/presentation/widgets/character_equipment_sheet.dart:40`**
```dart
title: '${character.name} ${slot.slotLabel}',
```
캐릭터 이름과 슬롯 라벨을 공백으로 연결. 위와 동일한 패턴.

---

## 8. 패턴 G — 시각 위계 없는 카드 본문 텍스트

적용 상태:
- G1: 완료. 캐릭터 카드의 배치/성장 보조 텍스트를 `bodySmall + onSurfaceVariant` 톤으로 낮췄다.

### 8.1 캐릭터 카드 보조 정보

**`lib/features/characters/presentation/widgets/character_card.dart:57, 59`**
```dart
Text(item.assignmentLabel),    // bodyMedium, 스타일 없음
Text(item.growthLabel),        // bodyMedium, 스타일 없음
```
제목(`character.name`)은 `subsectionTitle`, 우측 타입 라벨은 `bodySmall + onSurfaceVariant`로 처리되는데,
`assignmentLabel`과 `growthLabel`은 기본 `bodyMedium`이라 제목과 시각 무게 차이가 없다.
보조 정보이므로 `bodySmall` 또는 `onSurfaceVariant` 색상이 필요하다.

**수정 방향**: `bodySmall + onSurfaceVariant` 스타일 적용. 또한 `assignmentLabel`은 `'배치 상태: 대기'` 형식이므로 prefix 제거 후 badge로 전환 검토.

---

## 9. 패턴 H — Before/After 구조 소실

적용 상태:
- H1: 완료. 인챈트 미리보기의 인챈트/스탯 정보를 `현재 → 다음` 비교 행으로 분리했다.

### 9.1 인챈트 미리보기

**`lib/features/workshop/enchanting/presentation/widgets/workshop_enchant_preview_section.dart:42-45`**
```dart
AppBadge(label: preview!.currentEnchantLabel),   // 현재 인챈트
AppBadge(label: preview!.nextEnchantLabel),      // 다음 인챈트
AppBadge(label: preview!.currentStatLabel),      // 현재 스탯
AppBadge(label: preview!.nextStatLabel),         // 다음 스탯
```
`(현재 인챈트 / 다음 인챈트)`와 `(현재 스탯 / 다음 스탯)` 두 쌍이 있지만,
네 배지가 모두 동등한 `AppBadge`로 나열되어 before/after 구조가 평탄화됨.
`deltaStatLabel`은 별도 `dataEmphasis` 텍스트로 분리되어 있어 오히려 더 눈에 띔.

**수정 방향**: 인챈트 쌍과 스탯 쌍을 시각적으로 구분하거나, 현재 값을 보조 색상으로 낮추고 다음 값을 강조.

---

## 10. 패턴 D 추가 — 섹션 제목 스타일 불일치 (계속)

### 10.1 양조 등록 다이얼로그

**`lib/features/workshop/crafting/presentation/widgets/workshop_brew_recipe_book_tab.dart:120`**
```dart
Text('수량'),
```
같은 파일의 `WorkshopDiscoveredBrewDetailDialog` 안에서 섹션 제목 `Text('수량')`에 스타일 없음.
`WorkshopMaterialCraftDetailDialog`의 `Text('수량')`, `Text('재료')`(패턴 D1)와 동일한 이슈.

**수정 방향**: D1과 함께 `AppTextStyles.of(context).subsectionTitle` 적용.

---

## 11. 패턴 A 추가 — `_splitEquipmentLabel` 4번째 위치

### 11.1 장비 장착 헤더

**`lib/features/characters/presentation/widgets/character_equipment_header.dart:75-81`**
```dart
Iterable<String> _splitEquipmentLabel(String label) {
  return label.split('\n').first.split(' / ').where(...);
}
```
패턴 A3~A5와 동일한 `_splitEquipmentLabel` 함수가 `character_equipment_header.dart`에도 복사됨.
총 4곳(`town_equipment_sheet`, `character_equipment_section`, `character_combat_sections`, `character_equipment_header`)에 동일 패턴 존재.

---

## 12. 패턴 E 추가 — 쉼표 연결 (계속)

### 12.1 마을 경제 카드

**`lib/features/town/presentation/screens/town_screen.dart:39`**
```dart
InfoCard(
  title: '마을 경제',
  subtitle: '골드 $gold, 명성 $townInsight',
),
```
두 개의 독립적인 자원(골드 / 명성)을 쉼표로 연결해 subtitle에 표시.

### 12.2 작업실 자원 카드

**`lib/features/workshop/dashboard/presentation/screens/workshop_screen.dart:60`**
```dart
InfoCard(
  title: '작업실 자원',
  subtitle: '${dashboard.essenceLabel}, ${dashboard.arcaneDustLabel}',
),
```
E3와 동일한 패턴. 정수/신비 두 자원을 쉼표로 연결.

---

## 13. 요약 테이블

| # | 패턴 | 파일 | 라인 | 우선순위 |
|---|------|------|------|----------|
| A1 | 레이블 함수 `\n` 반환 | `equipment_stat_labels.dart` | 39 | 완료 |
| A2 | 레이블 함수 `\n` 반환 | `equipment_detail_labels.dart` | 12, 26 | 완료 |
| A3 | UI 파싱 우회 | `town_equipment_sheet.dart` | 195-200 | 완료 |
| A4 | UI 파싱 우회 | `character_equipment_section.dart` | 76-82 | 완료 |
| A5 | 전투 효과 라벨 UI 파싱 우회 | `character_combat_sections.dart` | 54-59 | 완료 |
| A6 | UI 파싱 우회 | `character_equipment_header.dart` | 75-81 | 완료 |
| A7 | 드롭 라벨 UI 파싱 우회 | `battle_stage_drop_list.dart` | 105-110 | 완료 |
| A8 | 스킬트리 라벨 UI 파싱 우회 | `skill_tree_node_detail_dialog.dart` | 84-89 | 완료 |
| A9 | UI 문자열 조작 | `character_assignment_section.dart` | 18 | 완료 |
| B1 | 경고 + 탭 혼재 | `workshop_craft_card.dart` | 61-79 | 완료 |
| B2 | 액션 + 정보 혼재 | `town_shop_sheet.dart` | 37-54 | 완료 |
| C1 | 상태를 버튼 라벨로 | `town_shop_sheet.dart` | 215 | 완료 |
| C2 | 상태를 disabled 버튼으로 | `character_growth_section.dart` | 95-96 | 완료 |
| D1 | 섹션 제목 스타일 없음 | `workshop_material_craft_detail_dialog.dart` | 98, 111 | 완료 |
| D2 | 섹션 제목 스타일 없음 | `workshop_brew_recipe_book_tab.dart` | 120 | 완료 |
| E1 | 쉼표 연결 두 정보 | `battle_claim_dialog.dart` | 57 | 완료 |
| E2 | 중간점 연결 두 정보 | `workshop_brew_experiment_result_body.dart` | 37 | 완료 |
| E3 | 쉼표 연결 두 정보 | `town_screen.dart` | 39 | 완료 |
| E4 | 쉼표 연결 두 정보 | `workshop_screen.dart` | 60 | 완료 |
| F1 | 제목에 분류 정보 혼합 | `character_detail_sheet.dart` | 52 | 낮음 (검토) |
| F2 | 제목에 분류 정보 혼합 | `character_equipment_sheet.dart` | 40 | 낮음 (검토) |
| G1 | 카드 보조 텍스트 스타일 없음 | `character_card.dart` | 57, 59 | 완료 |
| H1 | Before/After 구조 소실 | `workshop_enchant_preview_section.dart` | 42-45 | 완료 |

---

## 14. 권장 작업 순서

1. **A1~A4, A6 (장비 라벨 구조화)**: 장비 스탯/효과 라벨을 구조화하고, 장비 관련 UI 파싱 함수를 제거한다.
2. **B (레이아웃 영역 혼재)**: Workshop 큐 경고와 상점 갱신 버튼은 각각 body 배너와 footer로 이동.
3. **D (섹션 제목 스타일 통일)**: D1과 D2를 함께 처리. `subsectionTitle` 스타일 적용.
4. **G + C2 (캐릭터 성장 위계)**: `character_card.dart`의 보조 텍스트 스타일과 `character_growth_section.dart`의 최대 상태 표현을 함께 정리한다.
5. **H (Before/After 구조)**: 인챈트 미리보기 current/next 쌍 시각 분리.
6. **A5, A7~A8 (전투 효과/드롭/스킬트리 라벨 구조화)**: 장비 라벨 작업과 별도 단계로 처리한다.
7. **C1, E, F**: 독립적인 소규모 수정 또는 검토 항목으로 후순위 처리한다.
