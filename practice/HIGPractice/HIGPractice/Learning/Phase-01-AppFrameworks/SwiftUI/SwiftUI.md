# SwiftUI

## 학습 소스
- site: `site/swiftui/01-tutorial.html`
- taskmaster folder: `practice/HIGPractice/HIGPractice/Learning/Phase-01-AppFrameworks/SwiftUI/TaskMaster`
- issue: 예정
- branch: 예정

## 이번 학습 구조
- `TaskMaster`
  - `site/swiftui/01-tutorial.html`의 예제를 직접 카피하면서 SwiftUI 문법과 UI 구조를 익히는 학습용 폴더
  - 단순 문법 복습이 아니라, 실제 Todo 성격의 화면을 조합하면서 상태/리스트/네비게이션을 같이 익히는 단계

## 이번 학습 방식
- 이번 SwiftUI 학습은 `Tutorial`과 `Sample`을 분리하지 않고, `TaskMaster` 안에서 코드를 카피하면서 익히는 방식으로 진행한다.
- 즉 흐름은:
  1. 사이트 예제를 읽는다
  2. `TaskMaster` 안에 직접 코드를 옮긴다
  3. 카피한 코드를 현재 프로젝트 기준으로 조금씩 수정한다
  4. 최종적으로는 SwiftUI 구조와 상태 흐름을 스스로 설명할 수 있어야 한다

## Ring 1 — SwiftUI 개요
### 개념 요약
- SwiftUI는 선언형 방식으로 UI를 구성하는 Apple의 UI 프레임워크다.
- 핵심은 "어떻게 그릴지"보다 "현재 상태에서 무엇이 보여야 하는지"를 표현하는 데 있다.
- 코드가 UI 구조와 상태 변화를 함께 설명한다.

### 내가 이해한 바
- SwiftUI는 화면을 직접 갱신하는 프레임워크라기보다, 상태가 바뀌면 UI가 다시 계산되는 구조에 가깝다.
- 그래서 처음부터 커스텀 디자인을 만드는 것보다 `View 구조`, `상태`, `데이터 흐름`을 먼저 이해해야 한다.

## SwiftUI 개념 메모

### 왜 `struct MyView: View`는 `var body: some View`가 필요할까
- `View`는 프로토콜이고, SwiftUI는 각 View 타입이 자기 화면 구조를 `body`로 설명하길 기대한다.
- 즉 `body`는 "이 View가 실제로 어떤 하위 View들로 구성되는가"를 정의하는 핵심 속성이다.
- SwiftUI는 상태가 바뀌면 이 `body`를 다시 계산해 새로운 화면 구조를 만든다.

### `some View`는 무엇인가
- `some View`는 "구체 타입은 하나로 정해져 있지만, 그 타입 이름은 숨긴다"는 뜻이다.
- 예를 들어 `Text("Hello")`를 반환하면 실제 타입은 `Text`지만, 바깥에는 `some View`라고만 드러난다.
- 중요한 점은 `some View`가 "아무 View나 가능하다"는 뜻이 아니라, 실제로는 하나의 고정된 구체 타입이라는 점이다.

### `any View`와의 차이
- `any View`는 "`View` 프로토콜을 따르는 타입이면 무엇이든 담을 수 있는 프로토콜 타입"이다.
- 즉 `some View`는 "정체는 하나인데 숨긴 것"이고,
- `any View`는 "`View` 계열이면 무엇이든 담을 수 있는 큰 상자"에 가깝다.

### 쉽게 비유하면
- `some View`
  - 봉투 안에 물건이 하나 들어 있고, 그 정체는 이미 정해져 있다.
  - 다만 바깥에서 타입 이름만 숨긴 상태다.
- `any View`
  - 상자 안에 `Text`, `Image`, `VStack`처럼 여러 종류의 View를 넣을 수 있다.
  - 공통점은 전부 `View` 프로토콜을 따른다는 것뿐이다.

