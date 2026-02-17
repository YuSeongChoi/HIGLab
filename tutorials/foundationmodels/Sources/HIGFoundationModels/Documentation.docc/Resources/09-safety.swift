import FoundationModels
import SwiftUI

// 안전한 AI 응답 처리
struct SafeAIResponse {
    let content: String
    let wasFiltered: Bool
    let safetyInfo: SafetyInfo?
    
    struct SafetyInfo {
        let category: String
        let suggestion: String
    }
}

class SafetyAwareChatModel: ObservableObject {
    @Published var lastResponse: SafeAIResponse?
    @Published var isProcessing = false
    
    private let session = LanguageModel.default.createSession(
        systemPrompt: """
        당신은 도움이 되는 AI 어시스턴트입니다.
        - 사실에 기반한 정보만 제공하세요
        - 확실하지 않은 내용은 그렇다고 말하세요
        - 위험하거나 불법적인 활동을 조장하지 마세요
        """
    )
    
    func process(_ input: String) async {
        isProcessing = true
        
        do {
            let response = try await session.generate(prompt: input)
            
            await MainActor.run {
                lastResponse = SafeAIResponse(
                    content: response,
                    wasFiltered: false,
                    safetyInfo: nil
                )
            }
            
        } catch LanguageModelError.guardrailViolation(let reason) {
            await MainActor.run {
                lastResponse = SafeAIResponse(
                    content: "죄송합니다. 해당 요청에 응답할 수 없습니다.",
                    wasFiltered: true,
                    safetyInfo: SafeAIResponse.SafetyInfo(
                        category: reason.description,
                        suggestion: getSuggestion(for: reason)
                    )
                )
            }
            
        } catch {
            await MainActor.run {
                lastResponse = SafeAIResponse(
                    content: "일시적인 오류가 발생했습니다. 다시 시도해주세요.",
                    wasFiltered: false,
                    safetyInfo: nil
                )
            }
        }
        
        isProcessing = false
    }
    
    private func getSuggestion(for reason: GuardrailViolation) -> String {
        switch reason {
        case .harmfulContent:
            return "다른 주제로 대화해보시겠어요?"
        case .personalInformation:
            return "개인정보 보호를 위해 일부 정보는 제공되지 않습니다."
        case .unsupportedTopic:
            return "이 주제에 대해서는 도움을 드리기 어렵습니다."
        @unknown default:
            return "다른 질문을 해보시겠어요?"
        }
    }
}
