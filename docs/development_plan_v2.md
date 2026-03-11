# Alchemist Hunter 방치형 전환 기획 v2

## 0) 문서 목적
- v2 확정안을 실제 구현 추적 문서로 사용한다.
- “무엇을”, “어디서”, “어떤 기준으로 완료 판단하는지”를 기록한다.

상태 표기:
- `[x]` 완료
- `[-]` 진행중/부분완료
- `[ ]` 미착수

## 1) 제품 방향 (확정)
- 운영(제조/판매) 중심 방치형
- 코어 루프: 재료 수급 -> 특성 추출/조합 -> 포션 제조 -> 판매/전투 투입 -> 성장
- 전투는 완전 자동(보조 루프)
- 스킬트리는 `마을 트리 / 작업실 트리`로 분리하고, 각 트리는 별도 재화로 강화
- 세션 목표: 초반 10~15분 -> 후반 3~5분 점검형
- 이세계 포탈은 시즌2 이관

## 2) 아키텍처/폴더 기준

### 2.1 현재 기준 폴더
- `lib/app`: 앱 엔트리/탭 구조
- `lib/features/*`: 기능(feature) 단위 폴더
- `lib/features/*/presentation`: 탭/기능 UI

### 2.2 feature-based 폴더 구조 규칙 (확정)
- [ ] `lib/features` 아래는 반드시 기능 단위로 분리
- [ ] 공통 `game` 단일 폴더 확장은 지양하고, 각 기능이 독립 구조를 가짐
- 권장 구조:
  - `lib/features/town/{domain,data,application,presentation}`
  - `lib/features/workshop/{domain,data,application,presentation}`
  - `lib/features/characters/{domain,data,application,presentation}`
  - `lib/features/battle/{domain,data,application,presentation}`
- 규칙:
  - `domain`: 엔티티/값객체/도메인 규칙
  - `data`: 저장소/DTO/더미/로컬DB 구현
  - `application`: 서비스/유스케이스/상태관리(provider/notifier)
  - `presentation`: 화면/widget/controller

### 2.3 완료 정의(공통)
- 코드 작성 + 최소 단위 테스트 추가 + 분석/테스트 통과 시 완료로 본다.
- UI 기능은 “버튼/입력/결과 반영” 3요소가 연결되면 1차 완료로 본다.

### 2.4 아키텍처/폴더 정리 실행안 (신규)
- [ ] 레이어 경계 강제
  - `presentation` -> `application`만 참조
  - `application` -> `domain`, `data(interface)` 참조
  - `data` -> `domain` 참조 가능, `presentation` 참조 금지
- [ ] 공통 모듈 최소화
  - `lib/core`: 라우팅, 공통 에러, 공통 유틸, 테마
  - `lib/shared`: 재사용 위젯/포맷터(게임 규칙 없음)
  - 게임 규칙은 반드시 각 feature `domain`에 둠
- [ ] 파일 명명 규칙
  - 엔티티: `*_entity.dart`
  - 값객체: `*_vo.dart`
  - 서비스/유스케이스: `*_service.dart`, `*_usecase.dart`
  - 상태관리: `*_provider.dart`, `*_notifier.dart`
  - 화면: `*_screen.dart`, 컴포넌트: `*_widget.dart`
- [ ] 의존성 역전 규칙
  - repository는 `domain`에 interface, 구현은 `data`에 배치
  - `application`은 interface에만 의존

### 2.5 폴더 마이그레이션 매핑 (신규)
- [x] 기존 `lib/features/game/*` 분해 이전
  - 연금/제조/인챈트/부화 관련 -> `lib/features/workshop/*`
  - 상점/판매/장비제작/용병고용 관련 -> `lib/features/town/*`
  - 전투/드롭/스테이지 관련 -> `lib/features/battle/*`
  - 캐릭터 성장/편성/티어승급 관련 -> `lib/features/characters/*`
- [x] 기존 `lib/screens/*` 분해 이전
  - 탭 루트 화면은 각 feature `presentation/screens`로 이동
  - 공통 위젯만 `lib/shared/widgets`로 이동
- [ ] 테스트 구조 동기화
  - `test/features/<feature>/<layer>/...` 구조로 재배치
  - 기존 `test/services/*`는 feature 하위로 이동