### 왜 SwiftUI는 `some View`를 더 선호하나
- SwiftUI는 View 타입 정보를 많이 활용해서 렌더링 구조와 변경 지점을 추적한다.
- 그래서 타입이 더 선명한 `some View`가 SwiftUI의 기본 구조와 잘 맞는다.
- 반대로 `any View`는 "일단 View이긴 한데 정확한 타입 정보는 감춘 상태"라서 SwiftUI가 정적 타입 정보를 덜 활용하게 된다.

### 그럼 `body` 안에서 `if/else`는 왜 될까
- 겉으로 보면 `if`에서는 `ProgressView`, `else`에서는 `Text`처럼 서로 다른 타입을 반환하는 것처럼 보인다.
- 그런데 `body`는 SwiftUI가 `@ViewBuilder`로 조립해주는 특별한 문맥이라,
- 여러 View 분기와 조합을 결국 하나의 View 타입으로 묶어준다.

### `@ViewBuilder`는 무엇을 해주나
- 여러 View 조각을 하나의 View 결과처럼 조립해주는 빌더다.
- 그래서 `body` 안에서는 `if`, `switch`, 여러 줄 View 선언이 자연스럽게 동작한다.
- 일반 함수에서는 이 처리가 없으면 서로 다른 View 타입을 `some View`로 바로 반환하기 어렵다.

### `AnyView`는 언제 쓰나
- `AnyView`는 서로 다른 View 타입을 같은 박스에 넣어 하나처럼 다루고 싶을 때 쓴다.
- 다만 SwiftUI에서는 가능하면 `some View`와 `@ViewBuilder`를 먼저 쓰고,
- 정말 타입을 지워야 할 때만 `AnyView`를 쓰는 편이 일반적이다.

### 한 줄 정리
- `body` = 이 View의 실제 화면 정의
- `some View` = 구체 타입은 하나지만 이름은 숨김
- `any View` = `View`면 무엇이든 담을 수 있는 프로토콜 타입
- `@ViewBuilder` = 여러 View 조각을 하나의 View처럼 조립해주는 장치

## 접근성 메모

### SwiftUI의 accessibility 속성은 무엇을 하나
- `accessibility...` 계열 modifier는 주로 `VoiceOver` 같은 보조기술이 화면 요소를 더 정확히 읽도록 돕는다.
- 즉 시각적으로 보이는 정보(색상, 선택 상태, 배지 숫자)를 텍스트 정보로 다시 전달하는 역할에 가깝다.

### 자주 쓰는 속성
- `accessibilityLabel`
  - 이 요소의 이름을 정한다.
  - 예: 화면에는 `업무`라고만 보여도, 보조기술에는 `업무 카테고리`라고 더 명확하게 읽히게 할 수 있다.
- `accessibilityValue`
  - 현재 상태값을 전달한다.
  - 예: `선택됨`, `3개 미완료`
- `accessibilityHint`
  - 사용자가 이 요소를 조작하면 어떤 일이 일어나는지 설명한다.
  - 예: `탭하면 업무 카테고리로 필터링합니다`
- `accessibilityAddTraits`
  - 이 요소의 성격을 추가로 알려준다.
  - 예: 현재 선택된 칩이면 `.isSelected`를 붙여 "선택된 항목"으로 인식하게 한다.

### 왜 필요한가
- 시각적으로는 색상, 배경, 배지, 볼드 처리로 상태를 표현할 수 있다.
- 하지만 VoiceOver 사용자는 그 시각적 차이를 직접 볼 수 없기 때문에,
- SwiftUI 접근성 속성으로 같은 의미를 텍스트/상태 정보로 전달해야 한다.

### 이번 TaskMaster 예시로 보면
- `CategoryChip`은 단순 버튼이 아니라
  - 어떤 카테고리인지
  - 몇 개가 남아 있는지
  - 지금 선택된 상태인지
  - 누르면 어떤 필터가 적용되는지
  를 함께 설명해야 한다.
