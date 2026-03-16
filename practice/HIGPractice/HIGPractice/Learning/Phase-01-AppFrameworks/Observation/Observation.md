# Observation

## 학습 소스
- site: `site/observation/01-tutorial.html`
- tutorials: `tutorials/observation`
- sample: `samples/CartFlow`
- ai-reference: `ai-reference/swiftui-observation.md`
- issue draft: `practice/HIGPractice/HIGPractice/Learning/Phase-01-AppFrameworks/Observation/ISSUE_DRAFT.md`
- issue: `#26`
- branch: `learning/observation-cartflow`

## 이번 학습 구조
- 이번 Observation 학습은 `CartFlow`를 기준으로 "상태가 어떻게 추적되고, 어떤 읽기가 어떤 뷰 갱신을 유발하는가"를 보는 방식으로 진행한다.
- SwiftUI 때는 화면 구조, SwiftData 때는 저장 흐름을 봤다면, 이번에는 상태 관리 계층 자체를 읽는다.
- 핵심 질문은 아래 4가지다.
  - 상태는 어느 객체가 소유하는가
  - 뷰는 어떤 값을 읽고 있는가
  - 어떤 수정이 어떤 뷰 갱신으로 이어지는가
  - `@Observable`, `@State`, `@Bindable`, `@Environment`는 각각 어디에 쓰는가

## 이번 학습 방식
- 읽는 순서는 고정한다.
  1. `CartStore.swift`
  2. `Product.swift`
  3. `ProductListView.swift`
  4. `CartView.swift`
  5. `CheckoutView.swift`
  6. `CartFlowApp.swift`
- 각 파일에서 "Observation 관점 메모"를 남긴다.
- 문법만 외우지 말고, `CartFlow`에서 상태 소유권과 뷰 갱신 경계를 설명할 수 있는지까지 본다.

## 읽는 순서와 체크 포인트

### 1. `CartStore.swift`
- 파일: `samples/CartFlow/Shared/CartStore.swift`
- 여기서는 "상태를 가진 중심 객체"를 본다.
- 체크 포인트
  - `@Observable`
  - stored property와 computed property
  - 상태 변경 메서드
  - 왜 `ObservableObject` 대신 이 구조를 쓰는가

### 내가 적을 메모
- `CartStore`는 Observation 상태의 중심 객체다.
- `@Observable`이 붙으면 stored property 접근과 변경이 자동 추적된다.
- `items`, `isLoading`, `isCheckoutComplete`, `errorMessage`는 추적 대상 상태다.
- `totalItemCount`, `totalPrice`, `formattedTotalPrice`, `isEmpty`는 저장값이 아니라 읽기 파생값이다.

## `CartStore.swift`를 보고 답할 질문
- `@Observable`은 무엇을 자동화하는가
- computed property는 어떻게 뷰 갱신과 연결되는가
- 도메인 메서드를 store 안에 두는 이유는 무엇인가

### 2. `Product.swift`
- 파일: `samples/CartFlow/Shared/Product.swift`
- 여기서는 "관찰 대상 상태"와 "단순 모델 값"의 차이를 본다.
- 체크 포인트
  - value type 모델
  - store가 아닌 데이터 모델의 역할
  - 상태 소유권 경계

### 내가 적을 메모
- 모든 모델이 `@Observable`일 필요는 없다.
- `Product`처럼 주로 값 전달에 쓰이는 모델은 단순 struct로 두는 편이 자연스럽다.
- Observation에서 중요한 건 "무엇을 관찰할지"보다 "누가 상태를 소유하고 바꾸는지"를 분리하는 것이다.

## `Product.swift`를 보고 답할 질문
- 왜 `Product`는 `@Observable`이 아닐까
- store와 plain model은 역할이 어떻게 다른가

### 3. `ProductListView.swift`
- 파일: `samples/CartFlow/CartFlowApp/Views/ProductListView.swift`
- 여기서는 "뷰가 상태를 읽는 방식"을 본다.
- 체크 포인트
  - 뷰가 store를 어떻게 받는가
  - 어떤 프로퍼티 읽기가 뷰 갱신 대상이 되는가
  - 세부 뷰 분리와 읽기 범위

### 내가 적을 메모
- Observation에서는 뷰가 실제로 읽은 프로퍼티 기준으로 갱신 경계가 잡힌다.
- 따라서 큰 store 하나를 넘기더라도, 뷰가 무엇을 읽는지에 따라 갱신 범위가 달라진다.
- 이 단계에서는 "store를 넘기는 것"보다 "어떤 값을 읽는지"가 더 중요하다.

## `ProductListView.swift`를 보고 답할 질문
- 이 뷰는 store의 어떤 값을 읽고 있는가
- 읽기 범위를 줄이면 어떤 이점이 있는가

