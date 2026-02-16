import CoreNFC
import Foundation

class MultiLanguageHandler {
    
    struct LocalizedText {
        let language: String
        let text: String
    }
    
    /// 메시지에서 모든 텍스트 레코드를 추출
    func extractAllTexts(_ message: NFCNDEFMessage) -> [LocalizedText] {
        var results: [LocalizedText] = []
        
        for record in message.records {
            guard record.typeNameFormat == .nfcWellKnown,
                  String(data: record.type, encoding: .utf8) == "T",
                  let (text, locale) = record.wellKnownTypeTextPayload() else {
                continue
            }
            
            results.append(LocalizedText(
                language: locale?.identifier ?? "unknown",
                text: text
            ))
        }
        
        return results
    }
    
    /// 현재 디바이스 언어에 맞는 텍스트 반환
    func getLocalizedText(_ message: NFCNDEFMessage) -> String? {
        let texts = extractAllTexts(message)
        
        // 현재 디바이스 언어
        let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        // 1. 정확히 일치하는 언어 찾기
        if let match = texts.first(where: { $0.language == deviceLanguage }) {
            return match.text
        }
        
        // 2. 언어 코드 앞부분만 일치 (예: "en-US" vs "en")
        if let match = texts.first(where: { $0.language.hasPrefix(deviceLanguage) }) {
            return match.text
        }
        
        // 3. 영어 폴백
        if let english = texts.first(where: { $0.language.hasPrefix("en") }) {
            return english.text
        }
        
        // 4. 첫 번째 텍스트
        return texts.first?.text
    }
}