- 그래서 `accessibilityLabel`, `Value`, `Hint`, `Traits`를 같이 붙이는 것이 좋다.

### 음성 명령과의 차이
- 이 속성들은 주로 `VoiceOver`처럼 화면을 읽어주는 보조기술을 위한 것이다.
- 즉 `Siri`나 `App Intents`처럼 "말로 앱 기능을 실행하는 구조"와는 목적이 다르다.
- 정리하면:
  - 접근성 속성 = UI 요소를 보조기술이 더 잘 읽게 만드는 정보
  - App Intents = 앱 기능을 시스템에 외부 액션으로 노출하는 구조

## 빈 상태 UI 메모

### `ContentUnavailableView`는 무엇인가
- `ContentUnavailableView`는 보여줄 데이터가 없을 때 사용하는 SwiftUI의 시스템 기본 빈 상태 화면이다.
- 예를 들어:
  - 할일 목록이 비어 있을 때
  - 검색 결과가 없을 때
  - 아직 데이터가 생성되지 않았을 때
  같은 상황에 적합하다.

### 왜 쓰는가
- 빈 `List`나 빈 `ScrollView`만 보여주면 사용자는 "왜 아무것도 안 보이는지" 이해하기 어렵다.
- `ContentUnavailableView`를 쓰면
  - 현재 상태가 왜 비어 있는지
  - 다음에 무엇을 하면 되는지
  를 시스템 스타일에 맞게 전달할 수 있다.

### 어떤 요소로 구성되나
- 제목
- 시스템 이미지
- 설명 텍스트
- 필요하면 액션 버튼

### 예시
```swift
ContentUnavailableView(
    "할 일이 없습니다",
    systemImage: "checklist",
    description: Text("새 할 일을 추가해보세요.")
)
```

### TaskMaster에서의 사용 위치
- `TaskMasterView`에서 전체 할일이 0개일 때
- 검색 결과가 0개일 때
- 특정 카테고리 필터 결과가 비어 있을 때
- 즉 "콘텐츠가 없는 이유를 사용자에게 바로 설명해야 하는 화면"에 쓰는 게 좋다.

### 한 줄 정리
- `ContentUnavailableView` = 데이터가 없을 때 보여주는 SwiftUI 기본 empty state UI

## 타입 / 인스턴스 / static 메모

### 타입과 인스턴스란
- 타입은 설계도에 가깝다.
- 인스턴스는 그 설계도로 실제 만들어진 값 하나다.
- 비유하면:
  - 타입 = 붕어빵 틀
  - 인스턴스 = 실제 만들어진 붕어빵 1개

### 인스턴스 프로퍼티와 타입 프로퍼티의 차이
- 인스턴스 프로퍼티
  - 각 인스턴스가 자기 값을 가진다.
  - 예: `task.title`, `task.isCompleted`
- 타입 프로퍼티(`static`)
  - 타입 전체가 하나의 값을 공유한다.
  - 예: `TaskMasterRootView.sharedModelContainer`

### 왜 `static`이 중요한가
- SwiftUI의 `View`는 `struct` 기반이라 값 타입이고, 새로 계산되거나 재생성될 수 있다.
- 그런데 `ModelContainer`처럼 생성 비용이 크고 여러 화면이 같이 써야 하는 자원은
  - 각 View 인스턴스가 따로 가지는 값보다
  - 타입 전체가 공유하는 값으로 두는 편이 더 자연스럽다.
- 그래서 이런 자원은 일반 `let`보다 `static let`이 더 적합하다.

### `private let` vs `private static let`
- `private let`
  - 인스턴스 소속 고정 값
  - View 인스턴스가 자기 값을 가지는 구조
- `private static let`
  - 타입 전체가 공유하는 고정 값
  - 무거운 공용 자원, 공통 설정, 공용 컨테이너에 적합

