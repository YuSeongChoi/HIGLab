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
