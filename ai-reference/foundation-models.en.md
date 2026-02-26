# Foundation Models AI Reference

> On-device AI/LLM implementation guide. Read this document to use Foundation Models.

## Overview

Foundation Models is a framework that provides on-device AI capabilities in iOS 26+.
It leverages Apple Intelligence to implement text generation, summarization, tool use, and more while protecting privacy.

## Required Import

```swift
import FoundationModels
```

## Core Components

### 1. LanguageModelSession (Session Creation)

```swift
// Basic session
let session = LanguageModelSession()

// With system prompt
let session = LanguageModelSession(
    instructions: "You are a friendly cooking assistant. Respond in English."
)
```

### 2. Text Generation

```swift
// Simple generation
let response = try await session.respond(to: "Tell me a pasta recipe")
print(response.content)

// Streaming
for try await partial in session.streamResponse(to: "Tell me a pasta recipe") {
    print(partial.content, terminator: "")
}
```

### 3. Tool Definition

```swift
@Generable
struct WeatherTool: Tool {
    static let name = "weather"
    static let description = "Gets the current weather for a city"
    
    struct Arguments: Codable, Sendable {
        @Guide(description: "City name (e.g., Seoul, Busan)")
        let city: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        // Actual weather API call or simulation
        return "Current weather in \(arguments.city): Clear, 23°C"
    }
}
```

## Complete Working Example: AI Chatbot

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
            You are a friendly and helpful AI assistant.
            Respond concisely and accurately.
            Communicate in English.
            """
        )
    }
    
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(role: .user, content: text, timestamp: Date())
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        
        do {
            // Generate AI response
            let response = try await session?.respond(to: text)
            let assistantMessage = ChatMessage(
                role: .assistant,
                content: response?.content ?? "Unable to generate response.",
                timestamp: Date()
            )
            messages.append(assistantMessage)
        } catch {
            let errorMessage = ChatMessage(
                role: .assistant,
                content: "Error: \(error.localizedDescription)",
                timestamp: Date()
            )
            messages.append(errorMessage)
        }
        
        isLoading = false
    }
    
    func clearHistory() {
        messages.removeAll()
        setupSession()  // Reset session
    }
}

// MARK: - View
struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Message list
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
                
                // Input field
                HStack(spacing: 12) {
                    TextField("Enter message...", text: $viewModel.inputText)
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
            .navigationTitle("AI Chatbot")
            .toolbar {
                Button("Reset") {
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

## Tool Usage Example

```swift
// Define multiple tools
@Generable
struct CalculatorTool: Tool {
    static let name = "calculator"
    static let description = "Performs mathematical calculations"
    
    struct Arguments: Codable, Sendable {
        @Guide(description: "Expression (e.g., 2 + 2, 10 * 5)")
        let expression: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        // Simple calculation logic
        let expr = NSExpression(format: arguments.expression)
        if let result = expr.expressionValue(with: nil, context: nil) as? NSNumber {
            return "Result: \(result)"
        }
        return "Cannot calculate"
    }
}

@Generable
struct SearchTool: Tool {
    static let name = "search"
    static let description = "Searches for information"
    
    struct Arguments: Codable, Sendable {
        @Guide(description: "Search keywords")
        let query: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        // Actually would call an API
        return "Search results for '\(arguments.query)'..."
    }
}

// Create session with tools
let session = LanguageModelSession(
    instructions: "Actively use tools to help the user.",
    tools: [WeatherTool(), CalculatorTool(), SearchTool()]
)

// Question that requires tool invocation
let response = try await session.respond(to: "What's the weather in Seoul?")
// AI automatically calls WeatherTool
```

## Streaming Response

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
            streamedText = "Error: \(error.localizedDescription)"
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
            
            Button("Start Generation") {
                Task {
                    await viewModel.streamResponse(prompt: "Explain the history of artificial intelligence")
                }
            }
            .disabled(viewModel.isStreaming)
        }
    }
}
```

## Important Notes

1. **iOS 26+ Only**: Not available in earlier versions
2. **Apple Silicon Required**: On-device AI requires Neural Engine
3. **Privacy**: Data never leaves the device
4. **Sendable Compliance**: Tool Arguments must be Sendable
5. **@Generable Macro**: Required when defining Tools

## Availability Check

```swift
if LanguageModelSession.isAvailable {
    // Foundation Models available
} else {
    // Fallback logic (e.g., server API)
}
```