### `ModelContainer`는 무엇인가
- SwiftData에서 실제 저장소 역할을 하는 객체다.
- `TaskItem`, `Category` 같은 모델을 어떤 schema로 저장할지 정하고,
- 하위 View들이 `modelContext`와 `@Query`를 쓸 수 있도록 데이터 환경을 제공한다.

### `.modelContainer(...)`는 무엇을 하나
- 특정 `ModelContainer`를 View 계층에 주입한다.
- 이 modifier가 있어야 하위 View에서:
  - `@Environment(\\.modelContext)`
  - `@Query`
  가 같은 SwiftData 저장소를 기준으로 동작할 수 있다.

### 왜 `TaskMasterRootView`에 `sharedModelContainer`를 두는가
- `TaskMasterApp.swift`의 `@main` 역할 전체를 그대로 가져오는 것이 아니라,
- 앱 진입 시점에 하던 SwiftData 준비 작업만 `RootView`로 옮긴다.
- 즉 `TaskMasterRootView`는:
  - `ModelContainer` 생성
  - 기본 카테고리 초기화
  - `TaskMasterView`에 SwiftData 환경 주입
  을 담당하는 래퍼 역할이다.

### 한 줄 정리
- 타입 = 설계도
- 인스턴스 = 실제 값 하나
- `static let` = 타입 전체가 공유하는 공용 자원
- `ModelContainer` = SwiftData 저장소 본체
- `.modelContainer(...)` = 그 저장소를 View 트리에 주입하는 작업

## Ring 2 — 기본 View 구조와 Modifier
### 개념 요약
- 모든 화면은 `View` 프로토콜을 따르는 타입으로 시작한다.
- `VStack`, `HStack`, `ZStack`, `Text`, `Image`, `Button` 같은 작은 View를 조합해 화면을 만든다.
- Modifier는 View의 모양과 동작을 단계적으로 바꾼다.

### 이번에 먼저 볼 것
- `Text`, `Image`, `Button`
- `padding`, `font`, `foregroundStyle`, `background`
- 커스텀 `ViewModifier`

### 검증
- [ ] 하나의 카드형 UI를 `VStack + modifier` 조합으로 만들기
- [ ] 같은 스타일을 커스텀 modifier로 추출하기

## Ring 3 — State와 Binding
### 개념 요약
- SwiftUI의 핵심은 상태 기반 렌더링이다.
- `@State`는 View 내부의 로컬 상태다.
- `$binding`은 상태를 하위 View나 입력 컴포넌트와 연결할 때 사용한다.

### 이번에 먼저 볼 것
- `@State`
- `TextField`, `SecureField`
- `disabled`
- 입력값과 버튼 활성화 연결

### 내가 이해한 바
- SwiftUI에서 중요한 건 "UI를 바꾸는 코드"보다 "상태를 바꾸는 코드"다.
- 상태가 바뀌면 UI는 다시 계산되므로, 로직 중심으로 생각하는 습관이 더 중요하다.

### 검증
- [ ] 입력 폼 하나를 만들고 버튼 활성화 조건 연결
- [ ] 카운터/토글처럼 상태 변화가 즉시 UI에 반영되는지 확인

## Ring 4 — List, ForEach, Navigation
### 개념 요약
- SwiftUI 앱의 대부분은 "목록 -> 상세" 구조를 가진다.
- `List`와 `ForEach`는 컬렉션 기반 UI의 기본이다.
- `NavigationStack`은 현재 iOS 기준 기본 네비게이션 컨테이너다.

### 이번에 먼저 볼 것
- `Identifiable`
- `List`
- `ForEach`
- `NavigationStack`
- `NavigationLink`

### 검증
- [ ] Todo 형태의 리스트를 렌더링
- [ ] 리스트 항목 탭 시 상세 화면으로 이동
- [ ] 삭제/토글 같은 간단한 액션 붙이기

### 회고 포인트
- 값 기반 navigation과 destination 연결은 구조를 단순하게 유지해야 디버깅이 쉽다.
- 작은 샘플이라도 `목록 -> 상세` 흐름을 먼저 고정하면 이후 확장이 편하다.

