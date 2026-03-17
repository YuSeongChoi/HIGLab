# [학습] Phase 1 - Observation

- label: `learning`
- branch: `learning/observation-cartflow`
- issue: `#26`

## 학습 Phase
- Phase 1: App Frameworks

## Framework 이름
- Observation

## 이번 학습 목표
- `CartFlow`를 기준으로 Observation 상태 소유권과 뷰 갱신 흐름을 설명할 수 있다.
- `@Observable`, `@State`, `@Bindable`, `@Environment`의 역할을 구분할 수 있다.
- 뷰가 "읽은 프로퍼티만 추적된다"는 Observation의 핵심 원리를 정리한다.
- `ObservableObject` 기반 사고방식과 Observation 기반 사고방식의 차이를 비교 설명할 수 있다.
- 이후 Foundation Models나 더 큰 앱 구조 학습으로 넘어갈 때 상태 관리 기준점으로 삼을 메모를 남긴다.

## 작업 체크리스트
- [x] site 개념 확인
- [x] tutorials 실습
- [x] samples 구조 비교
- [x] `CartStore.swift` 읽고 `@Observable` / 상태 소유 구조 정리
- [x] `Product.swift` 읽고 plain model과 observable store 경계 정리
- [x] `ProductListView.swift` 읽고 읽기 추적과 뷰 갱신 범위 정리
- [x] `CartView.swift` 읽고 파생 상태와 액션 위임 구조 정리
- [x] `CheckoutView.swift` 읽고 async 상태 전이 정리
- [x] `CartFlowApp.swift` 읽고 앱 루트 상태 주입 방식 정리
- [x] Observation vs ObservableObject 비교 메모 작성
- [ ] PR 생성 및 CI 확인
- [ ] 머지 후 `LEARNING_LOG` / 회고 기록

## 완료 조건 (Definition of Done)
- `CartFlow` 기준 Observation 핵심 파일의 역할을 스스로 설명할 수 있다.
- `@Observable`, `@State`, `@Bindable`, `@Environment`의 사용 기준을 말할 수 있다.
- 왜 Observation이 `ObservableObject`보다 읽기 추적 관점에서 더 정교한지 설명할 수 있다.
- `Observation.md`에 파일별 메모와 비교 정리가 남아 있다.

## 2026-03-17 진행 메모
- `CartFlow/Views` 폴더 구현을 완료했다.
- 상품 목록, 장바구니, 체크아웃, 결제 결과, 루트 탭 구조, Apple Pay 버튼 래퍼를 연결했다.
- `CartStore`를 루트에서 소유하고 하위 화면에서는 `@Environment`와 `@Bindable`로 읽거나 전달하는 구조를 실제 UI에 반영했다.
- Apple Pay 결제 흐름을 위해 PassKit 관련 타입 import와 보조 UI도 함께 정리했다.