- [ ] 완료 기준
  - `lib/features/game` 잔존 코드 0
  - 신규 코드가 `lib/features/*/presentation`에만 추가됨
  - `flutter analyze` 경고 없이 통과

## 3) 시스템별 상세 상태

### 3.0 마을/작업실 역할 분리 (신규 확정)
- [-] 마을(Town): 기본 스탯 장비 제작 전담
  - 장비는 인챈트 전 기본 옵션만 가짐
  - 장비 등급/기본 스탯/제작 비용/제작 시간 관리
  - 상점 기능(재료 구매/포션 판매) 포함
  - 용병 고용/해고/대기열 관리 포함
- [-] 작업실(Workshop): 포션 인챈트 전담
  - `추출`: 재료 trait 분석/추출
  - `제조`: 포션 제작/제작 큐 운영
  - `인챈트`: 장비에 포션 주입해 옵션 강화/부여
  - `부화`: 호문쿨루스 생성/성장 시작
- 완료 기준:
  - 마을/작업실은 별개 화면/별개 상태 컨텍스트로 유지(기능 통합 금지)
  - 장비 생성은 마을 UI에서만 가능
  - 상점 구매/판매는 마을 UI에서만 가능
  - 용병 고용/해고는 마을 UI에서만 가능
  - 추출/제조/인챈트/부화는 작업실 UI에서만 가능
  - 인챈트 후 장비 상세에서 강화 수치/부가 효과 확인 가능

### 3.0.1 마을/작업실 재화 분리 규칙 (신규 확정)
- [ ] 재화 타입 분리
  - 마을 재화: `Gold`(상점 구매/장비 제작/용병 고용)
  - 작업실 재화: `Essence`(추출/제조/인챈트/부화)
- [ ] 소비 규칙
  - 마을 기능은 `Gold`만 소비
  - 작업실 기능은 `Essence`만 소비
  - 교차 소비 금지(`Gold`로 작업실 결제 불가, `Essence`로 마을 결제 불가)
- [ ] 획득 규칙
  - `Gold`: 판매/전투/오프라인 수익 중심
  - `Essence`: 추출 부산물/전투 특수 드롭/작업실 반복 보상 중심
- [ ] 완료 기준
  - 화면 상단 재화 노출이 마을/작업실에서 서로 다르게 표시
  - 결제 부족 메시지가 재화 타입 기준으로 정확히 출력

### 3.1 제조/특성 시스템
- [x] 단일/복합 특성 엔티티 정의
  - 파일: `lib/features/workshop/domain/models.dart`
  - 검증: 복합 trait의 components 구조 확인
- [x] 복합 -> 단일 분해 로직
  - 파일: `lib/features/workshop/application/services/alchemy_service.dart`
  - 테스트: `test/services/alchemy_service_test.dart`
- [x] 단일 -> 복합 합성 로직
  - 파일: `lib/features/workshop/application/services/alchemy_service.dart`
  - 테스트: `test/services/alchemy_service_test.dart`
- [x] 추출 프로필(전체/선택) 계산
  - 파일: `lib/features/workshop/application/services/alchemy_service.dart`
- [-] 추출 결과를 포션 제조 입력 재고와 연결
- [x] 포션 품질 점수 계산(목표 trait 비율 매칭)
  - 필요 작업:
    - `PotionQualityCalculator` 추가
    - 품질 등급(S/A/B/C) 정의
    - 품질에 따른 판매가/전투효과 multiplier 연결
    - 인챈트 강화량 multiplier 연결
- [x] 포션 결과 판정 규칙(신규 확정)
  - 종류(Type): 제조에 사용한 trait 조합으로 결정
  - 품질(Quality): 사용한 trait의 비율 매칭도(score)로 결정
  - 동일 trait 조합이라도 비율 우세값에 따라 타입이 분기될 수 있음
    - 예: `A+B` 조합에서 `A > B`이면 Potion X, `B > A`이면 Potion Y
    - 동률(`A == B`)은 기본 타입(중립 결과) 또는 별도 Branch Rule로 명시
  - 판정 순서:
    1) 조합 매칭으로 포션 타입 결정
    2) 조합 내 Branch Rule(우세 trait/비율 조건) 적용
    3) 해당 타입 기준 목표 비율과 실제 비율 비교
    4) score 구간에 따라 품질(S/A/B/C) 산출
  - 분기 우선순위: `정확 매칭(>)` -> `포괄 매칭(>=)` -> `기본 타입`
  - 동일 재료량이어도 조합/비율 차이로 타입/품질이 달라질 수 있음
