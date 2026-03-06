# IdleGuildMaster Reference Snapshot

본 문서는 IdleGuildMaster에서 반복 조회한 공식 API 응답을 바탕으로 구성 요소를 요약한 자료입니다. 게임 설계 참고용으로 활용하세요.

## 1. 진행 구조

### 던전 (D1~D11)
- **선형 해금**: 각 던전을 100회 이상 클리어하면 다음 던전이 개방됩니다.
- **어둠(Darkness) 조건**: 맵마다 고정/증가형 어둠 값이 존재하며, 특정 이벤트(예: D3에서 위습 200마리 연속 처치) 수행 시 보상 획득.
- **특수 규칙 예시**
  - D3 Eternal Battlefield: 어둠 20 고정, 위습 200킬 시 Orb of Ectoplasm.
  - D6 Frostbite Peaks: 이벤트 발생 시 어둠 약 50.
  - D8 The Southern Grove: R6 에픽 레이드 클리어 필요, 어둠 15.
  - D10 Hidden City of Larox: 어둠 8 고정.

### 레이드 (R1~R12)
- **해금 조건**: 대부분 “해당 던전 150회 이상” + 에픽/노멀 구분. 일부는 스탯 요구(예: R2 Divine Archeology → 체질 총합 200 이상)나 장비 조건(R5에서 Skeleton Key 착용 시 보스 교체) 존재.
- **진행 특성**
  - R6 The Dreadful Ascent: 진행도 저장형.
  - R7 The Lost Expedition: 어둠 100 고정.
  - R10~R12: 8~14인 편성, R9 에픽 클리어 필수, 고정 어둠/부활/랜덤 요소 등 고난도 규칙 적용.

## 2. 몬스터 & 아이템 생태계

### 몬스터 데이터
- 각 몬스터는 HP/스탯/공격 타입/스킬/드롭 테이블을 명시.
- 예: `Wolf` → HP 60, EXP 12, Beast Pelt 70%, Werewolf Fang 0.2%, Wild Egg 0.1%.

### 제작 시스템
- 드롭 재료로 장비/액세서리 제작 및 업그레이드 가능.
- 예시 조합:
  - **Wooden Buckler** = Wood ×6.
  - **Tusk Necklace** = Boar Tusk ×4 + Plant Fiber ×1 → **Infused Necklace**(추가: Living Sap).
  - **Cottontail Jacket** = Cottontail Fur ×4 + Leather ×10 → **Sage Jacket**(추가: Infusion of Wisdom).
  - **Fullmoon Dagger** = Wood ×6 + Werewolf Fang ×1 (CON+5/DEX+5/Lifesteal+15%).
- 제작 정보에 중요도·효율 지표가 포함되어 있어 우선순위 판단에 활용 가능.

## 3. 클래스 & 특성

### 클래스 트리
- Footman 계열 예:
  `Footman → Warrior → Knight → Holy Knight → Paladin → Templar → Inquisitor → Justiciar → Angel of War`
- 각 티어는 고유 액티브·패시브 스킬을 보유하며, 기절·도발·어둠 감소 등 상태 제어 능력이 발전.

### Adventurer Traits
- **기본**: Brute/Feral/Bookworm (능력치 ±10%).
- **고급**: Troll Blood(턴당 회복), Dragon Blood(피해감소 증가), Blessed(어둠 감소 8), Alert(선제 공격), Mindful(상태 면역 +10%), Nimble(회피 +8%) 등.
- **특수**: Cursed(턴당 HP 감소 대신 Lifesteal +15%), Nocturnal(어둠 수치 기반 피해 증가) 등. 일부는 상점 한정 버전(+15% 보정).

### 경험치 표
- 레벨 1~45까지 필요 경험치 및 누적 값 제공. (예: Lv40까지 누적 EXP 3,464,320)

## 4. 펫 시스템

### 펫 계열 및 알
- 6종 이상의 알 분류:
  - Wild Egg (Rat/Squirrel/Red Wolf): Bloodthirsty + Vigilant 기반.
  - Wooden Egg (Floating Seed/Holy Tree): 힐·재생.
  - Avian Egg (Dove/Owl/Eagle): Threat 특화.
  - Esoteric Egg (Floating Eye 등): Drop Rate·EXP 시너지.
  - Construct, Reptile, Insect Egg 등으로 확장.
- 펫마다 보유 가능한 특성 수(2~4)가 다름.

### 펫 특성 요약
| 이름 | 효과 | 레벨 80 기준 |
| --- | --- | --- |
| Bloodthirsty | Lifesteal 0.15%/레벨 | 12% |
| Bright | 어둠 감소 0.5/레벨 (+1) | 41 |
| Curious | 2회 드롭 굴림 확률 0.3%/레벨 | 24% |
| Fighter | {(0.5Lv+1)×0.9~1.1} 피해 | 36~45 |
| Teacher | EXP +0.4%/레벨 | 32% |

### 펫 경험치
- 레벨 1~120 누적 경험치 제공 (Lv50 = 22,216, Lv100 = 1,336,488, Lv120 = 6,833,961).

## 5. 설계 인사이트
1. **해금 구조**: 던전 반복 횟수, 레이드 조건, 어둠 시스템으로 장기 목표 제공.
2. **경제 루프**: 재료 → 제작 → 상위 업그레이드 → 효율 지표로 최적화 유도.
3. **조합 다양성**: 클래스·특성·펫 특성 조합으로 메타 변주.
4. **커뮤니티 요구**: 공식 Reddit에서 버그·정보 공유 필요성 및 Discord 요청 다수.

> 최신 데이터는 `https://tt.console.idleguildmaster.info/api` 하위 엔드포인트(map/class/pet 등)에 `token: ""`를 POST하여 재수집할 수 있습니다.
