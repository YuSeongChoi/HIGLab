# [학습] Observation - CartFlow Views 구현

## 요약
- `CartFlow`의 `Views` 폴더 구현을 마무리했습니다.
- 상품 목록부터 장바구니, 체크아웃, 결제 결과까지 이어지는 UI 흐름을 연결했습니다.
- Observation 관점에서 `CartStore`의 상태 소유권과 화면별 로컬 상태 분리를 실제 코드로 정리했습니다.

## 주요 변경 사항
- `ProductListView` 구현
  - 상품 로딩, 검색, 카테고리 필터, 정렬, 그리드/리스트 전환
  - 장바구니 추가 토스트와 접근성 라벨 반영
- `CartView` 구현
  - 장바구니 목록, 수량 변경, 삭제 확인, 무료 배송 진행률, 체크아웃 진입
- `CheckoutView` 구현
  - 주문 요약, 배송 방법 선택, 쿠폰 적용, Apple Pay 결제 시작, 오류/결과 처리
- `PaymentResultView` 구현
  - 결제 상태별 결과 표시, 주문/배송/결제 정보 요약, 영수증 공유
- `CartRootView`, `ApplePayButton` 구현
  - 루트 상태 주입, 탭 구조, PassKit 버튼 브리징, 결제 진행 상태 UI 추가
- 보조 수정
  - PassKit 관련 shared/service 타입 import 정리
  - Xcode project 파일에 신규 뷰 파일 반영

## Observation 학습 포인트
- 루트에서 `@State`로 `CartStore`를 소유하고 `.environment(cartStore)`로 하위에 주입했습니다.
- 목록/장바구니 화면은 `@Environment(CartStore.self)`로 공유 상태를 읽도록 구성했습니다.
- 체크아웃 화면은 `@Bindable`로 store를 직접 참조해 결제 직전 상태를 다루도록 구성했습니다.
- 검색어, 탭 선택, 시트 표시, 토스트, 쿠폰 입력 같은 화면 전용 상태는 각 뷰의 `@State`로 분리했습니다.

## 테스트
- 별도 자동 테스트는 실행하지 못했습니다.
- 수동 확인 기준
  - 상품 추가 시 목록 화면과 장바구니 화면의 상태가 함께 갱신되는지
  - 수량 변경 시 합계와 무료 배송 진행률이 함께 반영되는지
  - 체크아웃 후 결과 화면 표시와 장바구니 비우기 흐름이 정상인지

## 이슈에 남길 내용
- Observation 학습 범위 중 `CartFlow`의 Views 구현을 완료했습니다.
- 상태 소유권은 루트 `CartStore`, 화면 전용 상태는 각 뷰 `@State`로 나누는 기준을 실제 코드에 반영했습니다.
- `@Environment`, `@Bindable`, `@State`의 역할 차이를 상품 목록-장바구니-체크아웃 흐름에서 확인할 수 있게 정리했습니다.

## 후속 정리
- PR 생성 후 `LEARNING_LOG.md`의 Observation 행에 PR 번호를 업데이트합니다.
- issue 체크리스트의 `PR 생성 및 CI 확인`, `머지 후 LEARNING_LOG / 회고 기록` 항목은 실제 PR 진행 시점에 마무리합니다.