- [x] 포션 판정 데이터 스키마
  - `PotionRecipeRule`: requiredTraits, optionalTraits, forbiddenTraits, resultType
  - `PotionRecipeBranchRule`: dominantTrait, ratioCondition, branchedResultType
  - `PotionQualityRule`: targetRatio, tolerance, scoreCurve, qualityThresholds
  - 다중 매칭 충돌 시 최고 score recipe 우선

### 3.2 제작 큐 시스템
- [x] 큐 데이터 모델(반복, 재시도, eta, 상태)
  - 파일: `lib/features/workshop/domain/models.dart`
- [x] 큐 처리 tick 로직
  - 파일: `lib/features/workshop/application/services/craft_queue_service.dart`
  - 테스트: `test/services/craft_queue_service_test.dart`
- [x] UI 연결(큐 등록/틱 처리/상태 표시)
  - 파일: `lib/features/workshop/presentation/screens/workshop_screen.dart`
- [x] 큐 처리 결과물(포션 완제품) 인벤토리 반영
- [ ] 큐 슬롯 제한(초기 2칸, 확장 가능) 및 다이아 확장 로직

### 3.3 재료 수급 시스템

#### 3.3.1 상점
- [x] 2상점 구조(일반/촉매)
  - 파일: `lib/features/workshop/data/dummy_data.dart`, `lib/features/town/application/town_providers.dart`
- [x] 강제 갱신 누적 비용/주기초기화
  - 파일: `lib/features/town/application/services/economy_service.dart`
  - 테스트: `test/services/economy_service_test.dart`
- [x] UI 강제 갱신 버튼 연결
  - 파일: `lib/features/town/presentation/screens/town_screen.dart`
- [x] 상점 기능을 마을 화면으로 이전(구매/판매 통합)
- [x] 자동 갱신 스케줄러(실시간 주기 만료 시 자동 리롤)
- [ ] 상점별 구매 제한/품절 재입고 정책

#### 3.3.2 전투 드롭
- [x] normal/special drop 분리 테이블
  - 파일: `lib/features/workshop/domain/models.dart`, `lib/features/workshop/data/dummy_data.dart`
- [x] 자동전투 결과 loot 반영
  - 파일: `lib/features/battle/application/services/battle_service.dart`, `lib/features/battle/application/battle_providers.dart`
- [-] 특수 재료 기반 해금 연결
  - 필요 작업:
    - `unlockFlags` 업데이트 조건 추가
    - 해금 UI(잠김/개방) 상태 표시

### 3.4 전투 시스템
- [x] 완전 자동 전투 진입/결과 반영 흐름
  - 파일: `lib/features/battle/presentation/screens/dungeon_screen.dart`, `lib/features/battle/application/battle_providers.dart`
- [x] 실패 경미 페널티(골드 감소) 적용
- [ ] 스테이지별 적 세트/권장 전투력/승률 곡선 반영
- [ ] 포션 loadout 소모 규칙 반영
- [ ] 전투 로그 상세(턴, 치명, 회피, 드롭 근거) 출력

### 3.5 저장/오프라인 시스템
- [x] 오프라인 계산 유틸 초안
  - 파일: `lib/services/calculate_offline.dart`, `lib/utils/apply_offline_time.dart`
- [ ] 영속 저장소(Hive/Isar) 도입
- [ ] 앱 종료/복귀 시 큐/상점/인벤토리/진행 복원
- [ ] 오프라인 처리 파이프라인 통합
  - 수급 + 자동 제조 + 자동 판매 순차 처리
  - 상한 시간(8~12h) 정책 적용