## Ring 5 — 애니메이션과 스타일
### 개념 요약
- SwiftUI 애니메이션은 "상태 변화에 따라 어떤 전환을 보여줄지"를 선언하는 방식이다.
- 과한 모션보다 상태 변화를 보조하는 수준이 좋다.
- HIG 관점에서는 여백, 계층, 가독성, 터치 영역이 먼저고 애니메이션은 그 다음이다.

### 이번에 먼저 볼 것
- `.animation(..., value:)`
- `spring`
- 회전/크기 변화
- 버튼 스타일, 카드 스타일

### 검증
- [ ] 상태 토글에 따른 크기/회전 애니메이션 추가
- [ ] 버튼 스타일과 카드 스타일을 공통화

## Ring 6 — 상태 관리 확장
### 개념 요약
- 단순 화면 상태는 `@State`
- 여러 화면/도메인 상태는 별도 모델 계층으로 분리
- iOS 17+에서는 `@Observable` 중심 설계가 권장된다.

### 이번에 먼저 볼 것
- `@Observable`
- `ObservableObject`와 차이
- 어떤 상태를 View 안에 두고, 어떤 상태를 외부 모델로 뺄지 기준 세우기

### 내가 이해한 바
- SwiftUI 학습에서 가장 중요한 건 화면 코드보다 "상태를 어디에 둘 것인가"다.
- `SwiftUI`와 `Observation`을 섞어 이해하기보다,
  - SwiftUI는 View 계층
  - Observation은 상태 관리 계층
  로 나눠서 보는 게 덜 헷갈린다.

## site → TaskMaster 적용 플로우

### 1) 사이트 예제로 개념을 빠르게 익힌다
- View 구조
- Modifier
- State / Binding
- List / Navigation
- Animation

### 2) `TaskMaster` 안에 코드를 직접 옮긴다
- 할일 목록 화면
- 입력 폼 화면
- 상세 화면
- 공통 카드 스타일

### 3) 카피한 코드를 보면서 다시 체크할 질문
- 이 화면 상태는 `@State`인가, 외부 모델인가?
- 이 View는 너무 많은 책임을 가지지 않는가?
- 공통 스타일/레이아웃을 추출해야 하는가?
- Navigation 구조가 단순하게 유지되는가?

## SwiftUI 실무 적용 원칙
- 작은 View를 조합해 큰 화면을 만든다.
- 상태를 먼저 정의하고 UI는 그 상태를 반영하게 만든다.
- Modifier 중복은 공통 스타일로 추출한다.
- `List`, `NavigationStack`, `Form`, `Section` 같은 시스템 컴포넌트를 우선 활용한다.
- 커스텀 디자인은 구조와 데이터 흐름이 안정화된 뒤 붙인다.

## 이번 학습의 목표
- [ ] `TaskMaster` 안에서 SwiftUI 핵심 문법 예제를 직접 옮기며 다시 정리
- [ ] Todo 스타일 샘플 화면 1세트를 `TaskMaster` 안에서 구현
- [ ] `@State`와 `@Observable`의 경계를 실전 기준으로 이해
- [ ] HIG 관점에서 여백, 계층, 터치 영역을 체크

## 최종 정리
- 오늘 배울 핵심 3가지:
  1. SwiftUI는 선언형 UI 프레임워크이고, 상태가 UI를 결정한다.
  2. View 구조보다 더 중요한 것은 상태와 데이터 흐름의 위치다.
  3. 사이트 예제를 `TaskMaster`에 직접 옮겨보면서 구조를 손으로 익혀야 학습이 굳는다.
- 다음 액션:
  1. `TaskMaster` 폴더에 기초 예제부터 순서대로 정리
  2. `TaskMaster` 안에 Todo 기반 화면 샘플 구성
  3. 이후 `Observation` 학습과 연결해 상태 관리 경계를 다시 점검