### 4. `CartView.swift`
- 파일: `samples/CartFlow/CartFlowApp/Views/CartView.swift`
- 여기서는 "파생 상태와 사용자 액션"을 본다.
- 체크 포인트
  - 계산 프로퍼티 사용
  - 수량 변경 액션
  - 비어 있음/합계/목록 상태 연결

### 내가 적을 메모
- `CartView`는 store의 raw state와 파생 state를 함께 사용한다.
- 아이템 수량 변경 같은 액션은 뷰가 직접 배열을 수정하지 않고 store 메서드에 위임한다.
- Observation 학습에서는 "뷰가 상태를 어떻게 직접 만지지 않게 하는가"도 중요하다.

## `CartView.swift`를 보고 답할 질문
- 뷰가 배열을 직접 수정하지 않고 store 메서드를 호출하는 이유는 무엇인가
- 빈 상태, 합계, 목록은 각각 어떤 읽기에 의존하는가

### 5. `CheckoutView.swift`
- 파일: `samples/CartFlow/CartFlowApp/Views/CheckoutView.swift`
- 여기서는 "비동기 상태 변화"를 본다.
- 체크 포인트
  - `isLoading`
  - `errorMessage`
  - async 액션 후 상태 전이

### 내가 적을 메모
- Observation은 비동기 작업 자체를 처리하는 프레임워크가 아니라, 비동기 작업이 바꾼 상태를 추적하는 프레임워크다.
- 따라서 `checkout()` 같은 async 메서드에서는 작업보다 "어떤 상태를 언제 바꾸는가"를 봐야 한다.

## `CheckoutView.swift`를 보고 답할 질문
- async 작업과 Observation의 관계는 무엇인가
- 로딩/성공/실패는 어떤 상태로 표현되는가

### 6. `CartFlowApp.swift`
- 파일: `samples/CartFlow/CartFlowApp/CartFlowApp.swift`
- 여기서는 "상태 소유권 주입"을 본다.
- 체크 포인트
  - 앱 루트에서 store를 어디에 두는가
  - `@State`와 `@Environment` 사용 위치
  - 하위 뷰 전달 방식

### 내가 적을 메모
- Observation에서는 `@Observable` 타입을 앱 루트에서 `@State`로 소유하는 패턴이 중요하다.
- 환경 주입을 쓰면 하위 뷰는 타입 기반으로 상태를 읽을 수 있다.
- 이 단계는 SwiftUI 학습에서 봤던 상태 소유권 개념과 직접 연결된다.

## `CartFlowApp.swift`를 보고 답할 질문
- 왜 앱 루트에서 store를 소유하는가
- `@State`와 `@Environment`는 각각 어느 역할인가

## Observation 핵심 개념 요약

### `@Observable`
- 상태 객체를 자동 추적 가능하게 만드는 매크로
- `ObservableObject` + `@Published` 조합의 많은 보일러플레이트를 줄인다

### `@Bindable`
- `@Observable` 객체의 프로퍼티를 폼 입력과 양방향 바인딩할 때 사용한다
- 읽기 전용 참조가 아니라 binding을 열어 주는 역할이다

### `@State`
- 뷰가 상태 객체의 소유권을 가질 때 쓴다
- Observation 객체도 앱/뷰 루트에서는 `@State`로 들고 가는 경우가 많다

### `@Environment`
- Observation 상태 객체를 하위 뷰로 공유할 때 타입 기반으로 주입할 수 있다
- 기존 `@EnvironmentObject`와 구분해서 이해해야 한다

## Observation vs ObservableObject

### Observation이 강한 점
- 더 적은 보일러플레이트
- 프로퍼티 단위 읽기 추적
- modern SwiftUI 패턴과 자연스럽게 연결

### ObservableObject가 남는 맥락
- 구버전 iOS 호환
- 기존 코드베이스 유지보수
- Combine 의존이 이미 깊은 경우

## 이번 학습 체크리스트
- [ ] `@Observable`이 무엇을 자동화하는지 설명할 수 있다
- [ ] `@State`로 Observation 객체를 소유하는 이유를 말할 수 있다
- [ ] `@Bindable`이 필요한 순간을 설명할 수 있다
- [ ] 뷰가 "읽은 프로퍼티 기준으로 갱신된다"는 말을 설명할 수 있다
- [ ] plain model과 observable store의 역할 차이를 말할 수 있다
- [ ] async 작업과 상태 추적의 관계를 말할 수 있다
- [ ] `Observation`과 `ObservableObject`의 차이를 비교할 수 있다

## 이번 학습에서 내가 남길 정리
- Observation의 핵심은 "상태 객체를 만든다"가 아니라 "어떤 읽기가 어떤 갱신을 만들었는지"를 이해하는 데 있다.
- SwiftUI와 SwiftData 학습에서 봤던 상태/저장 흐름이 Observation에서 하나로 이어진다.