### 3.6 장비 제작/인챈트 시스템 (신규)
- [ ] 장비 도메인 모델 추가
  - `EquipmentBase`: 기본 스탯, 등급, 슬롯
  - `EquipmentEnchant`: 주입 포션 ID, 강화 배율, 추가 효과
  - `EquipmentInstance`: 실제 보유 장비(기본+인챈트 상태)
- [ ] 마을 제작 서비스
  - 입력: 장비 블루프린트, 재료/골드
  - 출력: 인챈트 전 장비 인스턴스
- [ ] 작업실 인챈트 서비스
  - 입력: 장비 인스턴스, 포션
  - 처리: 포션 품질/trait 매칭으로 강화 수치 계산
  - 출력: 인챈트 적용 장비
- [ ] 인챈트 규칙
  - 기본 스탯 증폭(공격/방어/체력 등)
  - 조건부 부가효과 부여(예: 치명 확률, 재생, 드롭률 보정)
  - 실패 시 경미 페널티(포션 소모, 장비 보존)

### 3.7 용병 고용 시스템 (신규)
- [ ] 용병 도메인 모델
  - `MercenaryTemplate`: 기본 직업/성장 계수/고용 비용
  - `MercenaryInstance`: 실제 보유 용병(레벨, 장비, 상태)
- [ ] 마을 고용 서비스
  - 고용 후보 생성/갱신
  - 골드 소모 후 고용
  - 해고 시 보상 규칙 정의
- [ ] 파티 편성 연동
  - 고용된 용병만 전투/작업 투입 가능
  - 용병 상태(대기/배치/전투중) 관리

### 3.8 캐릭터 체계: 용병 + 호문쿨루스 (신규 확정)
- [ ] 캐릭터 타입을 2종으로 고정
  - `Mercenary`: 마을에서 고용하는 인력
  - `Homunculus`: 제조/인챈트/전투 시너지용 성장체
- [ ] 공통 캐릭터 인터페이스
  - `CharacterBase`: id, name, level, stats, equipmentSlots, status
  - 타입별 추가 필드:
    - `Mercenary`: hireCost, role, contractState
    - `Homunculus`: growthStage, affinityTraits, synthesisHistory
- [ ] 공통 성장 축(레벨/랭크/티어) 도입
  - `Level`: 경험치 획득 시 자동 상승
  - `Rank`: 수동 승급, 승급 시 레벨 1로 초기화
  - `Tier`: 해당 티어 최대 랭크 달성 시 승급 가능
- [ ] 랭크별 최대 레벨 규칙
  - Rank 1 max level = 5
  - Rank 2 max level = 10
  - 일반식: `Rank N max level = N * 5`
- [ ] 랭크업 규칙
  - 현재 랭크 최대 레벨 도달 시에만 수동 랭크업 버튼 활성화
  - 랭크업 시 레벨은 1로 변경, 랭크 보정 스탯/보너스 적용
- [ ] 티어업 규칙
  - 현재 티어의 최대 랭크 달성 시 수동 티어업 가능
  - 티어업 시 랭크/레벨 초기화 여부는 타입별 정책으로 분리(초기 MVP는 둘 다 초기화)
  - 티어업 시 타입/티어별 승급 재료 필요(용병/호문쿨루스 재료 풀 분리)
  - 예: `MercenaryTierMaterial[Tier]`, `HomunculusTierMaterial[Tier]`
- [ ] 용병 티어 정의(5단계 고정)
  - 1: `Rookie`
  - 2: `Veteran`
  - 3: `Elite`
  - 4: `Champion`
  - 5: `Legend`
- [ ] 호문쿨루스 티어 정의(4단계 고정)
  - 1: `Nigredo (흑화)`
  - 2: `Albedo (백화)`
  - 3: `Citrinitas (황화)`
  - 4: `Rubedo (적화)`
- [ ] 편성 규칙
  - 전투 파티에 용병/호문쿨루스 혼합 편성 가능
  - 작업실 보조 슬롯은 호문쿨루스 우선 배치(보너스 계수)
- [ ] 성장 규칙
  - 용병: 전투 경험치 기반 레벨 성장 + 랭크/티어 승급
  - 호문쿨루스: 전투 경험치 기반 레벨 성장 + 랭크/티어 승급
  - 레벨 경험치 획득 소스는 전투 결과로 통일(작업실 활동은 레벨 XP 미지급)
