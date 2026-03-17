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
- 완료 여부: [x]
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
- 예전 `ObservableObject`처럼 각 프로퍼티마다 `@Published`를 붙이지 않아도 된다는 점이 가장 큰 문법 차이다.
- 하지만 더 중요한 차이는 "모든 변경 통지"가 아니라 "실제로 읽은 프로퍼티 기준 추적"이라는 점이다.
- `addToCart`, `updateQuantity`, `checkout` 같은 메서드를 store 안에 두면, 뷰는 상태 변경 규칙을 직접 들지 않고 store의 도메인 동작만 호출하면 된다.
- 따라서 Observation에서는 상태 객체를 단순 데이터 상자가 아니라 "상태 + 상태 변경 규칙을 가진 객체"로 보는 편이 이해에 도움이 된다.

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

## Observation 전에 같이 알아둘 이론

### `Sendable`은 무엇인가
- `Sendable`은 "이 값을 동시성 경계를 넘어 안전하게 전달할 수 있는가"를 나타내는 프로토콜이다.
- 여기서 동시성 경계란 다른 `Task`, 다른 actor, 다른 실행 문맥으로 값이 이동하는 상황을 말한다.
- Swift Concurrency에서 데이터 레이스를 줄이기 위해 컴파일러가 확인하는 기준 중 하나다.

### `Sendable`과 `@Sendable`의 차이
- `Sendable`은 타입에 붙는다.
  - 예: 어떤 struct, enum, class가 안전하게 전달 가능한가
- `@Sendable`은 클로저 타입에 붙는다.
  - 예: 어떤 클로저를 task에 넘겨도 안전한가
- 즉 `Sendable`은 값의 안전성, `@Sendable`은 클로저의 안전성이라고 보면 된다.

### 왜 Observation 학습 전에 이것을 알아야 하나
- Observation은 상태를 추적하는 프레임워크지만, 실제 앱에서는 async 작업과 함께 쓰이는 경우가 많다.
- 이때 상태 객체 자체는 Observation으로 이해하고,
  task/actor 사이에 넘기는 값은 `Sendable` 관점으로 이해해야 경계가 헷갈리지 않는다.
- 즉 Observation은 "누가 상태를 읽고 갱신하는가"를 설명하고,
  `Sendable`은 "그 값을 다른 실행 문맥으로 보내도 안전한가"를 설명한다.

### struct는 언제 `Sendable`에 유리한가
- struct는 값 타입이라 기본적으로 참조 공유 문제가 적다.
- 내부 프로퍼티가 모두 안전한 값 타입이면 자동으로 `Sendable` 취급이 가능한 경우가 많다.
- 예를 들어 `String`, `Int`, `Bool`, 그리고 그 값들로 이루어진 단순 설정 struct는 `Sendable`과 잘 맞는다.

### class는 왜 `Sendable`이 까다로운가
- class는 참조 타입이라 여러 task가 같은 객체 하나를 동시에 볼 수 있다.
- 그 객체가 mutable state를 가지면 데이터 레이스 가능성이 생긴다.
- 그래서 상태가 계속 바뀌는 store나 manager는 무조건 `Sendable`로 보기보다,
  `@MainActor`, actor 격리, 혹은 명확한 소유권 구조로 먼저 이해하는 편이 맞다.

### Observation과 `Sendable`을 헷갈리지 않기
- `@Observable` = 상태 추적
- `@Bindable` = 양방향 바인딩
- `@State` = 상태 소유
- `@Environment` = 상태 공유
- `Sendable` = 동시성 경계를 넘는 값 안전성
- `@Sendable` = 동시 실행에 넘기는 클로저 안전성

### 한 줄 정리
- Observation은 "이 상태를 누가 읽고 바꾸는가"를 보는 도구다.
- `Sendable`은 "이 값을 다른 task/actor로 보내도 안전한가"를 보는 기준이다.

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

## 2026-03-17 구현 완료 메모

### 이번에 구현한 범위
- `CartFlow/Views` 폴더의 주요 화면 구현을 완료했다.
- 구현 파일
  - `ProductListView.swift`
  - `CartView.swift`
  - `CheckoutView.swift`
  - `PaymentResultView.swift`
  - `CartRootView.swift`
  - `ApplePayButton.swift`
- Apple Pay 결제 흐름을 보조하기 위해 `PassKit` import 범위와 결제 설정 타입도 함께 정리했다.

### 화면별 Observation 관점 정리
- `ProductListView`
  - `@Environment(CartStore.self)`로 공유 store를 읽고, 화면 고유 상태는 `@State`로 분리했다.
  - 상품 로딩, 검색어, 레이아웃 모드, 정렬 기준은 뷰 로컬 상태이며, 장바구니 담기 액션만 store에 위임한다.
- `CartView`
  - 장바구니 목록, 합계, 빈 상태는 store의 읽기 결과에 따라 자동 갱신된다.
  - 삭제 확인, 결제 이동 여부 같은 일회성 UI 상태는 로컬 `@State`로 유지했다.
- `CheckoutView`
  - `@Bindable var cartStore`로 결제 직전 단계에서 store를 직접 참조한다.
  - 배송 방법, 쿠폰, 에러 표시, 결과 sheet 노출은 checkout 화면 책임으로 두고, 실제 결제 후 장바구니 정리는 store 액션으로 연결했다.
- `CartRootView`
  - 앱 루트에서 `@State private var cartStore = CartStore()`로 상태 소유권을 가진 뒤 `.environment(cartStore)`로 하위에 주입했다.
  - Observation에서 루트 소유와 하위 공유가 어떻게 분리되는지 확인할 수 있다.
- `ApplePayButton` / `PaymentResultView`
  - UIKit/PassKit 브리징과 결과 표현 UI를 SwiftUI로 감싸면서도, 결제 진행 상태는 별도 상태값으로 분리했다.
  - 외부 서비스 상태와 화면 표현 상태를 분리하는 구조가 Observation 학습 포인트로 남는다.

### 이번 구현에서 확인한 기준
- 공유 도메인 상태는 `CartStore`가 소유한다.
- 뷰 전용 상태는 각 화면의 `@State`로 둔다.
- 수정 규칙은 store 메서드나 서비스 메서드로 위임한다.
- Observation 학습에서는 "store를 어디서 읽는가"와 "뷰가 어떤 값을 직접 가지는가"를 분리해서 보는 것이 중요하다.

### 다음에 PR/회고에 옮길 핵심 문장
- 이번 작업은 `CartFlow`의 Views 레이어를 완성하면서 Observation의 상태 소유권, 읽기 추적, 화면 로컬 상태 분리를 실제 UI 흐름으로 연결한 단계다.
- 특히 `@Environment(CartStore.self)`, `@Bindable`, `@State`가 각각 어디에서 필요한지 실제 결제 플로우 안에서 비교할 수 있게 됐다.
