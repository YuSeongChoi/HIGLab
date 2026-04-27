# Foundation Models

## 학습 소스
- site: `site/foundationmodels/01-ai-chatbot.html`
- tutorials: `tutorials/foundationmodels`
- sample: `samples/AIChatbot`
- ai-reference: `ai-reference/foundationmodels.md`
- issue draft: `practice/HIGPractice/HIGPractice/Learning/Phase-01-AppFrameworks/FoundationModels/ISSUE_DRAFT.md`
- issue: `#31`
- branch: `learning/foundation-models-aichatbot`

## 이번 학습 구조
- 이번 Foundation Models 학습은 `AIChatbot`을 기준으로 온디바이스 모델을 앱에 연결하는 흐름을 읽는다.
- SwiftUI/Observation에서 봤던 화면 상태와 상태 소유권을, 이번에는 모델 세션과 대화 흐름 관점으로 다시 본다.
- 핵심 질문은 아래 5가지다.
  - 모델 세션은 어디서 만들고 누가 소유하는가
  - prompt와 instruction은 어디서 구성되는가
  - streaming 응답은 어떤 상태 변화로 화면에 반영되는가
  - tool calling은 앱 로직과 모델 응답 사이에서 어떤 경계 역할을 하는가
  - safety, guardrails, context 관리는 어디에 배치하는가

## 이번 학습 방식
- 읽는 순서는 고정한다.
  1. `AIChatbotApp.swift`
  2. `ContentView.swift`
  3. `ChatManager.swift`
  4. `ConversationStore.swift`
  5. `Message.swift`
  6. `InputBarView.swift`
  7. `MessageBubbleView.swift`
  8. `SettingsView.swift`
- 각 파일에서 "Foundation Models 관점 메모"를 남긴다.
- 문법만 외우지 말고, `AIChatbot`에서 대화 상태와 모델 세션 경계를 설명할 수 있는지까지 본다.

## 읽는 순서와 체크 포인트

### 1. `AIChatbotApp.swift`
- 파일: `samples/AIChatbot/AIChatbotApp/AIChatbotApp.swift`
- 여기서는 "앱 진입점과 루트 의존성"을 본다.
- 완료 여부: [ ]
- 체크 포인트
  - 앱 루트 구조
  - shared store/session 주입 여부
  - preview 또는 sample data 경계

### 내가 적을 메모
- 

## `AIChatbotApp.swift`를 보고 답할 질문
- 앱 루트는 어떤 상태를 직접 소유하는가
- 모델 관련 객체는 앱 루트에서 만들어지는가, 화면/매니저에서 만들어지는가

### 2. `ContentView.swift`
- 파일: `samples/AIChatbot/AIChatbotApp/ContentView.swift`
- 여기서는 "채팅 화면과 대화 흐름"을 본다.
- 완료 여부: [ ]
- 체크 포인트
  - 메시지 목록 표시
  - 입력 전송 액션
  - loading/streaming 상태 표시
  - 설정 화면 연결

### 내가 적을 메모
- 

## `ContentView.swift`를 보고 답할 질문
- 사용자가 보낸 메시지는 어디서 모델 요청으로 바뀌는가
- streaming 중인 응답은 어떤 상태로 표현되는가
- View가 직접 모델 API를 호출하는가, 별도 객체에 위임하는가

### 3. `ChatManager.swift`
- 파일: `samples/AIChatbot/Shared/ChatManager.swift`
- 여기서는 "Foundation Models 세션 사용 지점"을 본다.
- 완료 여부: [ ]
- 체크 포인트
  - `LanguageModelSession`
  - instruction/prompt 구성
  - streaming 응답 처리
  - tool calling 연결
  - error handling

### 내가 적을 메모
- 

## `ChatManager.swift`를 보고 답할 질문
- 세션은 언제 생성되고 언제 재사용되는가
- prompt와 instruction은 어떤 책임으로 나뉘는가
- 모델 응답이 UI 메시지로 바뀌는 경계는 어디인가

### 4. `ConversationStore.swift`
- 파일: `samples/AIChatbot/Shared/ConversationStore.swift`
- 여기서는 "대화 저장과 복원"을 본다.
- 완료 여부: [ ]
- 체크 포인트
  - conversation 목록 관리
  - 현재 conversation 선택
  - 저장/복원 방식
  - 모델 context와 앱 저장 상태의 경계

### 내가 적을 메모
- 

## `ConversationStore.swift`를 보고 답할 질문
- 저장된 대화와 모델 세션 context는 같은 것인가
- 새 대화를 시작할 때 어떤 상태가 초기화되는가

### 5. `Message.swift`
- 파일: `samples/AIChatbot/Shared/Message.swift`
- 여기서는 "채팅 도메인 모델"을 본다.
- 완료 여부: [ ]
- 체크 포인트
  - role 구분
  - text/content 표현
  - timestamp/id
  - streaming 임시 메시지 표현 여부

### 내가 적을 메모
- 

## `Message.swift`를 보고 답할 질문
- user/assistant/tool 메시지는 어떻게 구분되는가
- 모델 응답 중간 상태를 Message 모델이 직접 표현하는가

### 6. UI 세부 View
- 파일:
  - `samples/AIChatbot/AIChatbotApp/InputBarView.swift`
  - `samples/AIChatbot/AIChatbotApp/MessageBubbleView.swift`
  - `samples/AIChatbot/AIChatbotApp/SettingsView.swift`
- 여기서는 "UI와 모델 로직의 경계"를 본다.
- 완료 여부: [ ]
- 체크 포인트
  - 입력 상태
  - 메시지 렌더링
  - 모델 설정 변경
  - guardrails/safety 옵션 노출 여부

### 내가 적을 메모
- 

## UI 세부 View를 보고 답할 질문
- 어떤 상태가 UI 전용이고, 어떤 상태가 모델 요청에 영향을 주는가
- 설정 변경은 기존 세션에 즉시 반영되는가, 다음 요청부터 반영되는가

## Foundation Models 핵심 개념 요약

### `LanguageModelSession`
- 온디바이스 모델과 대화를 주고받는 세션 객체다.
- 앱에서는 세션 생성 시점, 재사용 범위, context 초기화 기준을 명확히 정해야 한다.

### Prompt / Instruction
- prompt는 사용자의 현재 요청에 가깝다.
- instruction은 모델이 따라야 하는 역할, 제약, 응답 스타일 같은 지속 규칙에 가깝다.

### Streaming
- 응답 전체가 끝난 뒤 한 번에 표시하는 대신, 생성 중인 텍스트를 점진적으로 UI에 반영하는 흐름이다.
- UI에서는 "현재 생성 중인 assistant 메시지"와 "완료된 메시지"의 경계를 정리해야 한다.

### Tool Calling
- 모델이 직접 계산하거나 외부 상태를 아는 척하지 않고, 앱이 제공한 도구를 호출해 결과를 받아오는 구조다.
- tool은 모델과 앱 로직 사이의 명시적 계약으로 보는 편이 좋다.

### Safety / Guardrails
- 입력 전 검증, 모델 instruction, 출력 후 검증, UI 안내를 함께 고려해야 한다.
- 챗봇 앱에서는 실패/거절/재시도 상태까지 사용자 경험으로 설계해야 한다.