- [ ] 호문쿨루스 부화 규칙
  - 부화는 작업실에서만 수행
  - 부화 재료/시간/촉매 규칙 정의
  - 부화 결과 희귀도/초기 특성 풀 정의

### 3.9 이원화 스킬트리 해금 시스템 (신규 확정)
- [ ] 스킬트리 도메인 모델 분리
  - `TownSkillNode`: 마을 전용 노드(상점/판매/장비/용병 계열)
  - `WorkshopSkillNode`: 작업실 전용 노드(추출/제조/인챈트/부화 계열)
  - `TownSkillTreeState`: unlockedNodes, nodeLevels, availablePoints, spentPoints
  - `WorkshopSkillTreeState`: unlockedNodes, nodeLevels, availablePoints, spentPoints
- [ ] 스킬트리 전용 재화 분리
  - 마을 트리 강화 재화: `TownInsight`
  - 작업실 트리 강화 재화: `ArcaneDust`
  - 교차 강화 금지(`TownInsight`로 작업실 트리 강화 불가, `ArcaneDust`로 마을 트리 강화 불가)
- [ ] 업그레이드 복합 비용 규칙
  - 마을 업그레이드 비용은 `TownInsight + Gold` 복합 요구 가능
  - 작업실 업그레이드 비용은 `ArcaneDust + 추출 원소(Element)` 복합 요구 가능
  - 복합 비용은 AND 조건(모든 비용 충족 시만 강화 가능)
- [ ] 해금/강화 규칙
  - 노드 해금은 선행 노드 + 영역별 진행 조건으로 제어
  - 마을 트리 조건 예: 누적 판매액, 용병 고용 수, 장비 제작 횟수
  - 작업실 트리 조건 예: 추출 횟수, 포션 제작 횟수, 인챈트 성공 횟수
  - 효과는 전역 수치에 반영되되, 노드 소속 영역 우선 적용
- [ ] 적용 계층 규칙
  - 계산 순서: `기본값 -> 장비/포션/캐릭터 보정 -> 마을 트리 보정 -> 작업실 트리 보정`
  - 퍼센트/고정값 중복 시 누적 방식(합연산/곱연산) 명시
- [ ] 리스펙(초기화) 정책
  - 트리별 개별 리스펙 지원(마을/작업실 독립)
  - 각 리스펙은 해당 트리 전용 재화 또는 전용 티켓으로만 실행
- [ ] 완료 기준
  - 마을 트리/작업실 트리 각각 최소 1개 노드 효과가 실제 수치에 반영
  - 해금 불가 노드는 트리별 잠금/조건 툴팁으로 원인 표시

## 4) UI/UX 상세 상태

### 4.1 탭 구조
- [x] 하단 탭을 `마을 / 작업실 / 캐릭터 / 전투`로 개편
  - 기존 4탭(`Characters / Weapons / Dungeons / Pets`)은 폐기 대상
  - 파일 영향 범위: `lib/app/app.dart`, `lib/features/*/presentation/*`
  - 완료 기준:
    - 탭 라벨/아이콘/라우팅이 4개 새 탭 기준으로 동작
    - 기존 Weapons 기능은 작업실로, Dungeons 기능은 전투로 이전

### 4.1.1 인벤토리 공통 표현 규칙 (신규 확정)
- [ ] 아이템 목록은 종류 단위 스택(아이콘+이름+총수량)으로 표시
- [ ] 스택 선택 시 상세 뷰에서 인스턴스 단위 정보 표시
- [ ] 상세 뷰 공통 필드: 품질, 인챈트 상태, 옵션/강화값, 잠금/즐겨찾기 상태
- [ ] 적용 범위: 마을 상점 판매 선택, 작업실 재료/포션/장비 선택, 캐릭터 장비 장착 화면

