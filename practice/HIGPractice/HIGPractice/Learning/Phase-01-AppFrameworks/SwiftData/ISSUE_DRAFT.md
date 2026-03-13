# [학습] Phase 1 - SwiftData

- label: `learning`
- branch: `learning/swiftdata-taskmaster`
- issue: `#23`

## 학습 Phase
- Phase 1: App Frameworks

## Framework 이름
- SwiftData

## 이번 학습 목표
- `TaskMaster`를 기준으로 SwiftData의 앱 연결 지점을 설명할 수 있다.
- `@Model`, `ModelContainer`, `ModelContext`, `@Query`, `#Predicate`의 역할을 구분할 수 있다.
- `Create / Read / Update / Delete` 흐름이 `TaskMaster` 안에서 어디서 일어나는지 정리한다.
- SwiftData와 `UserDefaults`, `Keychain`의 저장 목적과 적용 범위를 비교 설명할 수 있다.
- 이후 `Observation` 학습으로 자연스럽게 넘어갈 수 있도록 데이터 흐름 메모를 남긴다.

## 작업 체크리스트
- [ ] site 개념 확인
- [ ] tutorials 실습
- [ ] samples 구조 비교
- [ ] `TaskMasterApp.swift` 읽고 container/context 연결 방식 정리
- [ ] `TaskItem.swift`, `Category.swift` 읽고 모델/관계 정의 정리
- [ ] `ContentView.swift`에서 `@Query`와 메모리 필터링 경계 정리
- [ ] `AddTaskView.swift`에서 create 흐름 정리
- [ ] `TaskDetailView.swift`에서 update/delete 흐름 정리
- [ ] `DataService.swift`에서 `FetchDescriptor`, `#Predicate`, 정렬 패턴 정리
- [ ] SwiftData vs UserDefaults vs Keychain 비교 메모 작성
- [ ] PR 생성 및 CI 확인
- [ ] 머지 후 `LEARNING_LOG`/Velog 기록

## 완료 조건 (Definition of Done)
- `TaskMaster` 기준 SwiftData 핵심 파일 7개의 역할을 스스로 설명할 수 있다.
- `@Query`와 `FetchDescriptor`의 사용 기준을 말할 수 있다.
- 왜 SwiftData가 `UserDefaults`나 `Keychain`의 대체재가 아닌지 설명할 수 있다.
- `SwiftData.md`에 파일별 메모와 비교 정리가 남아 있다.
