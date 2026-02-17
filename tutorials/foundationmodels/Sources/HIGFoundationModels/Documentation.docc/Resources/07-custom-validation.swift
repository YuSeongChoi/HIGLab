import FoundationModels
import NaturalLanguage

// 커스텀 입력 검증기
struct InputValidator {
    
    // 입력 길이 제한
    static let maxInputLength = 2000
    
    // 금지된 키워드 (앱 특성에 맞게 정의)
    private static let blockedPatterns: [String] = [
        // 앱 특성에 맞는 제한 키워드 정의
    ]
    
    struct ValidationResult {
        let isValid: Bool
        let sanitizedInput: String
        let message: String?
    }
    
    static func validate(_ input: String) -> ValidationResult {
        // 1. 빈 입력 체크
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return ValidationResult(
                isValid: false,
                sanitizedInput: "",
                message: "메시지를 입력해주세요."
            )
        }
        
        // 2. 길이 제한
        if trimmed.count > maxInputLength {
            return ValidationResult(
                isValid: false,
                sanitizedInput: String(trimmed.prefix(maxInputLength)),
                message: "메시지가 너무 깁니다. \(maxInputLength)자 이내로 입력해주세요."
            )
        }
        
        // 3. 언어 감지 (한국어/영어만 허용하는 경우)
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(trimmed)
        if let language = recognizer.dominantLanguage {
            let supportedLanguages: [NLLanguage] = [.korean, .english]
            if !supportedLanguages.contains(language) {
                return ValidationResult(
                    isValid: false,
                    sanitizedInput: trimmed,
                    message: "한국어 또는 영어로 입력해주세요."
                )
            }
        }
        
        return ValidationResult(
            isValid: true,
            sanitizedInput: trimmed,
            message: nil
        )
    }
}

// 검증기를 적용한 채팅 함수
func sendMessage(_ input: String) async -> String {
    let validation = InputValidator.validate(input)
    
    guard validation.isValid else {
        return validation.message ?? "입력을 확인해주세요."
    }
    
    let session = LanguageModel.default.createSession()
    
    do {
        return try await session.generate(prompt: validation.sanitizedInput)
    } catch {
        return "응답을 생성할 수 없습니다."
    }
}