### 4.2 운영 화면(Weapons)
- [x] 상점 구매
- [x] 강제 갱신
- [x] 큐 등록/처리
- [x] 로그 표시
- [ ] 특성 분석 패널(재료 선택 -> 분석 결과 표시)
- [ ] 추출 패널(프로필/선택 추출 UI)
- [ ] 판매 패널(포션 묶음 판매, 예상 수익 미리보기)
- [ ] 마을 화면으로 장비 제작 기능 이전
- [x] 마을 화면으로 상점(구매/판매) 기능 이전
- [ ] 마을 화면으로 용병 고용 기능 이전
- [ ] 작업실 화면에 장비 인챈트 기능 배치
- [-] 기존 `Weapons` 단일 화면 사용 중단(읽기 전용 또는 제거)

### 4.2.1 기존 UI 마이그레이션 체크리스트 (신규)
- [x] 기존 `lib/screens/weapons_screen.dart` 기능 분해
  - 상점/판매/장비/용병 기능 -> `마을` 화면으로 이전
  - 추출/제조/인챈트/부화 기능 -> `작업실` 화면으로 이전
- [x] 기존 `lib/features/battle/presentation/screens/dungeon_screen.dart`를 `전투` 탭 구조에 맞춰 라우팅/상태 정리
- [ ] 기존 `Characters/Pets` 화면 요소를 `캐릭터(용병/호문쿨루스)` 화면으로 통합
- [-] 구 UI 진입 경로 차단
  - 하단 탭/딥링크/내부 버튼에서 폐기 화면 접근 불가
- [ ] UI 상태 관리 이전
  - 화면별 provider/notifier 범위를 `Town/Workshop/Character/Battle`로 분리
- [ ] 완료 기준
  - 신규 4탭만으로 주요 플레이 루프(구매/제조/전투/성장) 수행 가능
  - 구 UI 의존 코드 제거 후 빌드/테스트 통과

### 4.3 마을(Town) 화면 책임 (신규)
- [x] 상점 구매(일반/촉매)
- [x] 포션 판매(묶음 판매 + 예상 수익)
- [ ] 기본 장비 제작
- [ ] 용병 고용/해고
- [ ] 보유 용병 목록 및 대기열 표시
- [ ] 호문쿨루스 관리 진입(생성/강화 화면 링크)
- [ ] 스킬트리 진입/노드 강화 화면
  - 마을 트리 전용 노드 목록/연결선 표시
  - 노드 상태(잠김/해금가능/강화가능/최대) 표시
  - 노드 선택 시 효과 미리보기(현재 -> 다음 레벨)
  - 강화 재화: `TownInsight` + 일부 노드 `Gold` 추가 요구
- [-] 마을 전용 재화 HUD
  - `Gold` 잔액/증감 로그 표시
  - `Essence`는 참조값(읽기 전용) 또는 비노출

### 4.4 전투 화면(Dungeons)
- [x] 스테이지 실행 버튼
- [ ] 잠금 상태 시 진입 제한/해금 조건 툴팁
- [ ] 전투 결과 상세 모달

### 4.5 캐릭터(Character) 화면 책임 (신규)
- [ ] 탭을 `용병 / 호문쿨루스` 서브탭으로 분리
- [ ] 용병 목록: 역할, 장비, 배치 상태, 계약 상태 표시
- [ ] 호문쿨루스 목록: 성장 단계, 친화 특성, 보조 효과 표시
- [ ] 캐릭터 상세에서 전투/작업실 배치 전환 가능
- [ ] 성장 패널
  - 현재 `Level / Rank / Tier` 표시
  - 랭크업 가능 조건 충족 시 수동 랭크업 버튼 표시
  - 티어업 가능 조건 충족 시 수동 티어업 버튼 표시
  - 티어업 재료 요구량/보유량 표시(타입/티어별)
  - 다음 목표(다음 랭크 최대 레벨/티어 승급 필요 조건) 표시

### 4.6 작업실(Workshop) 화면 책임 (신규 확정)
- [ ] 작업실 스킬트리 진입/노드 강화 화면
  - 작업실 트리 전용 노드 목록/연결선 표시
  - 노드 상태(잠김/해금가능/강화가능/최대) 표시
  - 노드 선택 시 효과 미리보기(현재 -> 다음 레벨)
  - 강화 재화: `ArcaneDust` + 일부 노드 `추출 원소(Element)` 추가 요구
- [-] 작업실 전용 재화 HUD
  - `Essence` 잔액/시간당 변화량 표시
  - `Gold`는 참조값(읽기 전용) 또는 비노출
