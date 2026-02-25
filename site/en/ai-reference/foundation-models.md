# Foundation Models AI Reference

> 온디바이스 AI/LLM 구현 가이드. 이 문서를 읽고 Foundation Models를 활용할 수 있습니다.

## 개요

Foundation Models는 iOS 26+에서 온디바이스 AI 기능을 제공하는 프레임워크입니다.
Apple Intelligence를 활용해 프라이버시를 보호하면서 텍스트 생성, 요약, 도구 사용 등을 구현합니다.

## 필수 Import

```swift
import FoundationModels
```

## 핵심 구성요소

### 1. LanguageModelSession (세션 생성)

```swift
// 기본 세션
let session = LanguageModelSession()

// 시스템 프롬프트 포함
let session = LanguageModelSession(
    instructions: "당신은 친절한 요리 도우미입니다. 한국어로 답변하세요."
)
```

### 2. 텍스트 생성

```swift
// 단순 생성
let response = try await session.respond(to: "파스타 레시피 알려줘")
print(response.content)

// 스트리밍
for try await partial in session.streamResponse(to: "파스타 레시피 알려줘") {
    print(partial.content, terminator: "")
}
```

### 3. Tool (도구) 정의

```swift
@Generable
struct WeatherTool: Tool {
    static let name = "weather"
    static let description = "도시의 현재 날씨를 가져옵니다"
    
    struct Arguments: Codable, Sendable {
        @Guide(description: "도시 이름 (예: 서울, 부산)")
        let city: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        // 실제 날씨 API 호출 또는 시뮬레이션
        return "\(arguments.city)의 현재 날씨: 맑음, 23°C"
    }
}
```

## 전체 작동 예제: AI 챗봇

```swift
import SwiftUI
import FoundationModels

// MARK: - Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    let timestamp: Date
    
    enum Role {
        case user, assistant
    }
}

// MARK: - ViewModel
@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var inputText = ""
    var isLoading = false
    
    private var session: LanguageModelSession?
    
    init() {
        setupSession()
    }
    
    private func setupSession() {
        session = LanguageModelSession(
            instructions: """
            당신은 친절하고 도움이 되는 AI 어시스턴트입니다.
            간결하고 정확하게 답변하세요.
            한국어로 대화합니다.
            """
        )
    }
    
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // 사용자 메시지 추가
        let userMessage = ChatMessage(role: .user, content: text, timestamp: Date())
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        
        do {
            // AI 응답 생성
            let response = try await session?.respond(to: text)
            let assistantMessage = ChatMessage(
                role: .assistant,
                content: response?.content ?? "응답을 생성할 수 없습니다.",
                timestamp: Date()
            )
            messages.append(assistantMessage)
        } catch {
            let errorMessage = ChatMessage(
                role: .assistant,
                content: "오류: \(error.localizedDescription)",
                timestamp: Date()
            )
            messages.append(errorMessage)
        }
        
        isLoading = false
    }
    
    func clearHistory() {
        messages.removeAll()
        setupSession()  // 세션 초기화
    }
}

// MARK: - View
struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 메시지 목록
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) {
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                
                Divider()
                
                // 입력 필드
                HStack(spacing: 12) {
                    TextField("메시지 입력...", text: $viewModel.inputText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        Task {
                            await viewModel.sendMessage()
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                }
                .padding()
            }
            .navigationTitle("AI 챗봇")
            .toolbar {
                Button("초기화") {
                    viewModel.clearHistory()
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user { Spacer() }
            
            Text(message.content)
                .padding(12)
                .background(message.role == .user ? Color.blue : Color.gray.opacity(0.2))
                .foregroundStyle(message.role == .user ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if message.role == .assistant { Spacer() }
        }
    }
}

#Preview {
    ChatView()
}
```

## Tool 사용 예제

```swift
// 여러 도구 정의
@Generable
struct CalculatorTool: Tool {
    static let name = "calculator"
    static let description = "수학 계산을 수행합니다"
    
    struct Arguments: Codable, Sendable {
        @Guide(description: "계산식 (예: 2 + 2, 10 * 5)")
        let expression: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        // 간단한 계산 로직
        let expr = NSExpression(format: arguments.expression)
        if let result = expr.expressionValue(with: nil, context: nil) as? NSNumber {
            return "결과: \(result)"
        }
        return "계산할 수 없습니다"
    }
}

@Generable
struct SearchTool: Tool {
    static let name = "search"
    static let description = "정보를 검색합니다"
    
    struct Arguments: Codable, Sendable {
        @Guide(description: "검색 키워드")
        let query: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        // 실제로는 API 호출
        return "'\(arguments.query)'에 대한 검색 결과입니다..."
    }
}

// 도구와 함께 세션 생성
let session = LanguageModelSession(
    instructions: "도구를 적극 활용해 사용자를 도와주세요.",
    tools: [WeatherTool(), CalculatorTool(), SearchTool()]
)

// 도구 호출이 필요한 질문
let response = try await session.respond(to: "서울 날씨 어때?")
// AI가 자동으로 WeatherTool 호출
```

## 스트리밍 응답

```swift
@Observable
class StreamingViewModel {
    var streamedText = ""
    var isStreaming = false
    
    func streamResponse(prompt: String) async {
        let session = LanguageModelSession()
        isStreaming = true
        streamedText = ""
        
        do {
            for try await partial in session.streamResponse(to: prompt) {
                streamedText += partial.content
            }
        } catch {
            streamedText = "오류: \(error.localizedDescription)"
        }
        
        isStreaming = false
    }
}

struct StreamingView: View {
    @State var viewModel = StreamingViewModel()
    
    var body: some View {
        VStack {
            ScrollView {
                Text(viewModel.streamedText)
                    .padding()
            }
            
            Button("생성 시작") {
                Task {
                    await viewModel.streamResponse(prompt: "인공지능의 역사를 설명해주세요")
                }
            }
            .disabled(viewModel.isStreaming)
        }
    }
}
```

## 주의사항

1. **iOS 26+ 전용**: 이전 버전에서는 사용 불가
2. **Apple Silicon 필요**: 온디바이스 AI는 Neural Engine 필요
3. **프라이버시**: 데이터가 기기를 떠나지 않음
4. **Sendable 준수**: Tool Arguments는 Sendable 필수
5. **@Generable 매크로**: Tool 정의 시 필수

## 가용성 확인

```swift
if LanguageModelSession.isAvailable {
    // Foundation Models 사용 가능
} else {
    // 대체 로직 (예: 서버 API)
}
```
