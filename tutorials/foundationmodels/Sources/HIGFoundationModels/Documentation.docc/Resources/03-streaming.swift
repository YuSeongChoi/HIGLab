import FoundationModels
import SwiftUI

@MainActor
class StreamingChatViewModel: ObservableObject {
    @Published var response = ""
    @Published var isGenerating = false
    
    private let model = LanguageModel.default
    
    func streamMessage(_ prompt: String) async {
        isGenerating = true
        response = ""
        
        do {
            // AsyncSequence로 토큰 단위 스트리밍
            for try await token in model.streamGenerate(prompt: prompt) {
                response += token.text
            }
        } catch {
            response = "오류: \(error)"
        }
        
        isGenerating = false
    }
}

// SwiftUI에서 사용
struct ChatView: View {
    @StateObject var viewModel = StreamingChatViewModel()
    @State var input = ""
    
    var body: some View {
        VStack {
            ScrollView {
                Text(viewModel.response)
                    .animation(.easeInOut, value: viewModel.response)
            }
            
            HStack {
                TextField("메시지 입력", text: $input)
                Button("보내기") {
                    Task { await viewModel.streamMessage(input) }
                }
                .disabled(viewModel.isGenerating)
            }
        }
    }
}