- [-] 보유 자원 조회 패널
  - 보유 아이템(재료/포션/장비/촉매)을 종류별 스택으로 묶어 수량 중심 표시
  - 스택 셀 클릭 시 상세 뷰(드릴다운) 오픈
  - 상세 뷰에서 개별 인스턴스 정보 표시: 품질, 인챈트, 옵션 롤, 획득 시각
  - 보유 특성(단일/복합) 목록, potency, 출처 표시
  - 정렬(수량/희귀도/최근 획득) 및 검색 지원
- [ ] 추출 패널
  - 재료 선택 -> 분석 결과 -> 추출 프로필 선택 -> 추출 실행
- [x] 제조 패널
  - 포션 선택 -> 목표 trait 비율 확인 -> 큐 등록(반복/재시도)
- [ ] 인챈트 패널
  - 장비 선택 -> 포션 선택 -> 강화 결과 미리보기 -> 적용
- [ ] 부화 패널(호문쿨루스)
  - 부화식 선택 -> 재료 투입 -> 시간 진행 -> 결과 수령
- [ ] 공통 완료 기준
  - 작업실 진입 시 보유 아이템/특성 현황이 즉시 보임
  - 추출/제조/인챈트/부화 각 패널에서 동일한 보유 데이터 소스 사용
  - 목록 뷰는 종류 단위 스택, 상세 뷰는 인스턴스 단위 데이터로 일관 유지

## 5) 데이터/밸런스 상세 항목
- [x] 더미 콘텐츠 수량 충족
  - 던전 5, 재료 30, 포션 15, trait 18, enemy set 20
- [ ] 실제 밸런스 테이블 분리(JSON 또는 scriptable data)
  - 포션 타입 판정표(`PotionRecipeRule`) 포함
  - 포션 품질 판정표(`PotionQualityRule`) 포함
  - 마을 스킬트리 노드 테이블(`TownSkillNodeTable`) 포함
  - 작업실 스킬트리 노드 테이블(`WorkshopSkillNodeTable`) 포함
  - 티어 승급 재료 테이블(`TierPromotionMaterialTable`: 타입/티어별 요구 재료) 포함
  - 스킬 업그레이드 비용 테이블(`SkillUpgradeCostTable`: 단일/복합 비용, AND 조건) 포함
  - 재화 정의 테이블(`CurrencyTable`: Gold/Essence/TownInsight/ArcaneDust/Element 소스/싱크/상한) 포함
- [ ] 가격/드롭/제작시간 곡선 정의 문서 추가
- [ ] 후반 점검형 전이 지표 설계
  - 목표: 평균 접속 간격, 접속당 처리 액션 수, 큐 대기시간

## 6) 테스트/검증 상세

### 6.1 완료된 테스트
- [x] Alchemy 분해/합성
- [x] 상점 강제갱신 비용 증가
- [x] 제작 큐 상태 전이
- [x] 탭 렌더 위젯 테스트

### 6.2 추가 필요 테스트
- [ ] 품질 점수 계산 경계값 테스트
- [ ] 포션 타입 판정 테스트(조합별 결과 type 검증)
- [ ] 포션 판정 충돌 테스트(다중 recipe 후보 우선순위 검증)
- [ ] 해금 조건 판정 테스트(특수 재료 임계치)
- [ ] 오프라인 통합 테스트(8h cap 포함)
- [ ] 자동 갱신 주기 경계(정각/주기 직전) 테스트
- [ ] 전투 특수 드롭 보장 시나리오 테스트
- [ ] 레벨업 자동 상승 테스트(경험치 누적 경계값)
- [ ] 랭크별 최대 레벨 캡 테스트(1랭크 5, 2랭크 10, N랭크 N*5)
- [ ] 랭크업 수동 전환 테스트(최대 레벨 도달 전/후 버튼 상태)
- [ ] 랭크업 시 레벨 초기화 테스트(레벨 1로 리셋)
- [ ] 티어업 조건 테스트(해당 티어 최대 랭크 도달)
- [ ] 티어업 재료 검증 테스트(타입/티어별 요구 재료 충족 여부)
- [ ] 전투 외 활동 XP 미지급 테스트(작업실 행동 시 레벨 XP 증가 없음)
- [ ] 용병/호문쿨루스 티어 테이블 매핑 테스트
- [ ] 마을 스킬트리 노드 선행조건/잠금 해제 테스트
- [ ] 작업실 스킬트리 노드 선행조건/잠금 해제 테스트
- [ ] 스킬트리 효과 적용 순서 테스트(장비/포션/캐릭터 대비, 마을->작업실 순)
- [ ] 트리별 리스펙 상태 롤백/재계산 일관성 테스트
- [ ] 마을/작업실 재화 분리 테스트(교차 결제 차단)
- [ ] 스킬트리 재화 분리 테스트(TownInsight/ArcaneDust 교차 강화 차단)
- [ ] 복합 비용 결제 테스트(TownInsight+Gold, ArcaneDust+Element)
- [ ] 재화 부족 오류 메시지 테스트(Gold/Essence/TownInsight/ArcaneDust/Element 구분)

