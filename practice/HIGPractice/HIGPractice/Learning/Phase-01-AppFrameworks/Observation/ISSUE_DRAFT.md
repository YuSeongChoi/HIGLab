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
- [ ] site 개념 확인
- [ ] tutorials 실습
- [ ] samples 구조 비교
- [ ] `CartStore.swift` 읽고 `@Observable` / 상태 소유 구조 정리
- [ ] `Product.swift` 읽고 plain model과 observable store 경계 정리
- [ ] `ProductListView.swift` 읽고 읽기 추적과 뷰 갱신 범위 정리
- [ ] `CartView.swift` 읽고 파생 상태와 액션 위임 구조 정리
- [ ] `CheckoutView.swift` 읽고 async 상태 전이 정리
- [ ] `CartFlowApp.swift` 읽고 앱 루트 상태 주입 방식 정리
- [ ] Observation vs ObservableObject 비교 메모 작성
- [ ] PR 생성 및 CI 확인
- [ ] 머지 후 `LEARNING_LOG` / 회고 기록

## 완료 조건 (Definition of Done)
- `CartFlow` 기준 Observation 핵심 파일의 역할을 스스로 설명할 수 있다.
- `@Observable`, `@State`, `@Bindable`, `@Environment`의 사용 기준을 말할 수 있다.
- 왜 Observation이 `ObservableObject`보다 읽기 추적 관점에서 더 정교한지 설명할 수 있다.
- `Observation.md`에 파일별 메모와 비교 정리가 남아 있다.
