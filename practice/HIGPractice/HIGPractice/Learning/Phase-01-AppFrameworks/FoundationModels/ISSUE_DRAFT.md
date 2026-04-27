# [학습] Phase 1 - Foundation Models

- label: `learning`
- branch: `learning/foundation-models-aichatbot`
- issue: `#31`

## 학습 Phase
- Phase 1: App Frameworks

## Framework 이름
- Foundation Models

## Sample 앱
- AIChatbot

## 이번 학습 목표
- `AIChatbot`을 기준으로 Foundation Models의 앱 연결 지점을 설명할 수 있다.
- `LanguageModelSession`, prompt/instruction, streaming 응답, tool calling의 역할을 구분할 수 있다.
- 채팅 UI 상태와 모델 세션 상태를 어디서 소유하고 갱신하는지 정리한다.
- guardrails, safety, context 관리가 실제 챗봇 앱 구조에서 어디에 들어가는지 설명할 수 있다.
- 이후 온디바이스 AI 기능을 앱에 붙일 때 재사용할 수 있는 구조 메모를 남긴다.

## 작업 체크리스트
- [ ] site 개념 확인
- [ ] tutorials 실습
- [ ] samples 구조 비교
- [ ] `AIChatbotApp.swift` 읽고 앱 진입점/루트 연결 방식 정리
- [ ] `ContentView.swift` 읽고 화면 상태와 대화 흐름 정리
- [ ] `ChatManager.swift` 읽고 Foundation Models 세션 사용 방식 정리
- [ ] `ConversationStore.swift` 읽고 대화 저장/복원 경계 정리
- [ ] `Message.swift` 읽고 메시지 모델 역할 정리
- [ ] `InputBarView.swift`, `MessageBubbleView.swift`, `SettingsView.swift` 읽고 UI와 모델 로직 경계 정리
- [ ] streaming, tool calling, safety/context 관리 메모 작성
- [ ] PR 생성 및 CI 확인
- [ ] 머지 후 `LEARNING_LOG` / 회고 기록

## 완료 조건 (Definition of Done)
- `AIChatbot` 기준 Foundation Models 핵심 파일의 역할을 스스로 설명할 수 있다.
- Foundation Models 세션 생성, prompt 구성, streaming 응답 처리 흐름을 말할 수 있다.
- tool calling과 guardrails가 앱 구조에서 어디에 들어가는지 설명할 수 있다.
- `FoundationModels.md`에 파일별 메모와 비교 정리가 남아 있다.
