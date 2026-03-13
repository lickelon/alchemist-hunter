# 프로젝트 구조 원칙

## 1. 문서 목적
- 이 문서는 앞으로의 폴더 구조 기준과 각 레이어의 책임을 고정한다.
- 새 기능 추가나 리팩토링 시 "어디에 둘지"를 다시 토론하지 않도록 한다.
- 구조 정리는 기능 구현의 부산물이 아니라, 명확한 책임 분리를 위한 수단으로만 수행한다.
- 구조 관련 상세 기준의 source of truth로 사용한다.

## 2. 최상위 구조 원칙
- 구조는 `feature-first`를 기본으로 한다.
- 공통 코드보다 기능 소유권을 우선한다.
- 게임 규칙은 feature 내부에 둔다.
- 전역 상태/앱 부트스트랩만 `app` 또는 `core`에 둔다.

### 기준 구조
```text
lib/
  app/
  core/
  features/
  common/
```

### 최상위 폴더 책임
- `app`
  - 앱 시작점, 탭 셸, 라우팅, 앱 레벨 composition
- `core`
  - 전역 세션 저장소, 앱 공통 상태, feature 비의존 유틸
- `features`
  - 실제 제품 기능
- `common`
  - 순수 재사용 위젯/테마/스타일

## 3. Feature 내부 구조 원칙
- 각 feature는 가능하면 아래 구조를 따른다.
- 빈 폴더를 미리 만들지는 않는다.
- 필요한 레이어만 만든다.

```text
features/<feature>/
  presentation/
    screens/
    widgets/
    viewmodels/
  domain/
    models/
    use_cases/
    services/
    repositories/
  data/
    repositories/
    sources/
    catalogs/
```

### 3.1 presentation
- 화면, 위젯, ViewModel, selector/provider를 둔다.
- Flutter, Riverpod 같은 UI 프레임워크 의존은 여기서 허용한다.
- 역할:
  - 사용자 입력 수집
  - 화면 상태 조립
  - 도메인 use case 호출
  - 도메인 모델을 화면용 값으로 변환
- 금지:
  - 게임 규칙 직접 구현
  - 데이터 원본 직접 접근
  - 다른 feature 내부 상태 직접 변경

### 3.2 domain
- feature의 핵심 규칙을 둔다.
- Flutter, Riverpod, 위젯 의존을 두지 않는다.

#### domain/models
- 엔티티, enum, value object, feature state
- "무엇이 존재하는가"를 정의한다.

#### domain/use_cases
- 사용자 액션 단위의 비즈니스 흐름
- 상태를 어떻게 바꾸는지 정의한다.
- 예:
  - 구매
  - 추출
  - 제작 큐 등록
  - 판매
  - 자동 전투 실행
  - 랭크업/티어업

#### domain/services
- 여러 use case가 공통으로 쓰는 순수 계산 규칙
- 알고리즘, 가격 계산, 제작 공식, 전투 결과 계산
- 외부 IO 없이 입력/출력만 가진다.

#### domain/repositories
- 데이터 접근 계약
- 저장/조회가 필요한 경우 interface만 둔다.

### 3.3 data
- 실제 데이터 접근 구현을 둔다.
- 저장소 구현체, 로컬/원격 source, catalog/mock/seed를 둔다.
- 외부 패키지, 파일, DB, API 의존은 여기서 처리한다.

## 4. 현재 프로젝트에 적용하는 소유권 기준

### 4.1 town
- `presentation`
  - 마을 화면, 상점 시트, 판매 UI
- `domain/use_cases`
  - 재료 구매, 강제 갱신, 자동 갱신 동기화
- `domain/services`
  - 가격/상점 갱신 계산

### 4.2 workshop
- `presentation`
  - 추출/제작 큐/완성 포션 관련 화면과 위젯
- `domain/models`
  - 재료, 포션, 추출, 큐, 드롭 모델
- `domain/use_cases`
  - 추출, 큐 등록, 틱 처리, blocked 재개, 완료 정리, 판매
- `domain/services`
  - 연금 계산, 제작 계산, 큐 진행 계산
- `data/catalogs`
  - 재료/포션/추출 프로필/상점 seed/전투 테이블

### 4.3 battle
- `presentation`
  - 전투 화면, 잠금/진행 UI
- `domain/use_cases`
  - 자동 전투 실행, 진행도 반영
- `domain/services`
  - 전투 결과 계산, 보상 해석

### 4.4 characters
- `presentation`
  - 캐릭터 화면, 힌트/상태 표시
- `domain/use_cases`
  - 랭크업, 티어업
- `domain/services`
  - XP 누적/레벨 계산