## 7) 마일스톤 기준 재정리

### M1 기반 구축 (완료)
- [x] 앱 엔트리/탭 골격 통합
- [x] 핵심 도메인 모델/서비스 초안
- [x] 기본 UI 바인딩 + 기초 테스트

### M2 운영 코어 루프 (완료)
- [x] 제조 품질 점수 계산 + 완제품 인벤토리 반영
- [x] 포션 타입 판정(조합/비율 분기) 실동작
- [x] 마을/작업실 분리 화면 기준 기능 이전
- [x] 기존 UI 마이그레이션(Weapons 분해, 구 화면 진입 경로 차단)
  - [x] 탭 기준 구 진입 경로 차단(하단 탭에서 Weapons 제거)
  - [x] `weapons_screen` 제거 및 기능 이전
- [x] 아키텍처/폴더 마이그레이션 1차(`features/game` 분해 이전)
  - [x] `town_screen`/`workshop_screen` 신설
  - [x] `features/game`를 `town/workshop/battle/characters`로 실제 이동
- [x] 상점 자동 갱신 스케줄러

### M3 캐릭터 성장/해금 루프 (진행중)
- [x] 용병/호문쿨루스 공통 성장축(Level/Rank/Tier) 적용
- [x] 전투 기반 XP 성장 + 랭크업/티어업 플로우
- [x] 티어 승급 재료(타입/티어별) 소모 규칙 적용
- [-] 특수 재료 기반 콘텐츠 해금 UI(잠김/조건 표시)

### M4 이원화 스킬트리/재화 체계 (미착수)
- [ ] 마을 스킬트리(Town) 구현: TownInsight + Gold 복합 비용
- [ ] 작업실 스킬트리(Workshop) 구현: ArcaneDust + Element 복합 비용
- [ ] 스킬트리 교차 강화 차단 + 트리별 리스펙 정책 반영
- [ ] 재화 HUD/부족 안내/결제 검증 UX 정리

### M5 저장/오프라인 통합 (미착수)
- [ ] 로컬 저장소(Hive/Isar) 도입
- [ ] 앱 복귀 시 상태 복원(큐/상점/인벤토리/진행)
- [ ] 오프라인 처리 파이프라인(수급->제조->판매, cap 적용)
- [ ] 오프라인 포함 통합 테스트 세트 구축

### M6 밸런스/폴리시/출시준비 (미착수)
- [ ] 밸런스 테이블 외부화(JSON/scriptable)
- [ ] 전투 상세 로그/리포트 + 지표 수집
- [ ] 경제 인플레이션/병목/이탈 지표 튜닝
- [ ] 편의성 과금 훅(슬롯 확장/가속) 최소 연동

## 8) 즉시 다음 작업(실행 순서)
1. `M3 진행: 특수 재료 기반 해금 UI(잠금/조건 표기) 완성`
2. `M3 진행: 캐릭터 성장 수치 밸런스(경험치 곡선/랭크 캡) 조정`
3. `M4 준비: 마을/작업실 스킬트리 노드 데이터 스키마 확정`
4. `M4 착수: 이원화 스킬트리 + 복합 비용 결제`
5. `M5 준비: 로컬 저장소 스키마/마이그레이션 설계`