### 4.5 session
- `core/session`으로 본다.
- feature가 아니라 앱 전역 상태 저장소다.
- 책임:
  - 현재 상태 snapshot
  - 상태 반영
  - 전역 로그 적재
  - 시간 공급
- 금지:
  - feature 비즈니스 규칙 보유
  - 상점/전투/제작 로직 직접 구현

## 5. 의존성 규칙
- `presentation` -> `domain`
- `data` -> `domain`
- `core` -> feature 의존 금지
- feature A가 feature B의 `presentation`이나 `data`를 직접 참조하지 않는다.
- cross-feature 협력이 필요하면:
  - 공통 `core/session`을 통해 상태를 읽고
  - 각 feature의 `domain/use_case` 또는 `presentation/viewmodel` 진입점으로 호출한다.

## 6. 네이밍 규칙

### 파일명
- 화면: `*_screen.dart`
- 위젯: `*_widget.dart`, `*_sheet.dart`, `*_card.dart`, `*_list.dart`
- ViewModel: `*_view_model.dart`
- Selector/Provider: `*_selectors.dart`, `*_providers.dart`
- Use case: `*_use_case.dart`
- Domain service: `feature_responsibility_service.dart`
- Model: `*_model.dart`, `*_models.dart`, `*_state.dart`
- Repository contract: `*_repository.dart`
- Repository impl: `*_repository_impl.dart`

### 네이밍 금지
- `*_domain.dart`
- `manager`, `helper`, `util` 같은 모호한 이름
- feature 바깥 문맥이 없으면 의미가 불명확한 `service.dart`

## 7. 불필요한 리팩토링을 막는 구현 원칙

### 7.1 새 코드 작성 전 판단 순서
1. 이 코드는 어느 feature의 규칙인가
2. UI 조립인가, 비즈니스 규칙인가, 데이터 접근인가
3. 다른 use case에서도 재사용되는 순수 계산인가
4. 전역 공통인가, 사실상 특정 feature 전용인가

이 4개에 답할 수 없으면 파일을 만들지 않는다.

### 7.2 레이어 선택 기준
- 화면 표시와 입력 처리면 `presentation`
- 상태를 바꾸는 액션 흐름이면 `domain/use_cases`
- 순수 계산이면 `domain/services`
- 외부 데이터 읽기/쓰기면 `data`
- 앱 전역 상태 저장이면 `core/session`

### 7.3 리팩토링 허용 조건
- 책임이 두 개 이상 섞였을 때
- 다른 변경 이유를 가진 코드가 한 파일에 몰렸을 때
- 동일 규칙이 2곳 이상 중복됐을 때
- feature 경계를 넘는 직접 참조가 생겼을 때

### 7.4 리팩토링 금지 조건
- 단순히 이름이 마음에 들지 않는다는 이유만으로 이동하지 않는다.
- 아직 한 번도 재사용되지 않은 코드를 미리 추상화하지 않는다.
- feature 하나에서만 쓰이는 코드를 공통 폴더로 올리지 않는다.
- 구조 대칭을 맞추기 위해 빈 레이어를 억지로 만들지 않는다.

### 7.5 파일 분리 기준
- 한 파일에 "행동 축"이 2개 이상이면 분리한다.
- 화면 파일이 데이터 계산과 액션 조합까지 같이 들면 분리한다.
- 파일 길이보다 변경 이유 개수를 기준으로 나눈다.

## 8. 새 작업 추가 규칙
- 새 기능은 먼저 기존 feature 안에 넣는다.
- 새로운 top-level 폴더는 마지막 수단이다.
- feature를 새로 만들 기준:
  - 별도 화면이 있고
  - 별도 규칙이 있고
  - 독립적으로 테스트할 가치가 있을 때

## 9. 테스트 구조 원칙
```text
test/
  core/
  features/<feature>/presentation/
  features/<feature>/domain/
  features/<feature>/data/
```

- use case와 domain service는 단위 테스트 우선
- ViewModel은 상태 전이와 호출 경계 중심 테스트
- widget 테스트는 사용자 상호작용과 핵심 문구만 검증

## 10. 점진적 마이그레이션 원칙
- 기존 구조를 한 번에 다 뒤엎지 않는다.
- 새 코드부터 새 규칙을 따른다.
- 기존 파일은 다음 조건 중 하나를 만족할 때만 이동한다.
  - 기능 변경으로 반드시 수정해야 할 때
  - 책임 분리가 명확히 필요한 때
  - 테스트 경계가 깨질 때

## 11. 최종 원칙 요약
- 구조 기준은 `feature-first`
- 레이어 기준은 `presentation / domain / data`
- 전역 상태는 `core/session`
- `application`은 장기적으로 제거 대상
- `domain`은 모델과 비즈니스 규칙 전용
- 불필요한 이동보다 책임 명확화가 우선
